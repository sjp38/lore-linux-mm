Message-ID: <38E9A47F.F1286A57@mandrakesoft.com>
Date: Tue, 04 Apr 2000 04:14:55 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: RFC: kvmd - kernel VM the easy way
Content-Type: multipart/mixed;
 boundary="------------DADEDCAEC7019DF36D93641A"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------DADEDCAEC7019DF36D93641A
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

This little bugger exists because of tmpfs.

I have always wanted to create a virtual memory filesystem, like
Solaris' tmpfs.  Currently, doing this involves sticking your hands DEEP
into the guts of the page cache, swap cache, and other nastiness.  The
main reason such nastiness is necessary, AFAICS, is that swappable pages
are tied a process fairly closely.  ie. current->mm is referenced quite
a bit in the MM/swap code.

For tmpfs and other uses the kernel may have for VM, we want driver<->VM
association, not process<->VM association.  So, I hacked up some code
which allows kernel drivers to use swappable VM too.

The main idea behind the hack is to create kernel threads, and associate
MAP_ANONYMOUS mappings with those kernel threads, at the request of any
random kernel driver.

I think this hack makes it possible to use the page cache and swap cache
as a general cache, without having to rewrite the MM subsystem or adding
memory-pressure callbacks or stuff like that.  It seems like filesystems
would find kvmd most useful, but there are probably others uses for it
as well.

Attached is the kernel api (kvmd.h) and sample implementation for this
idea (kvmd.c).  The API can be summarized as

kvmd_open - attach to a VM kernel thread
kvmd_alloc - allocate some swappable memory (create new MAP_ANONYMOUS
mapping)
kvmd_map - fault a region of swappable memory into RAM, for subsequent
access by kernel driver

kvmd_unmap - release region locked into RAM by kvmd_map
kvmd_free - release MAP_ANONYMOUS mapping
kvmd_close - release attachment to VM kernel thread

Random notes...
* A thread pool is used to distribute the mappings, and in the process
create a nicely parallel system
* It would probably be nice to be able to expand and shrink mappings
too.
* It would be simple to expand the system to support apache-style
min/max process thresholds

Disclaimers...
* The big disclaimer :) I am not am MM guru.  This may not solve the
problems described at all...
* THE ATTACHED CODE EXISTS ONLY TO ILLUSTRATE A POINT.  It was typed
straight off-the-cuff, and I never even attempted to compile it.
* the SMP locking may be off, and in some places it might be good to
replace wait queue with semaphore

Comments welcome...

-- 
Jeff Garzik              | Tact is the ability to tell a man 
Building 1024            | he has an open mind when he has a
MandrakeSoft, Inc.       | hole in his head.  (-random fortune)
--------------DADEDCAEC7019DF36D93641A
Content-Type: text/plain; charset=us-ascii;
 name="kvmd.h"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kvmd.h"

/*
 * include/linux/kvmd.h - API for the kernel VM mapping daemon
 *
 * Copyright 2000 Jeff Garzik <jgarzik@mandrakesoft.com>
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file COPYING in the main directory of this archive
 * for more details.
 *
 */

#ifndef __LINUX_KVMD_H__
#define __LINUX_KVMD_H__

#ifdef __KERNEL__

/* max number of outstanding commands for each thread */
#define KVMD_QUEUE_LEN		16

/* kvmd per-thread flags */
#define KVMD_DEDICATED		(1<<0) /* one-one thread-driver mapping */


struct kvmd_command {
	struct list_head node;
	wait_queue_head_t wait;
	int cmd;
	long arg[4];
};


typedef struct {
	struct list_head node;

	struct task *tsk;
	int flags;

	wait_queue_head_t wait;
	spinlock_t lock;
	struct semaphore thr_start_sem;

	const char *name;
	
	atomic_t n_attach;

	struct kvmd_command cmd [KVMD_QUEUE_LEN];
	struct list_head cmd_list;
	struct list_head free_list;
} kvmd_t;


int kvmd_open (kvmd_t **vmd_out);
void kvmd_close (kvmd_t *vmd);

long kvmd_alloc (kvmd_t *vmd, size_t *vaddr_out, size_t size);
long kvmd_free (kvmd_t *vmd, size_t vaddr, size_t size);

int kvmd_map (int rw, kvmd_t *vmd, size_t vaddr, size_t size, struct kiobuf **iobuf_out);
void kvmd_unmap (kvmd_t *vmd, struct kiobuf *iobuf);


#endif /*  __KERNEL__  */
#endif /*  __LINUX_KVMD_H__  */

--------------DADEDCAEC7019DF36D93641A
Content-Type: text/plain; charset=us-ascii;
 name="kvmd.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kvmd.c"

