Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 869BE6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 13:18:29 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id fz5so91495302obc.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 10:18:29 -0700 (PDT)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id q64si6824625oif.43.2016.03.17.10.18.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 10:18:28 -0700 (PDT)
Received: by mail-ob0-x22b.google.com with SMTP id fz5so91495006obc.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 10:18:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1458146962-15401-1-git-send-email-l.stach@pengutronix.de>
References: <1458146962-15401-1-git-send-email-l.stach@pengutronix.de>
Date: Fri, 18 Mar 2016 02:18:27 +0900
Message-ID: <CAAmzW4PnnDSDGdMHY98GgkL7LuXvk=6=_MQGnWy6HJr_qax8RA@mail.gmail.com>
Subject: Re: [PATCH] mm/page_isolation: let caller take the zone lock for test_pages_isolated
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, kernel@pengutronix.de, patchwork-lst@pengutronix.de

2016-03-17 1:49 GMT+09:00 Lucas Stach <l.stach@pengutronix.de>:
> This fixes an annoying race in the CMA code leading to lots of "PFNs busy"
> messages when CMA is used concurrently. This is harmless normally as CMA
> will just retry the allocation at a different place, but it might lead to
> increased fragmentation of the CMA area as well as failing allocations
> when CMA is under memory pressure.
>
> The issue is that test_pages_isolated checks if the range is free by
> checking that all pages in the range are buddy pages. For this to work
> the start pfn needs to be aligned to the higher order buddy page
> including the start pfn if there is any.
>
> This is not a problem for the memory hotplug code, as it always offlines
> whole pageblocks, but CMA may want to isolate a smaller range. So for
> the check to work correctly it down-aligns the start pfn to the higher
> order buddy page. As the zone is not yet locked at that point a
> concurrent page free might coalesce the pages to be checked into an
> even bigger buddy page, causing the check to fail, while all pages are
> in fact buddy pages.
>
> By moving the zone locking to the caller of the test function, it's
> possible to do it before CMA tries to find the proper start page and stop
> any concurrent page coalescing to happen until the check is finished.

I think that this patch cannot prevent the same race on
isolate_freepages_range(). If buddy merging happens after we
passed test_pages_isolated(), isolate_freepages_range() cannot see
buddy page and will fail.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
