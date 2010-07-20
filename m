Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 201E26006B4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 20:09:24 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6K09Y7D015858
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Jul 2010 09:09:35 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A6A2C45DE4F
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 09:09:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8931845DE4C
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 09:09:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 604C01DB8017
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 09:09:34 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 11E231DB8014
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 09:09:34 +0900 (JST)
Date: Tue, 20 Jul 2010 09:04:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v2
Message-Id: <20100720090440.b7f85b8a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1279448311-29788-1-git-send-email-minchan.kim@gmail.com>
References: <1279448311-29788-1-git-send-email-minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Sun, 18 Jul 2010 19:18:31 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Kukjin reported oops happen while he change min_free_kbytes
> http://www.spinics.net/lists/arm-kernel/msg92894.html
> It happen by memory map on sparsemem.
> 
> The system has a memory map following as. 
>      section 0             section 1              section 2
> 0x20000000-0x25000000, 0x40000000-0x50000000, 0x50000000-0x58000000
> SECTION_SIZE_BITS 28(256M)
> 
> It means section 0 is an incompletely filled section.
> Nontheless, current pfn_valid of sparsemem checks pfn loosely. 
> It checks only mem_section's validation but ARM can free mem_map on hole 
> to save memory space. So in above case, pfn on 0x25000000 can pass pfn_valid's 
> validation check. It's not what we want. 
> 
> We can match section size to smallest valid size.(ex, above case, 16M)
> But Russell doesn't like it due to mem_section's memory overhead with different
> configuration(ex, 512K section).
> 
> I tried to add valid pfn range in mem_section but everyone doesn't like it 
> due to size overhead. This patch is suggested by KAMEZAWA-san. 
> I just fixed compile error and change some naming. 
> 
> This patch registers address of mem_section to memmap itself's page struct's
> pg->private field. This means the page is used for memmap of the section.
> Otherwise, the page is used for other purpose and memmap has a hole.
> 
> This patch is based on mmotm-2010-07-01-12-19.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reported-by: Kukjin Kim <kgene.kim@samsung.com>

Thank you for working on this. I myself like this solution.
I think ARM guys can make this default later (after rc period ?)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
