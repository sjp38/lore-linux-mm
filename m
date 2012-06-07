Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id E38716B0062
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 15:05:23 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 7 Jun 2012 18:56:20 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q57IvwGt3473852
	for <linux-mm@kvack.org>; Fri, 8 Jun 2012 04:57:59 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q57J5Aeu012269
	for <linux-mm@kvack.org>; Fri, 8 Jun 2012 05:05:11 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 07/14] mm/page_cgroup: Make page_cgroup point to the cgroup rather than the mem_cgroup
In-Reply-To: <4FCD7FBB.1000304@jp.fujitsu.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1338388739-22919-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4FCD648E.90709@jp.fujitsu.com> <87ehpu8o5z.fsf@skywalker.in.ibm.com> <4FCD7FBB.1000304@jp.fujitsu.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Fri, 08 Jun 2012 00:35:00 +0530
Message-ID: <87sje72bab.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> You can use other pages than head/tails.
> For example,I think you have 512 pages per 2M pages.

How about the below. This limit the usage to hugetlb cgroup to only
hugepages with more than 3 normal pages. I guess that is an acceptable limitation.

static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
{
	if (!PageHuge(page))
		return NULL;
	if (compound_order(page) < 3)
		return NULL;
	return (struct hugetlb_cgroup *)page[2].lru.next;
}

static inline
int set_hugetlb_cgroup(struct page *page, struct hugetlb_cgroup *h_cg)
{
	if (!PageHuge(page))
		return -1;
	if (compound_order(page) < 3)
		return -1;
	page[2].lru.next = (void *)h_cg;
	return 0;
}


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
