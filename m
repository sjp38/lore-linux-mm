Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CEB0C6B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 01:06:34 -0400 (EDT)
Date: Thu, 4 Jun 2009 07:13:46 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v5
Message-ID: <20090604051346.GM1065@one.firstfloor.org>
References: <20090603846.816684333@firstfloor.org> <20090603184648.2E2131D028F@basil.firstfloor.org> <20090604032441.GC5740@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604032441.GC5740@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "npiggin@suse.de" <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 11:24:41AM +0800, Wu Fengguang wrote:
> On Thu, Jun 04, 2009 at 02:46:47AM +0800, Andi Kleen wrote:
> 
> [snip]
> 
> This patch is full of this style error (the old version didn't have
> this problem though):

I don't see that here. At least nothing new compared to old.

> 
>         ERROR: code indent should use tabs where possible

It's checkpath clean for me, except for a few > 80 lines on printks,
one list_for_each_entry_safe (which I think checkpatch is wrong on) and
the meminfo comma error which I also think checkpath.pl is wrong on too.

> > +               page_cache_release(p);
> > +
> > +       /*
> > +        * Now truncate the page in the page cache. This is really
> > +        * more like a "temporary hole punch"
> > +        * Don't do this for block devices when someone else
> > +        * has a reference, because it could be file system metadata
> > +        * and that's not safe to truncate.
> > +        */
> > +       mapping = page_mapping(p);
> > +       if (mapping && S_ISBLK(mapping->host->i_mode) && page_count(p) > 1) {
> 
> Shall use (page_count > 2) to count for the page cache reference.

I think the page cache reference got dropped in

	  if (!isolate_lru_page(p))
                page_cache_release(p);

So it should be only one if there are no other users

> Or can we base the test on busy buffers instead of page count?  Nick?

At least the S_ISBLK test is the best one I came up with. I'm not 
saying it's the absolutely best.

> > +       SetPageError(p);
> > +       /* TBD: print more information about the file. */
> > +       if (mapping) {
> > +               /*
> > +                * IO error will be reported by write(), fsync(), etc.
> > +                * who check the mapping.
> 
> btw, here are some side notes on EIO.
> 
> close() *may* also report it. NFS will sync file on close.

I think the comment is already too verbose, sure there are other
details too that it doesn't describe. It's not trying to be a
full reference on linux error reporting. So I prefer to not
add more cases.

> > +                * at the wrong time.
> > +                *
> > +                * So right now we assume that the application DTRT on
> 
> DTRT = do the return value test?

Do The Right Thing

> > +};
> > +
> > +static void action_result(unsigned long pfn, char *msg, int ret)
> 
> rename 'ret' to 'action'?

But's not an action (as in a page state handler), it's a return value?
(RECOVERED, FAILED etc.) I can name it result.

> > +        * need this to decide if we should kill or just drop the page.
> > +        */
> > +       mapping = page_mapping(p);
> > +       if (!PageDirty(p) && !PageAnon(p) && !PageSwapBacked(p) &&
> 
> !PageAnon(p) could be removed: the below non-zero mapping check will
> do the work implicitly.

You mean !page_mapped?  Ok.

> > +                       kill = 0;
> > +                       printk(KERN_INFO
> > +       "MCE %#lx: corrupted page was clean: dropped without side effects\n",
> > +                               pfn);
> > +                       ttu |= TTU_IGNORE_HWPOISON;
> 
> Why not put the two assignment lines together? :)

Ok. But that was your patch @)

> > +        * Try a few times (RED-PEN better strategy?)
> > +        */
> > +       for (i = 0; i < N_UNMAP_TRIES; i++) {
> > +               ret = try_to_unmap(p, ttu);
> > +               if (ret == SWAP_SUCCESS)
> > +                       break;
> > +               pr_debug("MCE %#lx: try_to_unmap retry needed %d\n", pfn,  ret);
> 
> Can we make it a printk? This is a serious accident.

I think it can actually happen due to races, e.g. when a remap
is currently in process.

> > +        */
> > +       hwpoison_user_mappings(p, pfn, trapno);
> > +
> > +       /*
> > +        * Torn down by someone else?
> > +        */
> > +       if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
> > +               action_result(pfn, "already unmapped LRU", IGNORED);
> 
> "NULL mapping LRU" or "already truncated page"?
> At least page_mapped != page_mapping.

It's "already truncated" now.

> > @@ -1311,6 +1311,20 @@
> >                 .mode           = 0644,
> >                 .proc_handler   = &scan_unevictable_handler,
> >         },
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +       {
> > +               .ctl_name       = CTL_UNNUMBERED,
> > +               .procname       = "memory_failure_early_kill",
> > +               .data           = &sysctl_memory_failure_early_kill,
> > +               .maxlen         = sizeof(vm_highmem_is_dirtyable),
> 
> s/vm_highmem_is_dirtyable/sysctl_memory_failure_early_kill/

Fixed thanks.

> >   * Documentation/sysctl/ctl_unnumbered.txt
> > Index: linux/fs/proc/meminfo.c
> > ===================================================================
> > --- linux.orig/fs/proc/meminfo.c        2009-06-03 19:37:38.000000000 +0200
> > +++ linux/fs/proc/meminfo.c     2009-06-03 20:13:43.000000000 +0200
> > @@ -95,7 +95,11 @@
> >                 "Committed_AS:   %8lu kB\n"
> >                 "VmallocTotal:   %8lu kB\n"
> >                 "VmallocUsed:    %8lu kB\n"
> > -               "VmallocChunk:   %8lu kB\n",
> > +               "VmallocChunk:   %8lu kB\n"
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +               "BadPages:       %8lu kB\n"
> 
> "HWPoison:" or something like that? 
> People is more likely to misinterpret "BadPages".

I'll name it HardwareCorrupted. That makes it too long, but it's hopefully
clearer.

> >                 vmi.used >> 10,
> >                 vmi.largest_chunk >> 10
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +               ,atomic_long_read(&mce_bad_pages) << (PAGE_SHIFT - 10)
> 
> ERROR: space required after that ','

That's one of the cases where checkpatch.pl is stupid. The lone comma
with a space looks absolutely ridiculous to me. I refuse to do ridiculous
things things just for checkpatch.pl deficiencies.

> >           Enable the KSM kernel module to allow page sharing of equal pages
> >           among different tasks.
> > 
> > +config MEMORY_FAILURE
> > +       bool
> > +
> 
> Do we have code to automatically enable/disable CONFIG_MEMORY_FAILURE
> based on hardware capability?

Yes the architecture can enable it. There's also another patch
which always enables it for testing.

> > +
> > +Control how to kill processes when uncorrected memory error (typically
> > +a 2bit error in a memory module) is detected in the background by hardware.
> > +
> > +1: Kill all processes that have the corrupted page mapped as soon as the
> > +corruption is detected.
> > +
> > +0: Only unmap the page from all processes and only kill a process
> > +who tries to access it.
> 
> Note that
> - no process will be killed if the page data is clean and can be
>   safely reloaded from disk
> - pages in swap cache is always late killed.

I clarified that

Thanks,
-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
