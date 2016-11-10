Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 552D26B0266
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 02:04:11 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b132so8861187iti.5
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 23:04:11 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0046.outbound.protection.outlook.com. [104.47.2.46])
        by mx.google.com with ESMTPS id 16si1795309otc.181.2016.11.09.23.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 23:04:10 -0800 (PST)
Date: Thu, 10 Nov 2016 15:03:51 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v2 2/2] mm: hugetlb: support gigantic surplus pages
Message-ID: <20161110070348.GA2057@sha-win-210.asiapac.arm.com>
References: <1478141499-13825-3-git-send-email-shijie.huang@arm.com>
 <1478675294-2507-1-git-send-email-shijie.huang@arm.com>
 <20161109165549.1cf320c5@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161109165549.1cf320c5@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Wed, Nov 09, 2016 at 04:55:49PM +0100, Gerald Schaefer wrote:
> > index 9fdfc24..5dbfd62 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1095,6 +1095,9 @@ static struct page *alloc_gigantic_page(int nid, unsigned int order)
> >  	unsigned long ret, pfn, flags;
> >  	struct zone *z;
> > 
> > +	if (nid == NUMA_NO_NODE)
> > +		nid = numa_mem_id();
> > +
> 
> Now counter.sh works (on s390) w/o the lockdep warning. However, it looks
Good news to me :)
We have found the root cause of the s390 issue.

> like this change will now result in inconsistent behavior compared to the
> normal sized hugepages, regarding surplus page allocation. Setting nid to
> numa_mem_id() means that only the node of the current CPU will be considered
> for allocating a gigantic page, as opposed to just "preferring" the current
> node in the normal size case (__hugetlb_alloc_buddy_huge_page() ->
> alloc_pages_node()) with a fallback to using other nodes.
Yes.

> 
> I am not really familiar with NUMA, and I might be wrong here, but if
> this is true then gigantic pages, which may be hard allocate at runtime
> in general, will be even harder to find (as surplus pages) because you
> only look on the current node.
Okay, I will try to fix this in the next version.

> 
> I honestly do not understand why alloc_gigantic_page() needs a nid
> parameter at all, since it looks like it will only be called from
> alloc_fresh_gigantic_page_node(), which in turn is only called
> from alloc_fresh_gigantic_page() in a "for_each_node" loop (at least
> before your patch).
> 
> Now it could be an option to also use alloc_fresh_gigantic_page()
> in your patch, instead of directly calling alloc_gigantic_page(),
Yes, a good suggestion. But I need to do some change to the
alloc_fresh_gigantic_page().	


Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
