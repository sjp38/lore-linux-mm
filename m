Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id F362A6B0027
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 01:13:31 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 1 Apr 2013 15:07:58 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id B72D22BB0023
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:13:20 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r315DFkl15532244
	for <linux-mm@kvack.org>; Mon, 1 Apr 2013 16:13:15 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r315DIRL018462
	for <linux-mm@kvack.org>; Mon, 1 Apr 2013 16:13:19 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 03/10] soft-offline: use migrate_pages() instead of migrate_huge_page()
In-Reply-To: <20130327135250.GI16579@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-4-git-send-email-n-horiguchi@ah.jp.nec.com> <87boa69z6j.fsf@linux.vnet.ibm.com> <20130327135250.GI16579@dhcp22.suse.cz>
Date: Mon, 01 Apr 2013 10:43:14 +0530
Message-ID: <874nfqesut.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Tue 26-03-13 16:59:40, Aneesh Kumar K.V wrote:
>> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> [...]
>> > diff --git v3.9-rc3.orig/mm/memory-failure.c v3.9-rc3/mm/memory-failure.c
>> > index df0694c..4e01082 100644
>> > --- v3.9-rc3.orig/mm/memory-failure.c
>> > +++ v3.9-rc3/mm/memory-failure.c
>> > @@ -1467,6 +1467,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
>> >  	int ret;
>> >  	unsigned long pfn = page_to_pfn(page);
>> >  	struct page *hpage = compound_head(page);
>> > +	LIST_HEAD(pagelist);
>> >
>> >  	/*
>> >  	 * This double-check of PageHWPoison is to avoid the race with
>> > @@ -1482,12 +1483,20 @@ static int soft_offline_huge_page(struct page *page, int flags)
>> >  	unlock_page(hpage);
>> >
>> >  	/* Keep page count to indicate a given hugepage is isolated. */
>> > -	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
>> > -				MIGRATE_SYNC);
>> > -	put_page(hpage);
>> > +	list_move(&hpage->lru, &pagelist);
>> 
>> we use hpage->lru to add the hpage to h->hugepage_activelist. This will
>> break a hugetlb cgroup removal isn't it ?
>
> This particular part will not break removal because
> hugetlb_cgroup_css_offline loops until hugetlb_cgroup_have_usage is 0.
>

But we still need to hold hugetlb_lock around that right ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
