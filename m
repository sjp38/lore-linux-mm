Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 8CC916B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 13:52:13 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 28 Jul 2012 03:51:52 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6RHhs6510420428
	for <linux-mm@kvack.org>; Sat, 28 Jul 2012 03:43:54 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6RHq5XH001632
	for <linux-mm@kvack.org>; Sat, 28 Jul 2012 03:52:05 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] list corruption by gather_surplus
In-Reply-To: <E1SuVpz-00028P-QG@eag09.americas.sgi.com>
References: <E1SuVpz-00028P-QG@eag09.americas.sgi.com>
Date: Fri, 27 Jul 2012 23:21:53 +0530
Message-ID: <87394d5bye.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cliff Wickman <cpw@sgi.com>, cmetcalf@tilera.com, dave@linux.vnet.ibm.com, dhillf@gmail.com, dwg@au1.ibm.com, kamezawa.hiroyuki@gmail.com, khlebnikov@openvz.org, lee.schermerhorn@hp.com, mgorman@suse.de, mhocko@suse.cz, shhuiw@gmail.com, viro@zeniv.linux.org.uk
Cc: linux-mm@kvack.org

Cliff Wickman <cpw@sgi.com> writes:

> From: Cliff Wickman <cpw@sgi.com>
>
> Gentlemen,
> I see that you all have done maintenance on mm/hugetlb.c, so I'm hoping one
> or two of you could comment on a problem and proposed fix.
>
>
> I am seeing list corruption occurring from within gather_surplus_pages()
> (mm/hugetlb.c).  The problem occurs under a heavy load, and seems to be
> because this function drops the hugetlb_lock.
>
> I have CONFIG_DEBUG_LIST=y, and am running an MPI application with 64 threads
> and a library that creates a large heap of hugetlbfs pages for it.
>
> The below patch fixes the problem.
> The gist of this patch is that gather_surplus_pages() does not have to drop
> the lock if alloc_buddy_huge_page() is told whether the lock is
> already held.


But you didn't explain the corruption details right ? What cause the
corruption ? It would be nice to document that in the commit.

>
> But I may be missing some reason why gather_surplus_pages() is unlocking and
> locking the hugetlb_lock several times (besides around the allocator).
>
> Could you take a look and advise?
>
> Signed-off-by: Cliff Wickman <cpw@sgi.com>
> ---
>  mm/hugetlb.c |   28 +++++++++++++++++-----------
>  1 file changed, 17 insertions(+), 11 deletions(-)
>
> Index: linux/mm/hugetlb.c
> ===================================================================
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -747,7 +747,9 @@ static int free_pool_huge_page(struct hs
>  	return ret;
>  }
>
> -static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
> +/* already_locked means the caller has already locked hugetlb_lock */
> +static struct page *alloc_buddy_huge_page(struct hstate *h, int nid,
> +						int already_locked)
>  {

Why ? Why can't we always call this with lock held ?

>  	struct page *page;
>  	unsigned int r_nid;
> @@ -778,7 +780,8 @@ static struct page *alloc_buddy_huge_pag
>  	 * the node values until we've gotten the hugepage and only the

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
