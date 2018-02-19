Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26D426B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 03:24:32 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t128so4381709wmt.9
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 00:24:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b49si13999253wrg.513.2018.02.19.00.24.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 00:24:30 -0800 (PST)
Date: Mon, 19 Feb 2018 09:24:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/1] mm, compaction: correct the bounds of
 __fragmentation_index()
Message-ID: <20180219082428.GC21134@dhcp22.suse.cz>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.m.harris@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Mel Gorman <mgorman@suse.de>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>

On Sun 18-02-18 16:47:54, robert.m.harris@oracle.com wrote:
> From: "Robert M. Harris" <robert.m.harris@oracle.com>
> 
> __fragmentation_index() calculates a value used to determine whether
> compaction should be favoured over page reclaim in the event of
> allocation failure.  The function purports to return a value between 0
> and 1000, representing units of 1/1000.  Barring the case of a
> pathological shortfall of memory, the lower bound is instead 500.  This
> is significant because it is the default value of
> sysctl_extfrag_threshold, i.e. the value below which compaction should
> be avoided in favour of page reclaim for costly pages.
> 
> Here's an illustration using a zone that I fragmented with selective
> calls to __alloc_pages() and __free_pages --- the fragmentation for
> order-1 could not be minimised further yet is reported as 0.5:

Cover letter for a single patch is usually an overkill. Why is this
information not valuable in the patch description directly?

> # head -1 /proc/buddyinfo
> Node 0, zone      DMA   1983      0      0      0      0      0      0      0      0      0      0 
> # head -1 /sys/kernel/debug/extfrag/extfrag_index
> Node 0, zone      DMA -1.000 0.500 0.750 0.875 0.937 0.969 0.984 0.992 0.996 0.998 0.999 
> # 
> 
> With extreme memory shortage the reported fragmentation index does go
> lower.  In fact, it can go below zero:
> 
> # head -1 /proc/buddyinfo
> Node 0, zone      DMA      1      0      0      0      0      0      0      0      0      0      0 
> # head -1 /sys/kernel/debug/extfrag/extfrag_index
> Node 0, zone      DMA -1.000 0.-500 0.-250 0.-125 0.-62 0.-31 0.-15 0.-07 0.-03 0.-01 0.000 
> # 
> 
> This patch implements and documents a modified version of the original
> expression that returns a value in the range 0 <= index < 1000.  It
> amends the default value of sysctl_extfrag_threshold to preserve the
> existing behaviour.  With this patch in place, the same two tests yield
> 
> # head -1 /proc/buddyinfo
> Node 0, zone      DMA   1983      0      0      0      0      0      0      0      0      0      0 
> # head -1 /sys/kernel/debug/extfrag/extfrag_index
> Node 0, zone      DMA -1.000 0.000 0.500 0.750 0.875 0.937 0.969 0.984 0.992 0.996 0.998 
> # 
> 
> and
> 
> # head -1 /proc/buddyinfo
> Node 0, zone      DMA      1      0      0      0      0      0      0      0      0      0      0 
> # head -1 /sys/kernel/debug/extfrag/extfrag_index
> Node 0, zone      DMA -1.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 
> # 
> 
> Robert M. Harris (1):
>   mm, compaction: correct the bounds of __fragmentation_index()
> 
>  Documentation/sysctl/vm.txt |  2 +-
>  mm/compaction.c             |  2 +-
>  mm/vmstat.c                 | 47 +++++++++++++++++++++++++++++++++++----------
>  3 files changed, 39 insertions(+), 12 deletions(-)
> 
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
