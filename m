Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id A6F436B0005
	for <linux-mm@kvack.org>; Sun,  4 Nov 2018 19:20:15 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c7so18088819qkg.16
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 16:20:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v2si4045541qvm.85.2018.11.04.16.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 16:20:14 -0800 (PST)
Date: Mon, 5 Nov 2018 08:20:09 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] mm, memory_hotplug: teach has_unmovable_pages about of
 LRU migrateable pages
Message-ID: <20181105002009.GF27491@MiWiFi-R3L-srv>
References: <20181101091055.GA15166@MiWiFi-R3L-srv>
 <20181102155528.20358-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181102155528.20358-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Stable tree <stable@vger.kernel.org>

Hi Michal,

On 11/02/18 at 04:55pm, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Baoquan He has noticed that 15c30bc09085  ("mm, memory_hotplug: make
> has_unmovable_pages more robust") is causing memory offlining failures
> on a movable node. After a further debugging it turned out that
> has_unmovable_pages fails prematurely because it stumbles over off-LRU
> pages. Nevertheless those pages are not on LRU because they are waiting
> on the pcp LRU caches (an example of __dump_page added by a debugging
> patch)
> [  560.923297] page:ffffea043f39fa80 count:1 mapcount:0 mapping:ffff880e5dce1b59 index:0x7f6eec459
> [  560.931967] flags: 0x5fffffc0080024(uptodate|active|swapbacked)
> [  560.937867] raw: 005fffffc0080024 dead000000000100 dead000000000200 ffff880e5dce1b59
> [  560.945606] raw: 00000007f6eec459 0000000000000000 00000001ffffffff ffff880e43ae8000
> [  560.953323] page dumped because: hotplug
> [  560.957238] page->mem_cgroup:ffff880e43ae8000
> [  560.961620] has_unmovable_pages: pfn:0x10fd030d, found:0x1, count:0x0
> [  560.968127] page:ffffea043f40c340 count:2 mapcount:0 mapping:ffff880e2f2d8628 index:0x0
> [  560.976104] flags: 0x5fffffc0000006(referenced|uptodate)
> [  560.981401] raw: 005fffffc0000006 dead000000000100 dead000000000200 ffff880e2f2d8628
> [  560.989119] raw: 0000000000000000 0000000000000000 00000002ffffffff ffff88010a8f5000
> [  560.996833] page dumped because: hotplug

Sorry, last week I didn't test this patch with memory pressure adding.
Today use "stress -m 200 -t 2h" to add pressure, hot removing failed.
Will send you output log. W/o memory pressure, it sometimes succeed. I
saw one failure last night, it still show un-removable as 0 in
hotpluggable node one time, I worried it might be caused by my compiling
mistake, so compile and try again this morning.

Thanks
Baoquan
