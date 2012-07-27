Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 48FA26B0044
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 05:02:47 -0400 (EDT)
Date: Fri, 27 Jul 2012 11:02:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
Message-ID: <20120727090243.GB26351@tiehlicka.suse.cz>
References: <20120720134937.GG9222@suse.de>
 <20120720141108.GH9222@suse.de>
 <20120720143635.GE12434@tiehlicka.suse.cz>
 <50118D16.4050603@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50118D16.4050603@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 26-07-12 14:31:50, Rik van Riel wrote:
> On 07/20/2012 10:36 AM, Michal Hocko wrote:
> 
> >--- a/arch/x86/mm/hugetlbpage.c
> >+++ b/arch/x86/mm/hugetlbpage.c
> >@@ -81,7 +81,12 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> >  		if (saddr) {
> >  			spte = huge_pte_offset(svma->vm_mm, saddr);
> >  			if (spte) {
> >-				get_page(virt_to_page(spte));
> >+				struct page *spte_page = virt_to_page(spte);
> >+				if (!is_hugetlb_pmd_page_valid(spte_page)) {
> 
> What prevents somebody else from marking the hugetlb
> pmd invalid, between here...
> 
> >+					spte = NULL;
> >+					continue;
> >+				}
> 
> ... and here?

huge_ptep_get_and_clear is (should be) called inside i_mmap which is not
the case right now as Mel already pointed out in other email

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