/*
 * mm/kvmd.c - kernel VM mapping daemon
 *
 * Copyright 2000 Jeff Garzik <jgarzik@mandrakesoft.com>
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file COPYING in the main directory of this archive
 * for more details.
 *
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/kvmd.h>


#define KVMD_CMD_NONE		0
#define KVMD_CMD_ALLOC		1
#define KVMD_CMD_FREE		2
#define KVMD_CMD_EXIT		3

#define kvmd_list_entry(n) list_entry(n, kvmd_t, node)
#define kvmd_cmd_entry(n) list_entry(n, struct kvmd_command, node)
#define kvmd_for_each_thr(vmd) \
	for(dev = kvmd_list_entry(kvmd_threads.next); \
	    dev != kvmd_list_entry(&kvmd_threads); \
	    dev = kvmd_list_entry(&dev->node.next))
#define is_list_empty(head) (head->next == head)


static LIST_HEAD(kvmd_threads);
static size_t kvmd_n_threads;
static size_t kvmd_cur_thread;
static spinlock_t kvmd_lock;


static kvmd_t * kvmd_alloc_struct (void);
static void kvmd_free_struct (kvmd_t *vmd);


/* input: arg[0] == mapping length
 * output: arg[0] > 0 -- virtual address of mapping
 *	   arg[0] < 0 -- error code
 */
static void kvmd_cmd_alloc (kvmd_t *vmd, struct kvmd_command *kc)
{
	long error;
	
        down(&current->mm->mmap_sem);
        lock_kernel();
 
        error = do_mmap_pgoff(NULL, 0, kc->arg[0], PROT_READ|PROT_WRITE,
			      MAP_PRIVATE|MAP_ANONYMOUS, 0);
 
        unlock_kernel();
        up(&current->mm->mmap_sem);
	
	arg[0] = error;
	wake_up (&kc->wait);
}


/* input: arg[0] == virtual address of mapping
 *	  arg[1] == length of mapping
 * output: arg[0] == return value of munmap
 */
static void kvmd_cmd_free (kvmd_t *vmd, struct kvmd_command *kc)
{
	int ret;
	
        down(&current->mm->mmap_sem);
        ret = do_munmap(kc->arg[0], kc->arg[1]);
        up(&current->mm->mmap_sem);
	
	arg[0] = ret;
	wake_up (&kc->wait);
}


static int kvmd_thread (void *data)
{
	kvmd_t *vmd = data;
	int thread_active = 1;
	struct kvmd_command *kc;

	exit_files(current);	/* daemonize doesn't do exit_files */
	daemonize();
	
	/* we want VM mappings */
	current->mm = mm_alloc ();
	
	spin_lock (&vmd->lock);
	if (!vmd->name)
		vmd->name = "kvmd";
	strcpy (current->comm, vmd->name);
	vmd->tsk = current;
	spin_unlock (&vmd->lock);
	
	up (&vmd->thr_start_sem);

	while (thread_active) {
		spin_lock_irq(&current->sigmask_lock);
		flush_signals(current);
		spin_unlock_irq(&current->sigmask_lock);

		interruptible_sleep_on(&vmd->wait);

		spin_lock (&vmd->lock);

		/* if empty list (BUG!), no further processing */
		if (is_list_empty (&vmd->cmd_list)) {
			spin_unlock (&vmd->lock);
			continue;
		}
		
		/* remove next cmd struct from cmd list */
		kc = kvmd_cmd_entry (vmd->cmd_list.next);
		list_del (&kc->node);

		spin_unlock (&vmd->lock);

		/* process command */
		switch (kc->cmd) {
		case KVMD_CMD_EXIT:
			thread_active = 0;
			break;
		case KVMD_CMD_ALLOC:
			kvmd_cmd_alloc (vmd, kc);
			break;
		case KVMD_CMD_FREE:
			kvmd_cmd_free (vmd, kc);
			break;
		default:
			printk (KERN_WARNING "kvmd: unknown cmd %d\n", kc->cmd);
			break;
		}

		/* add command struct to free list */
		spin_lock (&vmd->lock);
		list_add_tail (&kc->node, &vmd->free_list);
		spin_unlock (&vmd->lock);
	}
	
	/* clean up mappings associated with this thread */
	exit_mm (current);

	/* tsk==NULL indicates thread has exited */
	spin_lock (&vmd->lock);
	vmd->tsk = NULL;
	spin_unlock (&vmd->lock);

	return 0;
}


