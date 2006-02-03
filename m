Received: from m7.gw.fujitsu.co.jp ([10.0.50.77])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k137ZCw8003763 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:35:12 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k137ZBWg031715 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:35:11 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp (s11 [127.0.0.1])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 97B94F8C3A
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:35:11 +0900 (JST)
Received: from fjm506.ms.jp.fujitsu.com (fjm506.ms.jp.fujitsu.com [10.56.99.86])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 528E3F8527
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:35:11 +0900 (JST)
Received: from [127.0.0.1] (fjmscan502.ms.jp.fujitsu.com [10.56.99.142])by fjm506.ms.jp.fujitsu.com with ESMTP id k137Ytxf002849
	for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:34:57 +0900
Message-ID: <43E307DB.3000903@jp.fujitsu.com>
Date: Fri, 03 Feb 2006 16:35:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] pearing off zone from physical memory layout [0/10]
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

This series of patches remove members from zone, which depends on physical
memory layout, zone_start_pfn, spanned_pages, zone_mem_map against 2.6.16-rc1.

By this, zone's meaning will be changed from "a range of memory to be used
in a same manner" to "a group of memory to be used in a same manner".

Now, the kernel and memmap became sparse if SPARSEMEM=y,  but zone is considered
as a range of memory.

memory-hot-add adds memory to HIGHMEM, but a zone is considered as a range.
This means memory layout (after hot add) like this is ok,
NORMAL | NORMAL  | HIGHMEM | HIGHMEM.
but this is insane
NORMAL | HIGHMEM | NORMAL  | HIGHMEM. (we can do, but insane)

IMHO, a zone is  an unit of allocation/reclaim of same type of pages.
I think that a zone should be defined by its usage/purpose not by physical
memory layout.

Some codes which wants to walk through all pages in a zone is supported by
for_each_page_in_zone() macro.

I tested this on my desktop machine a little, but  I know this patch needs
more work on some arch (ia64 etc...).

comments ?


-- Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
