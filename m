Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id TAA24070
	for <linux-mm@kvack.org>; Sat, 14 Dec 2002 19:09:32 -0800 (PST)
Message-ID: <3DFBF26B.47C04A6@digeo.com>
Date: Sat, 14 Dec 2002 19:09:31 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: freemaps
References: <003601c2a3c2$cf721ba0$0d50858e@sybix>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Frederic Rossi (LMC)" <Frederic.Rossi@ericsson.ca>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Frederic Rossi (LMC)" wrote:
> 
> ...
> 100000 mmaps, mmap=2545 msec munmap=59 msec
> 100000 mmaps, mmap=2545 msec munmap=58 msec
> 100000 mmaps, mmap=2544 msec munmap=60 msec
> 100000 mmaps, mmap=2547 msec munmap=60 msec
> 
> and with freemaps I get
> 100000 mmaps, mmap=79 msec munmap=60 msec
> 100000 mmaps, mmap=79 msec munmap=60 msec
> 100000 mmaps, mmap=80 msec munmap=60 msec
> 100000 mmaps, mmap=79 msec munmap=60 msec
> 

Yes, this is a real failing.

>  
> +ssize_t proc_pid_read_vmc (struct task_struct *task, struct file * file, char * buf, size_t count, loff_t *ppos)
> +{

This should use the seq_file API.

> +struct vma_cache_struct {
> +	struct list_head head;
> +	unsigned long vm_start;
> +	unsigned long vm_end;
> +};

So this is the key part.  It is a per-mm linear list of unmapped areas.

You state that its locking is via mm->mmap_sem.  I assume that means
a down_write() of that semaphore?

As this is a linear list, I do not understand why it does not have similar failure
modes to the current search.  Suppose this list describes 100,000 4k unmapped
areas and the application requests an 8k mmap??

> +static __inline__ int vma_cache_chainout (struct mm_struct *mm, struct vma_cache_struct *vmc)
> +{
> +	if (!vmc)
> +		return -EINVAL;
> +
> +	list_del_init (&vmc->head);
> +	vma_cache_free (vmc);

vma_cache_free() already does the list_del_init().
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
