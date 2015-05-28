Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0E72C6B0071
	for <linux-mm@kvack.org>; Thu, 28 May 2015 08:00:22 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so121329023wic.1
        for <linux-mm@kvack.org>; Thu, 28 May 2015 05:00:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cl7si3463277wjb.210.2015.05.28.05.00.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 May 2015 05:00:20 -0700 (PDT)
Date: Thu, 28 May 2015 13:00:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kernel bug(VM_BUG_ON_PAGE) with 3.18.13 in mm/migrate.c
Message-ID: <20150528120015.GA26425@suse.de>
References: <CABPcSq+uMcDSBU1xt7oRqPXn-89ZpJmxK+C46M7rX7+Y7-x7iQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CABPcSq+uMcDSBU1xt7oRqPXn-89ZpJmxK+C46M7rX7+Y7-x7iQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jovi Zhangwei <jovi@cloudflare.com>
Cc: linux-kernel@vger.kernel.org, sasha.levin@oracle.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, vbabka@suse.cz, rientjes@google.com

On Wed, May 27, 2015 at 11:05:33AM -0700, Jovi Zhangwei wrote:
> Hi,
> 
> I got below kernel bug error in our 3.18.13 stable kernel.
> "kernel BUG at mm/migrate.c:1661!"
> 
> Source code:
> 
> 1657    static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
> 1658   {
> 1659            int page_lru;
> 1660
> 1661           VM_BUG_ON_PAGE(compound_order(page) &&
> !PageTransHuge(page), page);
> 
> It's easy to trigger the error by run tcpdump in our system.(not sure
> it will easily be reproduced in another system)
> "sudo tcpdump -i bond0.100 'tcp port 4242' -c 100000000000 -w 4242.pcap"
> 
> Any comments for this bug would be great appreciated. thanks.
> 

What sort of compound page is it? What sort of VMA is it in? hugetlbfs
pages should never be tagged for NUMA migrate and never enter this
path. Transparent huge pages are handled properly so I'm wondering
exactly what type of compound page this is and what mapped it into
userspace.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