/* start a new kvmd thread */
static kvmd_t *kvmd_new_thread (int flags)
{
	kvmd_t *vmd;
	
	vmd = kvmd_alloc_struct ();
	if (!vmd)
		goto err_out;
	
	vmd->flags = flags;

	rc = kernel_thread (kvmd_thread, vmd, 0);
	if (rc)
		goto err_out_free;

	down_interruptible (&vmd->thr_start_sem); /* XXX check rc */

	spin_lock (&kvmd_lock);
	list_add_tail (&vmd->node, &kvmd_threads);
	kvmd_n_threads++;
	spin_unlock (&kvmd_lock);

	return vmd;

err_out_free:
	kvmd_free_struct (vmd);
err_out:
	return NULL;
}


/* rotate through a thread pool, pick next thread in line */
static kvmd_t *kvmd_select_thread (void)
{
	kvmd_t *vmd;
	size_t i, n_thr;

	spin_lock (&kvmd_lock);

	vmd = kvmd_list_entry(kvmd_threads.next);
	n_thr = kvmd_cur_thread++ % kvmd_n_threads;

	for (i = 0; i < n_thr; i++)
		vmd = kvmd_list_entry(vmd->node.next);

	spin_unlock (&kvmd_lock);
	
	return vmd;	
}


int kvmd_open (int flags, kvmd_t **vmd_out)
{
	kvmd_t *vmd;
	int n_threads;
	
	MOD_INC_USE_COUNT;
	
	*vmd_out = NULL;
	
	spin_lock (&kvmd_lock);
	n_threads = kvmd_n_threads;
	spin_unlock (&kvmd_lock);
	
	if ((flags & KVMD_DEDICATED) || (n_threads == 0))
		vmd = kvmd_new_thread (flags);
	else
		vmd = kvmd_select_thread ();

	if (!vmd) {
		MOD_DEC_USE_COUNT;
		return -EBUSY;
	}
	
	*vmd_out = vmd;
	
	atomic_inc (&vmd->n_attach);
	
	return 0;
}


void kvmd_close (kvmd_t *vmd)
{
	if (atomic_read (&vmd->n_attach) < 1)
		BUG();
	
	/* XXX if flags&DEDICATED, kill thread */
	if (flags & KVMD_DEDICATED) {
		flags &= ~KVMD_DEDICATED;
	}

	atomic_dec (&vmd->n_attach);
	MOD_DEC_USE_COUNT;
}


static long kvmd_send_cmd (kvmd_t *vmd, struct kvmd_command *kc_inout)
{
	struct kvmd_command *kc = NULL;
	int max_iter = 10000;

	while (max_iter-- > 0) {
		spin_lock (&vmd->lock);

		if (is_list_empty (&vmd->free_list)) {
			spin_unlock (&vmd->lock);
			if (current->need_resched)
				schedule();
			continue;
		}

		/* remove next cmd struct from cmd list */
		kc = kvmd_cmd_entry (vmd->free_list.next);
		list_del (&kc->node);

		spin_unlock (&vmd->lock);
		
		break;
	}
	if (!kc)
		return -EBUSY;
	
	/* fill in command struct */
	memset (kc, 0, sizeof (*kc));
	init_waitqueue_head (&kc->wait);
	kc->cmd = kc_inout->cmd;
	memcpy (&kc->arg, &kc_inout->arg, sizeof (kc->arg));
	
	/* pass command to thread */
	spin_lock (&vmd->lock);
	list_add_tail (&kc->node, &vmd->cmd_list);
	spin_unlock (&vmd->lock);
	
	/* wait for thread to process command */
	interruptible_sleep_on (&kc->wait);
	if (signal_pending(current))
		return -EAGAIN;

	/* XXX race. the command struct might be reused quickly */
	memcpy (&kc_inout->arg, &kc->arg, sizeof (kc->arg));
	
	return 0;
}


long kvmd_alloc (kvmd_t * vmd, size_t * vaddr_out, size_t size)
{
	struct kvmd_command kc;
	long rc;
	
	memset (&kc, 0, sizeof (kc));
	init_waitqueue_head (&kc.wait);
	kc.cmd = KVMD_CMD_ALLOC;
	kc.arg[0] = size;
	
	rc = kvmd_send_cmd (vmd, &kc);
	if (rc)
		return rc;
	
	if (kc.arg[0] < 0)
		return (int) kc.arg[0];
	
	*vaddr_out = kc.arg[0];
	
	return 0;
}


long kvmd_free (kvmd_t *vmd, size_t vaddr, size_t size)
{
	struct kvmd_command kc;
	long rc;
	
	memset (&kc, 0, sizeof (kc));
	init_waitqueue_head (&kc.wait);
	kc.cmd = KVMD_CMD_FREE;
	kc.arg[0] = vaddr;
	kc.arg[1] = size;
	
	rc = kvmd_send_cmd (vmd, &kc);
	if (rc)
		return rc;
	
	return kc.arg[0];
}


