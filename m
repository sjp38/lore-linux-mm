Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B26856B0044
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 06:08:26 -0500 (EST)
Message-ID: <494A2F94.2090800@cs.columbia.edu>
Date: Thu, 18 Dec 2008 06:10:12 -0500
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v11][PATCH 05/13] Dump memory address space
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu> <1228498282-11804-6-git-send-email-orenl@cs.columbia.edu> <4949B4ED.9060805@google.com>
In-Reply-To: <4949B4ED.9060805@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mike Waychison <mikew@google.com>
Cc: jeremy@goop.org, arnd@arndb.de, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Linux Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



Mike Waychison wrote:
> Comments below.

Thanks for the detailed review.

> 
> Oren Laadan wrote:
>> For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
>> it will be followed by the file name. Then comes the actual contents,
>> in one or more chunk: each chunk begins with a header that specifies
>> how many pages it holds, then the virtual addresses of all the dumped
>> pages in that chunk, followed by the actual contents of all dumped
>> pages. A header with zero number of pages marks the end of the contents.
>> Then comes the next VMA and so on.
>>

[...]

>> +    mutex_lock(&mm->context.lock);
>> +
>> +    hh->ldt_entry_size = LDT_ENTRY_SIZE;
>> +    hh->nldt = mm->context.size;
>> +
>> +    cr_debug("nldt %d\n", hh->nldt);
>> +
>> +    ret = cr_write_obj(ctx, &h, hh);
>> +    cr_hbuf_put(ctx, sizeof(*hh));
>> +    if (ret < 0)
>> +        goto out;
>> +
>> +    ret = cr_kwrite(ctx, mm->context.ldt,
>> +            mm->context.size * LDT_ENTRY_SIZE);
> 
> Do we really want to emit anything under lock?  I realize that this
> patch goes and does a ton of writes with mmap_sem held for read -- is
> this ok?

Because all tasks in the container must be frozen during the checkpoint,
there is no performance penalty for keeping the locks. Although the object
should not change in the interim anyways, the locks protects us from, e.g.
the task unfreezing somehow, or being killed by the OOM killer, or any
other change incurred from the "outside world" (even future code).

Put in other words - in the long run it is safer to assume that the
underlying object may otherwise change.

(If we want to drop the lock here before cr_kwrite(), we need to copy the
data to a temporary buffer first. If we also want to drop mmap_sem(), we
need to be more careful with following the vma's.)

Do you see a reason to not keeping the locks ?

>> +
>> + out:
>> +    mutex_unlock(&mm->context.lock);
>> +    return ret;
>> +}

[...]

>> +static int cr_ctx_checkpoint(struct cr_ctx *ctx, pid_t pid)
>> +{
>> +    struct fs_struct *fs;
>> +
>> +    ctx->root_pid = pid;
>> +
>> +    /*
>> +     * assume checkpointer is in container's root vfs
>> +     * FIXME: this works for now, but will change with real containers
>> +     */
>> +
>> +    fs = current->fs;
>> +    read_lock(&fs->lock);
>> +    ctx->fs_mnt = fs->root;
>> +    path_get(&ctx->fs_mnt);
>> +    read_unlock(&fs->lock);
>> +
>> +    return 0;
> 
> Spurious return value?

In a later patch (10/13: External checkpoint of a task other than ourself)
it becomes more useful.

> 
>> +}
>> +

[...]

>> +/*
>> + * utilities to alloc, free, and handle 'struct cr_pgarr' (page-arrays)
>> + * (common to ckpt_mem.c and rstr_mem.c).
>> + *
>> + * The checkpoint context structure has two members for page-arrays:
>> + *   ctx->pgarr_list: list head of the page-array chain
> 
> What's the second member?

Duh... will update text.

> 

[...]

>> +    for (i = pgarr->nr_used; i--; /**/)
>> +        page_cache_release(pgarr->pages[i]);
> 
> This is sorta hard to read (and non-intuitive).  Is it easier to do:
> 
> 
> for (i = 0; i < pgarr->nr_used; i++)
>     page_cache_release(pgarr->pages[i]);
> 
> 
> It shouldn't matter what order you release the pages in..

Was meant to avoid a dereference to 'pgarr->nr_used' in the comparison.
(though I doubt if the performance impact is at all visible)

[...]

