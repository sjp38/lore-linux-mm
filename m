Date: Fri, 19 May 2006 12:27:57 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC 4/5] page migration: Support moving of individual pages
Message-Id: <20060519122757.4b4767b3.akpm@osdl.org>
In-Reply-To: <20060518182131.20734.27190.sendpatchset@schroedinger.engr.sgi.com>
References: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
	<20060518182131.20734.27190.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, bls@sgi.com, jes@sgi.com, lee.schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, Michael Kerrisk <mtk-manpages@gmx.net>
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> Add support for sys_move_pages()

This should be reviewed by the selinux guys (bcc'ed) to see if security
hooks are needed.

> move_pages() is used to move individual pages of a process. The function can
> be used to determine the location of pages and to move them onto the desired
> node. move_pages() returns status information for each page.
> 
> int move_pages(pid, number_of_pages_to_move,
> 		addresses_of_pages[],
> 		nodes[] or NULL,
> 		status[],
> 		flags);
> 
> The addresses of pages is an array of unsigned longs pointing to the
> pages to be moved.
> 
> The nodes array contains the node numbers that the pages should be moved
> to. If a NULL is passed then no pages are moved but the status array is
> updated.
> 
> The status array contains a status indicating the result of the migration
> operation or the current state of the page if nodes == NULL.
> 
> Possible page states:
> 
> 0..MAX_NUMNODES		The page is now on the indicated node.
> 
> -ENOENT		Page is not present or target node is not present

So the caller has no way of distinguishing one case from the other? 
Perhaps it would be better to permit that.


> -EPERM		Page is mapped by multiple processes and can only
> 		be moved if MPOL_MF_MOVE_ALL is specified. Or the
> 		target node is not allowed by the current cpuset.
> 		Or the page has been mlocked by a process/driver and
> 		cannot be moved.
> 
> -EBUSY		Page is busy and cannot be moved. Try again later.
> 
> -EFAULT		Cannot read node information from node array.
> 
> -ENOMEM		Unable to allocate memory on target node.
> 
> -EIO		Unable to write back page. Page must be written
> 		back since the page is dirty and the filesystem does not
> 		provide a migration function.
> 
> -EINVAL		Filesystem does not provide a migration function but also
> 		has no ability to write back pages.

OK, the mapping from sys_move_pages() semantics onto errnos is reasonably
close.

But it still feels a bit kludgy to me.  Perhaps it would be nicer to define
a specific set of return codes for this application.

> 
> Test program for this may be found with the patches
> on ftp.kernel.org:/pub/linux/kernel/people/christoph/pmig/patches-2.6.17-rc4-mm1

The syscall is ia64-only at present.  And that's OK, but if anyone has an
interest in page migration on other architectures (damn well hope so) then
let's hope they wire the syscall up and get onto it..

> +/*
> + * Move a list of pages in the address space of the currently executing
> + * process.
> + */
> +asmlinkage long sys_move_pages(int pid, unsigned long nr_pages,
> +			const unsigned long __user *pages,
> +			const int __user *nodes,
> +			int __user *status, int flags)
> +{

I expect this is going to be a bitch to write compat emulation for.  If we
want to support this syscall for 32-bit userspace.

If there's any possibility of that then perhaps we should revisit these
types, see if we can design this syscall so that it doesn't need a compat
wrapper.

The `status' array should be char*, surely?

> +	int err = 0;
> +	int i;
> +	struct task_struct *task;
> +	nodemask_t task_nodes;
> +	struct mm_struct *mm;
> +	struct page_to_node *pm = NULL;
> +	LIST_HEAD(pagelist);
> +
> +	/* Check flags */
> +	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
> +		return -EINVAL;
> +
> +	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
> +		return -EPERM;
> +
> +	/* Find the mm_struct */
> +	read_lock(&tasklist_lock);
> +	task = pid ? find_task_by_pid(pid) : current;
> +	if (!task) {
> +		read_unlock(&tasklist_lock);
> +		return -ESRCH;
> +	}
> +	mm = get_task_mm(task);
> +	read_unlock(&tasklist_lock);
> +
> +	if (!mm)
> +		return -EINVAL;
> +
> +	/*
> +	 * Check if this process has the right to modify the specified
> +	 * process. The right exists if the process has administrative
> +	 * capabilities, superuser privileges or the same
> +	 * userid as the target process.
> +	 */
> +	if ((current->euid != task->suid) && (current->euid != task->uid) &&
> +	    (current->uid != task->suid) && (current->uid != task->uid) &&
> +	    !capable(CAP_SYS_NICE)) {
> +		err = -EPERM;
> +		goto out2;
> +	}

We have code which looks very much like this in maybe five or more places. 
Someone should fix it ;)

> +	task_nodes = cpuset_mems_allowed(task);
> +	pm = kmalloc(GFP_KERNEL, (nr_pages + 1) * sizeof(struct page_to_node));

A horrid bug.  If userspace passes in a sufficiently large nr_pages, the
multiplication will overflow and we'll allocate far too little memory and
we'll proceed to scrog kernel memory.

(OK, that's what would happen if you'd got the kmalloc args the correct way
around.  As it stands, heaven knows what it'll do ;))

> +	if (!pm) {
> +		err = -ENOMEM;
> +		goto out2;
> +	}
> +
> +	down_read(&mm->mmap_sem);
> +
> +	for(i = 0 ; i < nr_pages; i++) {

I really should write a fix-common-whitespace-mistakes script.

> +		unsigned long addr;
> +		int node;
> +		struct vm_area_struct *vma;
> +		struct page *page;
> +
> +		pm[i].page = ZERO_PAGE(0);
> +
> +		err = -EFAULT;
> +		if (get_user(addr, pages + i))
> +			goto putback;

No, we cannot run get_user() inside down_read(mmap_sem).  Because that ends
up taking mmap_sem recursively and an intervening down_write() from another
process will deadlock the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
