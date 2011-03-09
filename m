Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E96D38D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 00:43:37 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 812463EE0BB
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:43:33 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 668AC45DE4E
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:43:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4637645DE6C
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:43:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B4C01DB8040
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:43:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E0C5D1DB803A
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:43:32 +0900 (JST)
Date: Wed, 9 Mar 2011 14:37:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in
 all_unreclaimable()
Message-Id: <20110309143704.194e8ee1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTinDhorLusBju=Gn3bh1VsH1jrv0qixbU3SGWiqa@mail.gmail.com>
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>
	<20110305152056.GA1918@barrios-desktop>
	<4D72580D.4000208@gmail.com>
	<20110305155316.GB1918@barrios-desktop>
	<4D7267B6.6020406@gmail.com>
	<20110305170759.GC1918@barrios-desktop>
	<20110307135831.9e0d7eaa.akpm@linux-foundation.org>
	<AANLkTinDhorLusBju=Gn3bh1VsH1jrv0qixbU3SGWiqa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrew Vagin <avagin@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 8 Mar 2011 08:45:51 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Tue, Mar 8, 2011 at 6:58 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Sun, 6 Mar 2011 02:07:59 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> > Any alternative proposals? A We should get the livelock fixed if possible..
> >
> 
> And we should avoid unnecessary OOM kill if possible.
> 
> I think the problem is caused by (zone->pages_scanned <
> zone_reclaimable_pages(zone) * 6). I am not sure (* 6) is a best. It
> would be rather big on recent big DRAM machines.
> 

It means 3 times full-scan from the highest priority to the lowest
and cannot freed any pages. I think big memory machine tend to have
more cpus, so don't think it's big.

> I think it is a trade-off between latency and OOM kill.
> If we decrease the magic value, maybe we should prevent the almost
> livelock but happens unnecessary OOM kill.
> 

Hmm, should I support a sacrifice feature 'some signal(SIGINT?) will be sent by
the kernel when it detects system memory is in short' in cgroup ?
(For example, if full LRU scan is done in a zone, notifier
 works and SIGINT will be sent.)

> And I think zone_reclaimable not fair.
> For example, too many scanning makes reclaimable state to
> unreclaimable state. Maybe it takes a very long time. But just some
> page free makes unreclaimable state to reclaimabe with very easy. So
> we need much painful reclaiming for changing reclaimable state with
> unreclaimabe state. it would affect latency very much.
> 
> Maybe we need more smart zone_reclaimabe which is adaptive with memory pressure.
> 
I agree.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
