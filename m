Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D90C46B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 03:49:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u78so7136188wmd.4
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 00:49:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t104sor4411145wrc.35.2017.10.03.00.49.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 00:49:12 -0700 (PDT)
Date: Tue, 3 Oct 2017 09:49:01 +0200
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: Re: +
 mm-madvise-enable-soft-offline-of-hugetlb-pages-at-pud-level.patch added to
 -mm tree
Message-ID: <20171003074901.GA10409@gmail.com>
References: <59cd6cfc.gjq2hAb82xF6wYrU%akpm@linux-foundation.org>
 <20171003073301.hydw7jf2wztsx2om@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003073301.hydw7jf2wztsx2om@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, khandual@linux.vnet.ibm.com, kirill@shutemov.name, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, punit.agrawal@arm.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 03, 2017 at 09:33:01AM +0200, Michal Hocko wrote:
> I am sorry to jump here late
> 
> On Thu 28-09-17 14:43:24, Andrew Morton wrote:
> > From: Alexandru Moise <00moses.alexander00@gmail.com>
> > Subject: mm/madvise: enable soft offline of HugeTLB pages at PUD level
> > 
> > Since 94310cbcaa3c2 ("mm/madvise: enable (soft|hard) offline of HugeTLB
> > pages at PGD level") we've been able to soft offline 1G hugepages at the
> > PGD level, however x86_64 gigantic hugepages are at the PUD level so we
> > should add an extra check to account for hstate order at PUD level.
> > 
> > I'm not sure if this also applies to 5 level page tables on x86_64
> > however. Tested with 4 level pagetable.
> 
> This patch is wrong I believe! And I suspect 94310cbcaa3c2 is wrong as
> well but I am not familiar with ppc enough to be sure. It will allow
> PUD, PGD pages to be allocated from the zone movable while at least PUD
> pages are not migrateable for x86_64 AFAIR. Are PGD pages migrateable
> on ppc? If yes, are there any other architectures to allow PGD hugetlb
> pages which are not migrateable?
> 
> Andrew, could you drop it please?
>  

What exactly makes it wrong? When I tested this I saw no failure,
copy_huge_page() seems to take into account gigantic hugepages,
and when you move the mapping you don't really care about the
page size?

../Alex

> > Link: http://lkml.kernel.org/r/20170913101047.GA13026@gmail.com
> > Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Mike Kravetz <mike.kravetz@oracle.com>
> > Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> > Cc: Punit Agrawal <punit.agrawal@arm.com>
> > Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> > Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  include/linux/hugetlb.h |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff -puN include/linux/hugetlb.h~mm-madvise-enable-soft-offline-of-hugetlb-pages-at-pud-level include/linux/hugetlb.h
> > --- a/include/linux/hugetlb.h~mm-madvise-enable-soft-offline-of-hugetlb-pages-at-pud-level
> > +++ a/include/linux/hugetlb.h
> > @@ -480,6 +480,7 @@ static inline bool hugepage_migration_su
> >  {
> >  #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
> >  	if ((huge_page_shift(h) == PMD_SHIFT) ||
> > +		(huge_page_shift(h) == PUD_SHIFT) ||
> >  		(huge_page_shift(h) == PGDIR_SHIFT))
> >  		return true;
> >  	else
> > _
> > 
> > Patches currently in -mm which might be from 00moses.alexander00@gmail.com are
> > 
> > mm-hugetlb-soft_offline-save-compound-page-order-before-page-migration.patch
> > mm-madvise-enable-soft-offline-of-hugetlb-pages-at-pud-level.patch
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
