Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5BD026B0092
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 20:01:22 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 880CE3EE0B5
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 10:01:20 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C31345DE69
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 10:01:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5266445DD74
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 10:01:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E2641DB8040
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 10:01:20 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0611E1DB803A
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 10:01:20 +0900 (JST)
Date: Thu, 6 Jan 2011 09:55:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3]mm/oom-kill: direct hardware access processes should
 get bonus
Message-Id: <20110106095528.a8e12526.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4D22E0CF.8000307@leadcoretech.com>
References: <1288662213.10103.2.camel@localhost.localdomain>
	<1289305468.10699.2.camel@localhost.localdomain>
	<1289402093.10699.25.camel@localhost.localdomain>
	<1289402666.10699.28.camel@localhost.localdomain>
	<4D22D190.1080706@leadcoretech.com>
	<20110104172833.1ff20b41.kamezawa.hiroyu@jp.fujitsu.com>
	<4D22E0CF.8000307@leadcoretech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Cc: lkml <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Figo.zhang" <figo1802@gmail.com>, "rientjes@google.com" <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 04 Jan 2011 16:56:47 +0800
"Figo.zhang" <zhangtianfei@leadcoretech.com> wrote:

> On 01/04/2011 04:28 PM, KAMEZAWA Hiroyuki wrote:
> > On Tue, 04 Jan 2011 15:51:44 +0800
> > "Figo.zhang"<zhangtianfei@leadcoretech.com>  wrote:
> >
> >>
> >> i had send the patch to protect the hardware access processes for
> >> oom-killer before, but rientjes have not agree with me.
> >>
> >> but today i catch log from my desktop. oom-killer have kill my "minicom"
> >> and "Xorg". so i think it should add protection about it.
> >>
> >
> > Off topic.
> >
> > In this log, I found
> >
> >>> Jan  4 15:22:55 figo-desktop kernel: Free swap  = -1636kB
> >>> Jan  4 15:22:55 figo-desktop kernel: Total swap = 0kB
> >>> Jan  4 15:22:55 figo-desktop kernel: 515070 pages RAM
> >
> > ... This means total_swap_pages = 0 while pages are read-in at swapoff.
> >
> > Let's see 'points' for oom
> > ==
> > points = (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS)) * 1000 /
> >                          totalpages;
> > ==
> >
> > Here, totalpages = total_ram + total_swap but totalswap is 0 here.
> >
> > So, points can be>  1000, easily.
> > (This seems not to be related to the Xorg's death itself)
> 
> total_swap is 0, so
> totalpages = total_ram,
> get_mm_counter(p->mm, MM_SWAPENTS) = 0,
> 
> so
> points = (get_mm_rss(p->mm)) * 1000 / totalpages;
> 
> so points canot larger than 1000.

mm_counter's swap count is reduced only when swapents are removed from
page table. But total_swap is reduced to be 0 before try_to_unuse().


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
