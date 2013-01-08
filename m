Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 3112F6B005A
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 12:37:52 -0500 (EST)
Date: Tue, 8 Jan 2013 18:37:47 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: oops in copy_page_rep()
Message-ID: <20130108173747.GF9163@redhat.com>
References: <20130105152208.GA3386@redhat.com>
 <CAJd=RBCb0oheRnVCM4okVKFvKGzuLp9GpZJCkVY3RR-J=XEoBA@mail.gmail.com>
 <alpine.LNX.2.00.1301061037140.28950@eggly.anvils>
 <CAJd=RBAps4Qk9WLYbQhLkJd8d12NLV0CbjPYC6uqH_-L+Vu0VQ@mail.gmail.com>
 <CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com>
 <CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com>
 <CA+55aFzfUABPycR82aNQhHNasQkL1kmxLN1rD0DJcByFtead3g@mail.gmail.com>
 <20130108163141.GA27555@shutemov.name>
 <CA+55aFzaTvF7nYxWBT-G_b=xGz+_akRAeJ=U9iHy+Y=ZPo=pbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzaTvF7nYxWBT-G_b=xGz+_akRAeJ=U9iHy+Y=ZPo=pbA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

Hi,

On Tue, Jan 08, 2013 at 08:52:14AM -0800, Linus Torvalds wrote:
> On Tue, Jan 8, 2013 at 8:31 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> >>
> >> Heh. I was more thinking about why do_huge_pmd_wp_page() needs it, but
> >> do_huge_pmd_numa_page() does not.
> >
> > It does. The check should be moved up.
> >
> >> Also, do we actually need it for huge_pmd_set_accessed()? The
> >> *placement* of that thing confuses me. And because it confuses me, I'd
> >> like to understand it.
> >
> > We need it for huge_pmd_set_accessed() too.
> >
> > Looks like a mis-merge. The original patch for huge_pmd_set_accessed() was
> > correct: http://lkml.org/lkml/2012/10/25/402
> 
> Not a merge error: the pmd_trans_splitting() check was removed by
> commit d10e63f29488 ("mm: numa: Create basic numa page hinting
> infrastructure").
> 
> Now, *why* it was removed, I can't tell. And it's not clear why the
> original code just had it in a conditional, while the suggested patch
> has that "goto repeat" thing. I suspect re-trying the fault (which I
> assume the original code did) is actually better, because that way you
> go through all the "should I reschedule as I return through the
> exception" stuff. I dunno.

The reason it returned to userland and retried the fault is that this
should be infrequent enough not to worry about it and this was
marginally simpler but it could be changed.

If we don't want to return to userland we should wait on the splitting
bit and then take the pte walking routines like if the pmd wasn't
huge. This is not related to the below though.

> Mel, that original patch came from you , although it was based on
> previous work by Peter/Ingo/Andrea. Can you walk us through the
> history and thinking about the loss of pmd_trans_splitting(). Was it
> purely a mistake? It looks intentional.

d10e63f29488 is wrong in removing the pmd_splitting check, I assume
it's an accidental leftover.

My code did this:

@@ -3530,6 +3534,9 @@ retry:
                 */
                orig_pmd = ACCESS_ONCE(*pmd);
                if (pmd_trans_huge(orig_pmd)) {
+                       if (pmd_numa(*pmd))
+                               return huge_pmd_numa_fixup(mm, address,
+                                                          orig_pmd, pmd);
                        if (flags & FAULT_FLAG_WRITE &&
                            !pmd_write(orig_pmd) &&
                            !pmd_trans_splitting(orig_pmd)) {

The function I was calling was this:

+#ifdef CONFIG_AUTONUMA
+/* NUMA hinting page fault entry point for trans huge pmds */
+int huge_pmd_numa_fixup(struct mm_struct *mm, unsigned long addr,
+                       pmd_t pmd, pmd_t *pmdp)
+{
+       struct page *page;
+       bool migrated;
+
+       spin_lock(&mm->page_table_lock);
+       if (unlikely(!pmd_same(pmd, *pmdp)))
+               goto out_unlock;
+
+       page = pmd_page(pmd);
+       pmd = pmd_mknonnuma(pmd);
+       set_pmd_at(mm, addr & HPAGE_PMD_MASK, pmdp, pmd);
+       VM_BUG_ON(pmd_numa(*pmdp));
+       if (unlikely(page_mapcount(page) != 1))
+               goto out_unlock;
+       get_page(page);
+       spin_unlock(&mm->page_table_lock);
+
+       migrated = numa_hinting_fault(page, HPAGE_PMD_NR);
+       if (!migrated)
+               put_page(page);
+
+out:
+       return 0;
+
+out_unlock:
+       spin_unlock(&mm->page_table_lock);
+       goto out;
+}
+#endif

Taking the PT lock, checking pmd_same and clearing the numa bitflag
was perfectly ok even if the pmd was in splitting state the whole
time.

However do_huge_pmd_numa_page is slightly more complex than the above:
the problem is that migrate_misplaced_transhuge_page gets pmdp and pmd
as parameters (unlike the above numa_hinting_fault() function) and it
relies internally to pmd_same too.

	/* Recheck the target PMD */
	spin_lock(&mm->page_table_lock);
	if (unlikely(!pmd_same(*pmd, entry))) {
		spin_unlock(&mm->page_table_lock);
        [..]
	entry = mk_pmd(new_page, vma->vm_page_prot);
	entry = pmd_mknonnuma(entry);
	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
	entry = pmd_mkhuge(entry);

	page_add_new_anon_rmap(new_page, vma, haddr);

	set_pmd_at(mm, haddr, pmd, entry);

And this kind of mangling isn't ok if the pmd was in splitting state
because split_huge_page won't expect the pmd to change (if the numa
bit changes is ok but the pfn cannot change or split_huge_page_map
will go wrong).

So you're right that if migrate_misplaced_transhuge_page will continue
to do the pmd_same check, we should add the pmd_splitting bit in
memory.c for the pmd_numa() path too.

Looking at this, one thing that isn't clear is where the page_count is
checked in migrate_misplaced_transhuge_page. Ok that it's unable to
migrate anon transhuge COW shared pages so it doesn't need to mess
with rmap (the mapcount check makes it safe), but it shouldn't be
allowed to migrate memory that has gup direct-IO in flight (and that
can only be detected with a page_count vs mapcount check). Real
migrate does page_freeze_refs to be safe. Mel comments?

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
