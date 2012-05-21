Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id DBA376B004D
	for <linux-mm@kvack.org>; Mon, 21 May 2012 17:37:05 -0400 (EDT)
Date: Mon, 21 May 2012 14:37:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [tip:perf/uprobes] uprobes, mm, x86: Add the ability to install
 and remove uprobes breakpoints
Message-Id: <20120521143701.74ab2d0b.akpm@linux-foundation.org>
In-Reply-To: <tip-2b144498350860b6ee9dc57ff27a93ad488de5dc@git.kernel.org>
References: <20120209092642.GE16600@linux.vnet.ibm.com>
	<tip-2b144498350860b6ee9dc57ff27a93ad488de5dc@git.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, a.p.zijlstra@chello.nl, torvalds@linux-foundation.org, peterz@infradead.org, anton@redhat.com, akpm@linux-foundation.org, rostedt@goodmis.org, tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hpa@zytor.com, jkenisto@us.ibm.com, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, vda.linux@googlemail.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, srikar@linux.vnet.ibm.com, sfr@canb.auug.org.au, roland@hack.frob.com, mingo@elte.hu
Cc: linux-tip-commits@vger.kernel.org

On Fri, 17 Feb 2012 01:58:36 -0800
tip-bot for Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:

> Commit-ID:  2b144498350860b6ee9dc57ff27a93ad488de5dc
> Gitweb:     http://git.kernel.org/tip/2b144498350860b6ee9dc57ff27a93ad488de5dc
> Author:     Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> AuthorDate: Thu, 9 Feb 2012 14:56:42 +0530
> Committer:  Ingo Molnar <mingo@elte.hu>
> CommitDate: Fri, 17 Feb 2012 10:00:01 +0100
> 
> uprobes, mm, x86: Add the ability to install and remove uprobes breakpoints

hm, we seem to have conflicting commits between mainline and linux-next.
During the merge window.  Again.  Nobody knows why this happens. 

static void unmap_single_vma(struct mmu_gather *tlb,
		struct vm_area_struct *vma, unsigned long start_addr,
		unsigned long end_addr,
		struct zap_details *details)
{
	unsigned long start = max(vma->vm_start, start_addr);
	unsigned long end;

	if (start >= vma->vm_end)
		return;
	end = min(vma->vm_end, end_addr);
	if (end <= vma->vm_start)
		return;

<<<<<<< HEAD
=======
	if (vma->vm_file)
		uprobe_munmap(vma, start, end);

	if (vma->vm_flags & VM_ACCOUNT)
		*nr_accounted += (end - start) >> PAGE_SHIFT;

>>>>>>> linux-next/akpm-base
	if (unlikely(is_pfn_mapping(vma)))
		untrack_pfn_vma(vma, 0, 0);


It made me look at uprobes.  Noticed a few things...


> Add uprobes support to the core kernel, with x86 support.
> 
> ...
>
> +static struct rb_root uprobes_tree = RB_ROOT;
> +static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize rbtree access */
> +
> +#define UPROBES_HASH_SZ	13
> +/* serialize (un)register */
> +static struct mutex uprobes_mutex[UPROBES_HASH_SZ];
> +#define uprobes_hash(v)	(&uprobes_mutex[((unsigned long)(v)) %\
> +						UPROBES_HASH_SZ])
> +
> +/* serialize uprobe->pending_list */
> +static struct mutex uprobes_mmap_mutex[UPROBES_HASH_SZ];
> +#define uprobes_mmap_hash(v)	(&uprobes_mmap_mutex[((unsigned long)(v)) %\
> +						UPROBES_HASH_SZ])

Presumably these locks were hashed for scalability reasons?

If so, this won't be terribly effective when we have multiple mutexes
occupying a single cacheline - the array entries should be padded out.
Of course, that's all a complete waste of space on uniprocessor
machines, but nobody seems to think of that any more ;(

There was no need to code the accessor functions as macros.  It is, as
always, better to use a nice C function which takes an argument which
is as strictly typed as possible.  ie, it *could* take a void*, but it
would be better if it required an inode*.

If that makes no difference in performance testing then probably we
didn't need to hash it at all and we can go to a single lock and be
nice to uniprocessor.

>
> ...
>
> +static int read_opcode(struct mm_struct *mm, unsigned long vaddr,
> +						uprobe_opcode_t *opcode)
> +{
> +	struct page *page;
> +	void *vaddr_new;
> +	int ret;
> +
> +	ret = get_user_pages(NULL, mm, vaddr, 1, 0, 0, &page, NULL);
> +	if (ret <= 0)
> +		return ret;
> +
> +	lock_page(page);
> +	vaddr_new = kmap_atomic(page);
> +	vaddr &= ~PAGE_MASK;
> +	memcpy(opcode, vaddr_new + vaddr, uprobe_opcode_sz);
> +	kunmap_atomic(vaddr_new);

This is modifying user memory?  flush_dcache_page() needed?  Or perhaps
we will need different primitives to diddle the instruction memory on
architectures which care.


> +	unlock_page(page);
> +	put_page(page);		/* we did a get_user_pages in the beginning */
> +	return 0;
> +}
> +
>
> ...
>
> +int mmap_uprobe(struct vm_area_struct *vma)
> +{
> +	struct list_head tmp_list;
> +	struct uprobe *uprobe, *u;
> +	struct inode *inode;
> +	int ret = 0;
> +
> +	if (!atomic_read(&uprobe_events) || !valid_vma(vma, true))
> +		return ret;	/* Bail-out */
> +
> +	inode = vma->vm_file->f_mapping->host;
> +	if (!inode)
> +		return ret;
> +
> +	INIT_LIST_HEAD(&tmp_list);
> +	mutex_lock(uprobes_mmap_hash(inode));
> +	build_probe_list(inode, &tmp_list);
> +	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
> +		loff_t vaddr;
> +
> +		list_del(&uprobe->pending_list);
> +		if (!ret) {
> +			vaddr = vma_address(vma, uprobe->offset);
> +			if (vaddr < vma->vm_start || vaddr >= vma->vm_end) {
> +				put_uprobe(uprobe);
> +				continue;
> +			}
> +			ret = install_breakpoint(vma->vm_mm, uprobe, vma,
> +								vaddr);
> +			if (ret == -EEXIST)
> +				ret = 0;

This now has the comment "Ignore double add:".  That is a poor
comment, because it doesn't tell us *why* a double-add is ignored.

> +		}
> +		put_uprobe(uprobe);
> +	}
> +
> +	mutex_unlock(uprobes_mmap_hash(inode));
> +
> +	return ret;
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
