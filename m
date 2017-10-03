Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E10C76B0253
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 04:00:16 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k7so2849641wre.22
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 01:00:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c12si10548492wrd.406.2017.10.03.01.00.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 01:00:15 -0700 (PDT)
Date: Tue, 3 Oct 2017 10:00:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: +
 mm-madvise-enable-soft-offline-of-hugetlb-pages-at-pud-level.patch added to
 -mm tree
Message-ID: <20171003080014.ka2ciydnw472oyeg@dhcp22.suse.cz>
References: <59cd6cfc.gjq2hAb82xF6wYrU%akpm@linux-foundation.org>
 <20171003073301.hydw7jf2wztsx2om@dhcp22.suse.cz>
 <20171003074901.GA10409@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003074901.GA10409@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandru Moise <00moses.alexander00@gmail.com>
Cc: akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, khandual@linux.vnet.ibm.com, kirill@shutemov.name, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, punit.agrawal@arm.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Tue 03-10-17 09:49:01, Alexandru Moise wrote:
> On Tue, Oct 03, 2017 at 09:33:01AM +0200, Michal Hocko wrote:
> > I am sorry to jump here late
> > 
> > On Thu 28-09-17 14:43:24, Andrew Morton wrote:
> > > From: Alexandru Moise <00moses.alexander00@gmail.com>
> > > Subject: mm/madvise: enable soft offline of HugeTLB pages at PUD level
> > > 
> > > Since 94310cbcaa3c2 ("mm/madvise: enable (soft|hard) offline of HugeTLB
> > > pages at PGD level") we've been able to soft offline 1G hugepages at the
> > > PGD level, however x86_64 gigantic hugepages are at the PUD level so we
> > > should add an extra check to account for hstate order at PUD level.
> > > 
> > > I'm not sure if this also applies to 5 level page tables on x86_64
> > > however. Tested with 4 level pagetable.
> > 
> > This patch is wrong I believe! And I suspect 94310cbcaa3c2 is wrong as
> > well but I am not familiar with ppc enough to be sure. It will allow
> > PUD, PGD pages to be allocated from the zone movable while at least PUD
> > pages are not migrateable for x86_64 AFAIR. Are PGD pages migrateable
> > on ppc? If yes, are there any other architectures to allow PGD hugetlb
> > pages which are not migrateable?
> > 
> > Andrew, could you drop it please?
> >  
> 
> What exactly makes it wrong? When I tested this I saw no failure,
> copy_huge_page() seems to take into account gigantic hugepages,
> and when you move the mapping you don't really care about the
> page size?

Migrating 1GB (PUD) pages on x86_64 is just too easy to fail (if it
works at all) and so such an allocation can easily prefent memory
offline to succeed. Have you tested that scenario?

Btw. (ab)using hugepage_migration_supported for HWpoinsoning sounds
wrong to me. You do not need movable zone for the functionality.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
