Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 681CE600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 01:16:51 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o046GlSY005176
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 4 Jan 2010 15:16:48 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D64D45DE57
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:16:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 24FBA45DE4E
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:16:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 05F071DB803B
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:16:47 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B3B211DB8038
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:16:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] page allocator: fix update NR_FREE_PAGES only as necessary
In-Reply-To: <4B4186A7.5080402@gmail.com>
References: <20100104144332.96A2.A69D9226@jp.fujitsu.com> <4B4186A7.5080402@gmail.com>
Message-Id: <20100104151444.96A8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  4 Jan 2010 15:16:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> > Why can't we write following? __mod_zone_page_state() only require irq
> > disabling, it doesn't need spin lock. I think.
> >
> >
> >
> struct per_cpu_pageset {
>   .................................................
> #ifdef CONFIG_SMP
>      s8 stat_threshold;
>      s8 vm_stat_diff[NR_VM_ZONE_STAT_ITEMS];
> #endif
> } ____cacheline_aligned_in_smp;
> 
> The field 'stat_threshold' is in the CONFIG_SMP macro, does it not need 
> the spinlock? I will read the code more carefully.
> I saw the macro, so I thought it need the spinlock. :)

Generally,  per-cpu data isn't accessed from another cpu. it only need to care
process-context vs irq-context race.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