>> +/* allocate a single page-array object */
>> +static struct cr_pgarr *cr_pgarr_alloc_one(unsigned long flags)
>> +{
>> +    struct cr_pgarr *pgarr;
>> +
>> +    pgarr = kzalloc(sizeof(*pgarr), GFP_KERNEL);
>> +    if (!pgarr)
>> +        return NULL;
>> +
>> +    pgarr->vaddrs = kmalloc(CR_PGARR_TOTAL * sizeof(unsigned long),
> You used PAGE_SIZE / sizeof(void *) above.   Why not __get_free_page()?

Hahaha .. well, it's a guaranteed method to keep Dave Hansen from
barking about not using kmalloc ...

Personally I prefer __get_free_page() here, but not enough to keep
arguing with him. Let me know when the two of you settle it :)

> 
>> +                GFP_KERNEL);
>> +    if (!pgarr->vaddrs)
>> +        goto nomem;

[...]

>> +/* reset the page-array chain (dropping page references if necessary) */
>> +void cr_pgarr_reset_all(struct cr_ctx *ctx)
>> +{
>> +    struct cr_pgarr *pgarr;
>> +
>> +    list_for_each_entry(pgarr, &ctx->pgarr_list, list) {
>> +        cr_pgarr_release_pages(pgarr);
>> +        pgarr->nr_used = 0;
>> +    }
> 
> This doesn't look right.  cr_pgarr_current only ever looks at the head
> of the list, so resetting a list with > 1 pgarr on it will mean the
> non-head elements in the list will go to waste.

You're correct.
(the code is from a cleanup suggested to v4 and incorporated into v5).

> 
>> +}
>> +
>> +/*
>> + * Checkpoint is outside the context of the checkpointee, so one cannot
>> + * simply read pages from user-space. Instead, we scan the address space
>> + * of the target to cherry-pick pages of interest. Selected pages are
>> + * enlisted in a page-array chain (attached to the checkpoint context).
>> + * To save their contents, each page is mapped to kernel memory and then
>> + * dumped to the file descriptor.
>> + */
>> +
>> +
>> +/**
>> + * cr_private_follow_page - return page pointer for dirty pages
>> + * @vma - target vma
>> + * @addr - page address
>> + *
>> + * Looks up the page that correspond to the address in the vma, and
>> + * returns the page if it was modified (and grabs a reference to it),
>> + * or otherwise returns NULL (or error).
>> + *
>> + * This function should _only_ called for private vma's.
>> + */
>> +static struct page *
>> +cr_private_follow_page(struct vm_area_struct *vma, unsigned long addr)
> 
> s/cr_private_follow_page/cr_follow_page_private/ ?
> 

ok.

> Maybe even cr_dump_private_page?  The fact that it's following the page
>  tables down to the page is an implementation artifact and isn't really
> relevant to the semantics you want to express.

Except that we don't dump the page there - we follow the page tables and
decide whether we add it to the list of scanned pages. But, ok, we can
also do cr_consider_page_private() (or examine, or scan ..)

> 
>> +{
>> +    struct page *page;
>> +
>> +    BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
>> +
> 
> This BUG_ON shouldn't be needed if it's already done in
> cr_private_vma_fill_pgarr.
> 

Leftover, will remove.

>> +    /*

[...]

>> +    } else if (vma->vm_file && (page_mapping(page) != NULL)) {
>> +        /* file backed clean cow: ignore */
> 
> Probably better to describe 'why' it can be ignored here.

ok.

>> +        page_cache_release(page);
>> +        page = NULL;
>> +    }
>> +
>> +    return page;
>> +}
>> +
>> +/**
>> + * cr_private_vma_fill_pgarr - fill a page-array with addr/page tuples
>> + * @ctx - checkpoint context
>> + * @pgarr - page-array to fill
>> + * @vma - vma to scan
>> + * @start - start address (updated)
>> + *
>> + * Returns the number of pages collected
>> + */
>> +static int
>> +cr_private_vma_fill_pgarr(struct cr_ctx *ctx, struct cr_pgarr *pgarr,
>> +              struct vm_area_struct *vma, unsigned long *start)
> 
> This is sorta nasty because you shouldn't need to call into this routine
> with a container.  It should be able to enqueue the (vaddr, page) tuple
> directly on the ctx.  Doing so would also abstract out the pgarr
> management at this level and make the code a lot simpler.
> 

Yes, @pgarr can be abstracted inside here.

