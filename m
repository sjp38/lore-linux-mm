Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id A7E806B003A
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 15:26:07 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id c9so3263575qcz.0
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 12:26:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c9si7729414qan.32.2014.08.12.12.26.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Aug 2014 12:26:06 -0700 (PDT)
Date: Tue, 12 Aug 2014 14:55:44 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 3/3] mm/hugetlb: add migration entry check in
 hugetlb_change_protection
Message-ID: <20140812185544.GC8975@nhori.bos.redhat.com>
References: <1406914663-8631-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1406914663-8631-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.LSU.2.11.1408091611150.15311@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1408091611150.15311@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Sat, Aug 09, 2014 at 04:12:09PM -0700, Hugh Dickins wrote:
> On Fri, 1 Aug 2014, Naoya Horiguchi wrote:
> 
> > There is a race condition between hugepage migration and change_protection(),
> > where hugetlb_change_protection() doesn't care about migration entries and
> > wrongly overwrites them. That causes unexpected results like kernel crash.
> > 
> > This patch adds is_hugetlb_entry_(migration|hwpoisoned) check in this
> > function and skip all such entries.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: <stable@vger.kernel.org>  # [3.12+]
> > ---
> >  mm/hugetlb.c | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> > 
> > diff --git mmotm-2014-07-22-15-58.orig/mm/hugetlb.c mmotm-2014-07-22-15-58/mm/hugetlb.c
> > index 863f45f63cd5..1da7ca2e2a02 100644
> > --- mmotm-2014-07-22-15-58.orig/mm/hugetlb.c
> > +++ mmotm-2014-07-22-15-58/mm/hugetlb.c
> > @@ -3355,7 +3355,13 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
> >  			spin_unlock(ptl);
> >  			continue;
> >  		}
> > -		if (!huge_pte_none(huge_ptep_get(ptep))) {
> > +		pte = huge_ptep_get(ptep);
> > +		if (unlikely(is_hugetlb_entry_migration(pte) ||
> > +			     is_hugetlb_entry_hwpoisoned(pte))) {
> 
> Another instance of this pattern.  Oh well, perhaps we have to continue
> this way while backporting fixes, but the repetition irritates me.

Yes, I thought about the repetition too, so at some point (hopefully
in this patchset?) it would be nice to fix up all the similar code.

> Or use is_swap_pte() as follow_hugetlb_page() does?
>
> More importantly, the regular change_pte_range() has to
> make_migration_entry_read() if is_migration_entry_write():
> why is that not necessary here?

It's necessary for migration entry. For hwpoison entry, just unlocking is ok.
(I focused on avoiding bug and thought not enough about proper fixing, sorry.)

> And have you compared hugetlb codepaths with normal codepaths, to see
> if there are other huge places which need to check for a migration entry
> now?  If you have checked, please reassure us in the commit message:
> we would prefer not to have these fixes coming in one by one.

I've not checked all hugetlb codepaths, so will do this.
(for example free_pgtables() may need a check of migration pmd entry.)

> (I first thought __unmap_hugepage_range() would need it, but since
> zap_pte_range() only checks it for rss stats, and hugetlb does not
> participate in rss stats, it looks like no need.)

You catch the point. I thought that is_hugetlb_entry_migration() check
is necessary in __unmap_hugepage_range(), but didn't include it in this
patch just because it's not related to this specific problem.
But it's an inefficient manner of kernel development, so I'll include
it in the next version.

Thanks,
Naoya Horiguchi

> Hugh
> 
> > +			spin_unlock(ptl);
> > +			continue;
> > +		}
> > +		if (!huge_pte_none(pte)) {
> >  			pte = huge_ptep_get_and_clear(mm, address, ptep);
> >  			pte = pte_mkhuge(huge_pte_modify(pte, newprot));
> >  			pte = arch_make_huge_pte(pte, vma, NULL, 0);
> > -- 
> > 1.9.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