int kvmd_map (int rw, kvmd_t *vmd, size_t vaddr, size_t size, struct kiobuf **iobuf_out)
{
	struct task *saved = current;
	struct kiobuf *iobuf;
	int err;
	
	iobuf = *iobuf_out = NULL;
	err = alloc_kiovec (1, &iobuf);
	if (err)
		return err;

	spin_lock (&vmd->lock);
	current = vmd->tsk;
	spin_unlock (&vmd->lock);
	
	err = map_user_kiobuf (rw, iobuf, vaddr, size);
	if (err)
		free_kiovec (1, &iobuf);
	
	current = saved;
	return err;
}


void kvmd_unmap (kvmd_t *vmd, struct kiobuf *iobuf)
{
	struct task *saved = current;

	spin_lock (&vmd->lock);
	current = vmd->tsk;
	spin_unlock (&vmd->lock);
	
	unmap_kiobuf (iobuf);
	free_kiovec (1, &iobuf);

	current = saved;
}


static kvmd_t * __init kvmd_alloc_struct (void)
{
	kvmd_t *vmd;
	int i;
	
	vmd = kmalloc (sizeof (*vmd), GFP_KERNEL);
	if (!vmd)
		return NULL;

	memset (vmd, 0, sizeof (*vmd);
	
	init_waitqueue_head (&vmd->wait);
	init_MUTEX_LOCKED (&vmd->thr_start_sem);
	spin_lock_init (&vmd->lock);
	atomic_set (&vmd->n_attach, 0);
	
	INIT_LIST_HEAD (&vmd->cmd_list);
	INIT_LIST_HEAD (&vmd->free_list);
	
	for (i = KVMD_QUEUE_LEN; i > 0; i--)
		list_add_tail (&vmd->cmd[i].node, &vmd->free_list);

	return vmd;
}


static void kvmd_free_struct (kvmd_t *vmd)
{
	free_kiovec (1, &vmd->iobuf);
	kfree (vmd);
}


static void kvmd_exit_threads (void)
{
	kvmd_t *vmd, *tmp;
	struct kvmd_command cmd;
	int rc, doit_again, iter=0;
	struct task *tsk;
	
	cmd.cmd = KVMD_CMD_EXIT;

	/* signal all threads to exit */	
again:
	doit_again = 0;
	kvmd_for_each_thr(vmd) {
		spin_lock (&vmd->lock);
		tsk = vmd->tsk;
		spin_unlock (&vmd->lock);
		
		if (tsk) {
			rc = kvmd_cmd (vmd, cmd);
			if (rc)
				doit_again = 1;
		}
	}
	/* if command was not sent to one or more threads,
	 * then restart exit-signal loop 
	 * (kvmd_cmd typically fails due to command queue length limit)
	 */
	if (doit_again) {
		if (current->need_resched)
			schedule ();
		goto again;
	}
	
	/* wait for all threads to exit
	 * a thread has exited when vmd->tsk==NULL
	 */
again_butthead:
	doit_again = 0;
	kvmd_for_each_thr(vmd) {
		spin_lock (&vmd->lock);
		tsk = vmd->tsk;
		spin_unlock (&vmd->lock);
		
		if (tsk)
			doit_again = 1;

		if (current->need_resched)
			schedule ();
		
		if ((++iter % 100) == 0)
			printk (KERN_WARNING "kvmd: it's taking a while to kill those threads\n");
	}
	/* if any threasd are still alive, repeat the
	 * check-for-threads-still-alive loop :)
	 */
	if (doit_again)
		goto again_butthead;
	
	/* finally, clean up the thread pool info */
	while (!is_list_empty (&kvmd_threads)) {
		tmp = kvmd_list_entry (kvmd_threads.next);
		list_del (&tmp->node);
		kvmd_free_struct (tmp);
	}
}


static int __init kvmd_init (void)
{
	int i, rc;
	kvmd_t *vmd;

	MOD_INC_USE_COUNT;
	
	INIT_LIST_HEAD(&kvmd_threads);
	spin_lock_init (&kvmd_lock);
	kvmd_n_threads = 0;
	kvmd_cur_thread = 0;
	
	for (i = 0; i < (smp_num_cpus * 2); i++) {
		vmd = kvmd_new_thread ();
		if (!vmd) {
			rc = -ENOMEM;
			goto err_out;
		}
	}

	MOD_DEC_USE_COUNT;
	return 0;

err_out:
	kvmd_exit_threads ();
	MOD_DEC_USE_COUNT;
	return rc;
}


static void __exit kvmd_exit (void)
{
	kvmd_exit_threads ();
}

module_init(kvmd_init);
module_exit(kvmd_exit);

--------------DADEDCAEC7019DF36D93641A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