>> +{
>> +    unsigned long end = vma->vm_end;
>> +    unsigned long addr = *start;
>> +    int orig_used = pgarr->nr_used;
>> +
>> +    /* this function is only for private memory (anon or file-mapped) */
>> +    BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
>> +
>> +    while (addr < end) {
>> +        struct page *page;
>> +
>> +        page = cr_private_follow_page(vma, addr);
>> +        if (IS_ERR(page))
>> +            return PTR_ERR(page);
>> +
>> +        if (page) {
>> +            pgarr->pages[pgarr->nr_used] = page;
>> +            pgarr->vaddrs[pgarr->nr_used] = addr;
>> +            pgarr->nr_used++;
> 
> Should be something like:
> 
> ret = cr_ctx_append_page(ctx, addr, page);
> if (ret < 0)
>   goto out;

My concern here is performance: keeping track of @pgarr avoids the
reference through ctx. We may loop over MBs of memory, tens of
thousands of pages, in individual VMAs.

>> +        }

[...]

>> +
>> +    buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
> 
> __get_free_page()

lol... gonna run an experiment and change this one (Dave's main
argument regarding better "debugability" of kmalloc() doesn't
hold here anyways !).

>> +    if (!buf)
>> +        return -ENOMEM;

[...]

>> +#define CR_BAD_VM_FLAGS  \
>> +    (VM_SHARED | VM_MAYSHARE | VM_IO | VM_HUGETLB | VM_NONLINEAR)
>> +
>> +    if (vma->vm_flags & CR_BAD_VM_FLAGS) {
>> +        pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
>> +        cr_hbuf_put(ctx, sizeof(*hh));
>> +        return -ENOSYS;
>> +    }
>> +
> 
> The following code should be broken into it's own function?  Handling of
> other types of memory will follow and will clutter this guy up.
> 

I deferred this until I add those "other types".

>> +    /* by default assume anon memory */
>> +    vma_type = CR_VMA_ANON;

[...]

>> +    if (vma->vm_file) {
>> +        ret = cr_write_fname(ctx, &vma->vm_file->f_path, &ctx->fs_mnt);
> 
> Why is this using a filename, rather than a reference to a file?

Could be a reference to a file, but it isn't strictly necessary (*) and it
won't improve performance that much. won't gain that much.

Not necessary: open files may be shared and then we _must_ use the same file
pointer. In contrast, with memory mapping only needs _an_ open file.
Won't gain much: because file pointers of mapped regions are usually only
shared in the case of fork() without a following exec().

(*) It is strictly necessary when it comes to handling shared memory.

So I left this optimization for later.

> Shouldn't this use the logic in patch 8/13?

Yes. But need to make sure (especially on the restart side) to consider the
exceptions - e.g. a file in SHMFS used for anonymous shared memory, etc.

So yes, I'll add a FIXME comment there.

> 
>> +        if (ret < 0)
>> +            return ret;
>> +    }

[...]

>> +enum vm_type {
>> +    CR_VMA_ANON = 1,
>> +    CR_VMA_FILE
> 
> We need to figure out what MAP_SHARED | MAP_ANONYMOUS should be exposed
> as in this setup (much in the same way we need to start defining what
> shm mappings look like).  Internally, they are 'file-backed', but to
> userland, they aren't.
> 
> 
> Thoughts?

Eventually we'll have CR_VMA_ANON_SHM, CR_VMA_FILE_SHM, CR_VMA_IPC_SHM,
to identify the vma type. There will also be a flag "skip" that says that
the actual contents of the memory has already been copied earlier. (And,
for completeness, a flags "xfile" which indicated that the referenced
file is unlinked, in the case of CR_VMA_FILE and CR_VMA_FILE_SHM).

It's not a lot of work, only that I'm actually holding back on adding
more features, and focus on getting this into -mm tree first. I don't
want to write lots of code and then modify it again and again...

> 
>> +};
>> +
>> +struct cr_hdr_vma {
>> +    __u32 vma_type;
>> +    __u32 _padding;
> 
> Why padding?

For 64 bit architectures. See this threads:
https://lists.linux-foundation.org/pipermail/containers/2008-August/012318.html

Quoting Arnd Bergmann:
  "This structure has an odd multiple of 32-bit members, which means
  that if you put it into a larger structure that also contains
  64-bit members, the larger structure may get different alignment
  on x86-32 and x86-64, which you might want to avoid.
  I can't tell if this is an actual problem here.
  ...
  ...
  In this case, I'm pretty sure that sizeof(cr_hdr_task) on x86-32 is
  different from x86-64, since it will be 32-bit aligned on x86-32."

>> +
>> +    __u64 vm_start;
>> +    __u64 vm_end;
>> +    __u64 vm_page_prot;
>> +    __u64 vm_flags;
>> +    __u64 vm_pgoff;
>> +} __attribute__((aligned(8)));
>> +
>> +struct cr_hdr_pgarr {
>> +    __u64 nr_pages;        /* number of pages to saved */
>> +} __attribute__((aligned(8)));
>> +
>>  #endif /* _CHECKPOINT_CKPT_HDR_H_ */

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
