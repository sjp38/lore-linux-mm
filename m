Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2BE6B0008
	for <linux-mm@kvack.org>; Sun, 18 Feb 2018 11:46:07 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id x22so3387209uaj.12
        for <linux-mm@kvack.org>; Sun, 18 Feb 2018 08:46:07 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 66si2773229vka.384.2018.02.18.08.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Feb 2018 08:46:06 -0800 (PST)
From: robert.m.harris@oracle.com
Subject: [PATCH 0/1] mm, compaction: correct the bounds of __fragmentation_index()
Date: Sun, 18 Feb 2018 16:47:54 +0000
Message-Id: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org
Cc: Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Mel Gorman <mgorman@suse.de>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>, "Robert M. Harris" <robert.m.harris@oracle.com>

From: "Robert M. Harris" <robert.m.harris@oracle.com>

__fragmentation_index() calculates a value used to determine whether
compaction should be favoured over page reclaim in the event of
allocation failure.  The function purports to return a value between 0
and 1000, representing units of 1/1000.  Barring the case of a
pathological shortfall of memory, the lower bound is instead 500.  This
is significant because it is the default value of
sysctl_extfrag_threshold, i.e. the value below which compaction should
be avoided in favour of page reclaim for costly pages.

Here's an illustration using a zone that I fragmented with selective
calls to __alloc_pages() and __free_pages --- the fragmentation for
order-1 could not be minimised further yet is reported as 0.5:

# head -1 /proc/buddyinfo
Node 0, zone      DMA   1983      0      0      0      0      0      0      0      0      0      0 
# head -1 /sys/kernel/debug/extfrag/extfrag_index
Node 0, zone      DMA -1.000 0.500 0.750 0.875 0.937 0.969 0.984 0.992 0.996 0.998 0.999 
# 

With extreme memory shortage the reported fragmentation index does go
lower.  In fact, it can go below zero:

# head -1 /proc/buddyinfo
Node 0, zone      DMA      1      0      0      0      0      0      0      0      0      0      0 
# head -1 /sys/kernel/debug/extfrag/extfrag_index
Node 0, zone      DMA -1.000 0.-500 0.-250 0.-125 0.-62 0.-31 0.-15 0.-07 0.-03 0.-01 0.000 
# 

This patch implements and documents a modified version of the original
expression that returns a value in the range 0 <= index < 1000.  It
amends the default value of sysctl_extfrag_threshold to preserve the
existing behaviour.  With this patch in place, the same two tests yield

# head -1 /proc/buddyinfo
Node 0, zone      DMA   1983      0      0      0      0      0      0      0      0      0      0 
# head -1 /sys/kernel/debug/extfrag/extfrag_index
Node 0, zone      DMA -1.000 0.000 0.500 0.750 0.875 0.937 0.969 0.984 0.992 0.996 0.998 
# 

and

# head -1 /proc/buddyinfo
Node 0, zone      DMA      1      0      0      0      0      0      0      0      0      0      0 
# head -1 /sys/kernel/debug/extfrag/extfrag_index
Node 0, zone      DMA -1.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 
# 

Robert M. Harris (1):
  mm, compaction: correct the bounds of __fragmentation_index()

 Documentation/sysctl/vm.txt |  2 +-
 mm/compaction.c             |  2 +-
 mm/vmstat.c                 | 47 +++++++++++++++++++++++++++++++++++----------
 3 files changed, 39 insertions(+), 12 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
