Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAH6t2TU009840
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 17 Nov 2008 15:55:02 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 535532AEA82
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 15:55:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 889481EF081
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 15:54:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 688FD1DB803A
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 15:54:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EF9A61DB8045
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 15:54:58 +0900 (JST)
Date: Mon, 17 Nov 2008 15:54:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: evict streaming IO cache first
Message-Id: <20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com>
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081115210039.537f59f5.akpm@linux-foundation.org>
	<alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
	<49208E9A.5080801@redhat.com>
	<20081116204720.1b8cbe18.akpm@linux-foundation.org>
	<20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Nov 2008 15:39:20 +0900
"KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com> wrote:

> rewote by div to mul changing.
> 
> 
>                         file               recent scanned.
>   %file = IO_cost * ------------ * -------------
>                      anon + file       recent rotated.
> 
> 
Ah, sorry.

> > But when "files are used by streaming or some touch once application",
> > there is no rotation because they are in INACTIVE FILE at first add_to_lru().
> > But recent_rotated will not increase while recent_scanned goes bigger and bigger.
> 
> Yup.
> 
> > Then %file goes to 0 rapidly.
> 
> I think reverse.
> 
> The problem is, when streaming access started right after, recent
> scanned isn't so much.
> then %file don't reach 100%.
> 
> then, few anon pages swaped out althouth memory pressure isn't so heavy.
> 
"few" ? 
85Mbytes of used swap while 1.2GBytes of free memory in Gene Heskett's report.
Hmm..

How about resetting zone->recent_scanned/rotated to be some value calculated from
INACTIVE_ANON/INACTIVE_FILE at some time (when the system is enough idle) ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
