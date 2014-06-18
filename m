Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 701A66B0038
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 11:31:55 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id x13so1018610wgg.3
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 08:31:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id by5si3380073wjc.114.2014.06.18.08.31.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jun 2014 08:31:53 -0700 (PDT)
Date: Wed, 18 Jun 2014 11:31:45 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mm v2 04/11] pagewalk: move pmd_trans_huge_lock() from
 callbacks to common code
Message-ID: <20140618153145.GA26866@nhori>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1402609691-13950-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <53A0506C.6040609@redhat.com>
 <20140617150159.GA8524@nhori.redhat.com>
 <53A1ACB1.3050102@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53A1ACB1.3050102@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On Wed, Jun 18, 2014 at 05:13:53PM +0200, Jerome Marchand wrote:
> On 06/17/2014 05:01 PM, Naoya Horiguchi wrote:
> > On Tue, Jun 17, 2014 at 04:27:56PM +0200, Jerome Marchand wrote:
> >> On 06/12/2014 11:48 PM, Naoya Horiguchi wrote:
> >>> Now all of current users of page table walker are canonicalized, i.e.
> >>> pmd_entry() handles only trans_pmd entry, and pte_entry() handles pte entry.
> >>> So we can factorize common code more.
> >>> This patch moves pmd_trans_huge_lock() in each pmd_entry() to pagewalk core.
> >>>
> >>> ChangeLog v2:
> >>> - add null check walk->vma in walk_pmd_range()
> >>
> >> An older version of this patch already made it to linux-next (commit
> >> b0e08c5) and I've actually hit the NULL pointer dereference.
> >>
> >> Moreover, that patch (or maybe another recent pagewalk patch) breaks
> >> /proc/<pid>/smaps. All fields that should have been filled by
> >> smaps_pte() are almost always zero (and when it isn't, it's always a
> >> multiple of 2MB). It seems to me that the page walk never goes below
> >> pmd level.
> > 
> > Agreed, I'm now thinking that forcing pte_entry() for every user is not
> > good idea, so I'll return to the start point and just will do only the
> > necessary changes (i.e. only iron out the vma handling problem for hugepage.)
> > 
> > Thanks,
> > Naoya Horiguchi
> > 
> >> Jerome
> >>
> >>> - move comment update into a separate patch
> >>>
> >>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >>> ---
> 
> 
> >>> diff --git mmotm-2014-05-21-16-57.orig/mm/pagewalk.c mmotm-2014-05-21-16-57/mm/pagewalk.c
> >>> index 24311d6f5c20..f1a3417d0b51 100644
> >>> --- mmotm-2014-05-21-16-57.orig/mm/pagewalk.c
> >>> +++ mmotm-2014-05-21-16-57/mm/pagewalk.c
> >>> @@ -73,8 +73,22 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr,
> >>>  			continue;
> >>>  		}
> >>>  
> >>> -		if (walk->pmd_entry) {
> >>> -			err = walk->pmd_entry(pmd, addr, next, walk);
> >>> +		/*
> >>> +		 * We don't take compound_lock() here but no race with splitting
> >>> +		 * thp happens because:
> >>> +		 *  - if pmd_trans_huge_lock() returns 1, the relevant thp is
> >>> +		 *    not under splitting, which means there's no concurrent
> >>> +		 *    thp split,
> >>> +		 *  - if another thread runs into split_huge_page() just after
> >>> +		 *    we entered this if-block, the thread must wait for page
> >>> +		 *    table lock to be unlocked in __split_huge_page_splitting(),
> >>> +		 *    where the main part of thp split is not executed yet.
> >>> +		 */
> >>> +		if (walk->pmd_entry && walk->vma) {
> >>> +			if (pmd_trans_huge_lock(pmd, walk->vma, &walk->ptl) == 1) {
> >>> +				err = walk->pmd_entry(pmd, addr, next, walk);
> >>> +				spin_unlock(walk->ptl);
> >>> +			}
> >>>  			if (skip_lower_level_walking(walk))
> >>>  				continue;
> >>>  			if (err)
> 
> This is the cause of the smaps trouble. This code modifies walk->control
> when pmd_entry() is present, even when it is not called. All the control
> code should depend on pmd_trans_huge_lock() == 1 too.

Thank you for pointing out, I have a few objection about doing aggressive
cleanup around this code, and now I'm preparing the next version which
does minimum cleanup without walk->control stuff, so I hope your concern
will be gone in it.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
