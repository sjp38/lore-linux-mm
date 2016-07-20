Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7536B0253
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 09:24:34 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id l89so32465696lfi.3
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 06:24:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wm6si955079wjc.193.2016.07.20.06.24.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jul 2016 06:24:32 -0700 (PDT)
Date: Wed, 20 Jul 2016 15:24:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm/hugetlb: fix race when migrate pages
Message-ID: <20160720132431.GM11249@dhcp22.suse.cz>
References: <1468935958-21810-1-git-send-email-zhongjiang@huawei.com>
 <20160720073859.GE11249@dhcp22.suse.cz>
 <578F4C7C.6000706@huawei.com>
 <20160720121645.GJ11249@dhcp22.suse.cz>
 <20160720124501.GK11249@dhcp22.suse.cz>
 <20160720130055.GL11249@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160720130055.GL11249@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: vbabka@suse.cz, qiuxishi@huawei.com, akpm@linux-foundation.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>

[Sorry for spammin, I though my headache would force me to not stare
 into the code more but I couldn't resist ]
On Wed 20-07-16 15:00:55, Michal Hocko wrote:
> On Wed 20-07-16 14:45:01, Michal Hocko wrote:
> [...]
> > I was talking to Mel (CCed) and he has raised a good question. So if you
> > encounter a page under migration and fail to share the pmd with it how
> > can you have a proper content of the target page in the end?
> 
> Hmm, I was staring into the code some more and it seems this would be OK
> because we should hit hugetlb_no_page with the newel instantiated pmd
> and associate it with a page from the radix tree. So unless I am missing
> something the corruption shouldn't be possible.
> 
> I believe the post pmd_populate race is still there, though, so I
> believe the approach should be rethought.

So I think the swap entry is OK in fact. huge_pte_alloc would return a
shared pmd which would just happen to be swap entry. hugetlb_fault would
then recognize that by:
	/*
	 * entry could be a migration/hwpoison entry at this point, so this
	 * check prevents the kernel from going below assuming that we have
	 * a active hugepage in pagecache. This goto expects the 2nd page fault,
	 * and is_hugetlb_entry_(migration|hwpoisoned) check will properly
	 * handle it.
	 */
	if (!pte_present(entry))
		goto out_mutex;

We would get back from the page fault and if the page was still under
migration on the retry we would end up waiting for the migration entry
on the next fault.

	ptep = huge_pte_offset(mm, address);
	if (ptep) {
		entry = huge_ptep_get(ptep);
		if (unlikely(is_hugetlb_entry_migration(entry))) {
			migration_entry_wait_huge(vma, mm, ptep);
			return 0;

Or am I missing something? If not we should just reconsider the BUG_ON
but I still have to think wether it is useful/needed at all.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
