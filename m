Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 403A96B00AA
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 17:29:17 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id q58so2899436wes.16
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 14:29:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id vp1si33557835wjc.44.2014.06.09.14.29.14
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 14:29:15 -0700 (PDT)
Message-ID: <5396272b.21efc20a.2ac8.2134SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/7] mm/pagewalk: replace mm_walk->skip with more general mm_walk->control
Date: Mon,  9 Jun 2014 17:29:01 -0400
In-Reply-To: <539612A8.8080303@intel.com>
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1402095520-10109-3-git-send-email-n-horiguchi@ah.jp.nec.com> <539612A8.8080303@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On Mon, Jun 09, 2014 at 01:01:44PM -0700, Dave Hansen wrote:
> On 06/06/2014 03:58 PM, Naoya Horiguchi wrote:
> > +enum mm_walk_control {
> > +	PTWALK_NEXT = 0,	/* Go to the next entry in the same level or
> > +				 * the next vma. This is default behavior. */
> > +	PTWALK_DOWN,		/* Go down to lower level */
> > +	PTWALK_BREAK,		/* Break current loop and continue from the
> > +				 * next loop */
> > +};
> 
> I think this is a bad idea.
> 
> The page walker should be for the common cases of walking page tables,
> and it should be simple.  It *HAS* to be better (shorter/faster) than if
> someone was to just open-code a page table walk, or it's not really useful.
> 
> The only place this is used is in the ppc walker, and it saves a single
> line of code, but requires some comments to explain what is going on:
> 
>  arch/powerpc/mm/subpage-prot.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> So, it adds infrastructure, but saves a single line of code.  Seems like
> a bad trade off to me. :(

Right, thank you.

What I felt uneasy was that after moving pmd locking into common code,
we need unlock/re-lock before/after split_huge_page_pmd() like this:

  static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
                                   unsigned long end, struct mm_walk *walk)
  {
         struct vm_area_struct *vma = walk->vma;
+        spin_unlock(walk->ptl);
         split_huge_page_pmd(vma, addr, pmd);
+        spin_lock(walk->ptl);
         return 0;
  }

I thought it's straightforward but dirty, but my workaround in this patch
was dirty too. So I'm fine to give up the control stuff and take this one.

BTW after moving pmd locking, PTWALK_DOWN is used only by walk_page_test()
and ->test_walk(), so we can completely remove ->skip by giving that role
to the positive value of the return value. It's cleaner.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
