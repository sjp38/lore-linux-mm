Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 04B296B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 15:30:31 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so8408709pdi.2
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 12:30:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id h3si9754625paw.86.2014.03.31.12.30.30
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 12:30:30 -0700 (PDT)
Date: Mon, 31 Mar 2014 12:30:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: hugetlb: fix softlockup when a large number of
 hugepages are freed.
Message-Id: <20140331123028.113f3e263daa1b9e749a1678@linux-foundation.org>
In-Reply-To: <533946D4.1060305@jp.fujitsu.com>
References: <533946D4.1060305@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Mizuma, Masayoshi" <m.mizuma@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, 31 Mar 2014 19:43:32 +0900 "Mizuma, Masayoshi" <m.mizuma@jp.fujitsu.com> wrote:

> Hi,
> 
> When I decrease the value of nr_hugepage in procfs a lot, softlockup happens.
> It is because there is no chance of context switch during this process.
> 
> On the other hand, when I allocate a large number of hugepages,
> there is some chance of context switch. Hence softlockup doesn't happen
> during this process. So it's necessary to add the context switch
> in the freeing process as same as allocating process to avoid softlockup.
> 
> ...
>
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1535,6 +1535,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>  	while (min_count < persistent_huge_pages(h)) {
>  		if (!free_pool_huge_page(h, nodes_allowed, 0))
>  			break;
> +		cond_resched_lock(&hugetlb_lock);
>  	}
>  	while (count < persistent_huge_pages(h)) {
>  		if (!adjust_pool_surplus(h, nodes_allowed, 1))

Are you sure we don't need a cond_resched_lock() in this second loop as
well?

Let's bear in mind the objective here: it is to avoid long scheduling
stalls, not to prevent softlockup-detector warnings.  A piece of code
which doesn't trip the lockup detector can still be a problem.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
