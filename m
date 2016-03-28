Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3AF6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 05:14:06 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id r72so10524091wmg.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 02:14:06 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id m194si9888066wmg.82.2016.03.28.02.14.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 02:14:04 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id p65so90515775wmp.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 02:14:04 -0700 (PDT)
From: Nikolay Borisov <kernel@kyup.com>
Subject: memory fragmentation issues on 4.4
Message-ID: <56F8F5DA.6040206@kyup.com>
Date: Mon, 28 Mar 2016 12:14:02 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: vbabka@suse.cz, mgorman@techsingularity.net

Hello,

On kernel 4.4 I observe that the memory gets really fragmented fairly
quickly. E.g. there are no order  > 4 pages even after 2 days of uptime.
This leads to certain data structures on XFS (in my case order 4/order 5
allocations)  not being allocated and causes the server to stall. When
this happens either someone has to log on the server and manually invoke
the memory compaction or plain reboot the server. Before that the server
was running with the exact same workload but with 3.12.52 kernel and no
such issue were observed. That is - memory was fragmented but allocation
didn't fail, maybe alloc_pages_direct_compact was doing a better job?

FYI the allocation is performed with GFP_KERNEL | GFP_NOFS


Manual compaction usually does the job, however I'm wondering why isn't
invoking __alloc_pages_direct_compact from within __alloc_pages_nodemask
satisfying the request if manual compaction would do the job. Is there a
difference in the efficiency of manually invoking memory compaction and
the one invoked from the page allocator path?


Another question for my own satisfaction - I created a kernel module
which allocate pages of very high order - 8/9) then later when those
pages are returned I see the number of unmovable pages increase by the
amount of pages returned. So should freed pages go to the unmovable
category?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
