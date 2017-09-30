Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 14BA66B0069
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 04:35:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u78so1234711wmd.4
        for <linux-mm@kvack.org>; Sat, 30 Sep 2017 01:35:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b74sor1536204wme.62.2017.09.30.01.35.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 30 Sep 2017 01:35:51 -0700 (PDT)
Date: Sat, 30 Sep 2017 10:35:42 +0200
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: Re: [PATCH] mm, hugetlb: fix "treat_as_movable" condition in
 htlb_alloc_mask
Message-ID: <20170930083542.GA4391@gmail.com>
References: <20170929151339.GA4398@gmail.com>
 <20170929204321.GA593@gmail.com>
 <e085bc8c-6614-5c9b-6702-5ed477bc856c@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e085bc8c-6614-5c9b-6702-5ed477bc856c@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: akpm@linux-foundation.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, punit.agrawal@arm.com, gerald.schaefer@de.ibm.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

On Fri, Sep 29, 2017 at 02:16:10PM -0700, Mike Kravetz wrote:
> Adding Anshuman
> 
> On 09/29/2017 01:43 PM, Alexandru Moise wrote:
> > On Fri, Sep 29, 2017 at 05:13:39PM +0200, Alexandru Moise wrote:
> >>
> >> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> >> index 424b0ef08a60..ab28de0122af 100644
> >> --- a/mm/hugetlb.c
> >> +++ b/mm/hugetlb.c
> >> @@ -926,7 +926,7 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
> >>  /* Movability of hugepages depends on migration support. */
> >>  static inline gfp_t htlb_alloc_mask(struct hstate *h)
> >>  {
> >> -	if (hugepages_treat_as_movable || hugepage_migration_supported(h))
> >> +	if (hugepages_treat_as_movable && hugepage_migration_supported(h))
> >>  		return GFP_HIGHUSER_MOVABLE;
> >>  	else
> >>  		return GFP_HIGHUSER;
> >> -- 
> >> 2.14.2
> >>
> > 
> > I seem to have terribly misunderstood the semantics of this flag wrt hugepages,
> > please ignore this for now.
> 
> That is Okay, it made me look at this code more closely.
> 
> static inline bool hugepage_migration_supported(struct hstate *h)
> {
> #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>         if ((huge_page_shift(h) == PMD_SHIFT) ||
>                 (huge_page_shift(h) == PGDIR_SHIFT))
>                 return true;
>         else
>                 return false;
> #else
>         return false;
> #endif
> }

The real problem is that I still get movable hugepages somehow
even when that hugepages_treat_as_movable is 0, I need to dig
a bit deeper because this behavior really should be optional.

Tools like mcelog are not hugepage aware (IIRC) so users should be able
to rather choose between the balance of having their hugepage using
application run for longer or run with the higher risk of memory
corruption.

> 
> So, hugepage_migration_supported() can only return true if
> ARCH_ENABLE_HUGEPAGE_MIGRATION is defined.  Commit c177c81e09e5
> restricts hugepage_migration_support to x86_64.  So,
> ARCH_ENABLE_HUGEPAGE_MIGRATION is only defined for x86_64.
Hmm?

linux$ grep -rin ARCH_ENABLE_HUGEPAGE_MIGRATION *
arch/powerpc/platforms/Kconfig.cputype:311:config ARCH_ENABLE_HUGEPAGE_MIGRATION
arch/x86/Kconfig:2345:config ARCH_ENABLE_HUGEPAGE_MIGRATION

It is present on PPC_BOOK3S_64

../Alex

> 
> Commit 94310cbcaa3c added the ability to migrate gigantic hugetlb pages
> at the PGD level.  This added the check for PGD level pages to
> hugepage_migration_supported(), which is only there if
> ARCH_ENABLE_HUGEPAGE_MIGRATION is defined.  IIUC, this functionality
> was added for powerpc.  Yet, powerpc does not define
> ARCH_ENABLE_HUGEPAGE_MIGRATION (unless I am missing something).
> 
> -- 
> Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
