Received: from m5.gw.fujitsu.co.jp ([10.0.50.75]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i88CEmtx000647 for <linux-mm@kvack.org>; Wed, 8 Sep 2004 21:14:48 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i88CElbS004905 for <linux-mm@kvack.org>; Wed, 8 Sep 2004 21:14:47 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp (s3 [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C6A243F02
	for <linux-mm@kvack.org>; Wed,  8 Sep 2004 21:14:47 +0900 (JST)
Received: from fjmail502.fjmail.jp.fujitsu.com (fjmail502-0.fjmail.jp.fujitsu.com [10.59.80.98])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D706B43EFC
	for <linux-mm@kvack.org>; Wed,  8 Sep 2004 21:14:46 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail502.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3Q0040J20L81@fjmail502.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed,  8 Sep 2004 21:14:46 +0900 (JST)
Date: Wed, 08 Sep 2004 21:20:02 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] no bitmap buddy allocator:  remove free_area->map
 (0/4)
In-reply-to: <413EEFA9.9030007@jp.fujitsu.com>
Message-id: <413EF8F2.5000904@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <413EEFA9.9030007@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, LHMS <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This is a quick change-log from "previous-version" for comparison.

Big difference from previous one is revival of bad_range() and reduced victim pages.

   -- bad_range() is modified and bad_range_pfn() is added.
   -- bad_range_pfn() uses zone->memmap_start_pfn/memmap_end_pfn instead of using
      zone_start_pfn/spanned_pages. Because IA64's memmap's start is not equal to
      zone->zone_start_pfn.
   -- In most inner loop of __free_pages_bulk(), bad_range_pfn() is used.
   -- this bad_range_pfn() enables me to reduce victim pages.

      In my IA64,
Sep  8 18:59:38 casares kernel: calculate_buddy_range() 36e 129901
Sep  8 18:59:38 casares kernel: victim end page 1feda
Sep  8 18:59:38 casares kernel: calculate_buddy_range() 1fedc 292
Sep  8 18:59:38 casares kernel: victim top page 1fedc
Sep  8 18:59:38 casares kernel: victim top page 1fee0
Sep  8 18:59:38 casares kernel: victim top page 1ff00
Sep  8 18:59:38 casares kernel: victim end page 1ffff
Sep  8 18:59:38 casares kernel: saved end victim page 1ffff
Sep  8 18:59:38 casares kernel: calculate_buddy_range() 40000 262144
Sep  8 18:59:38 casares kernel: calculate_buddy_range() a0000 131072
Sep  8 18:59:38 casares kernel: victim top page a0000
Sep  8 18:59:38 casares kernel: Built 1 zonelists
       # of victim pages is 5. It was 19 in previous version.

   -- ia64's virtual_memmap_init() can call memmap_init() several times for the same
      memory range. It was fixed.

-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
