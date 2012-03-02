Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 807326B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 03:05:04 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 68F1C3EE0C0
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 17:05:02 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4771245DE5A
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 17:05:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F40D645DE5B
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 17:05:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB3DA1DB8064
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 17:05:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5251B1DB8056
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 17:05:01 +0900 (JST)
Date: Fri, 2 Mar 2012 17:03:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] mm: rework reclaim_stat counters
Message-Id: <20120302170328.37f42337.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F506486.4090204@openvz.org>
References: <20120229090748.29236.35489.stgit@zurg>
	<20120229091556.29236.96896.stgit@zurg>
	<20120302142825.cd583b59.kamezawa.hiroyu@jp.fujitsu.com>
	<4F506486.4090204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 02 Mar 2012 10:11:18 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Wed, 29 Feb 2012 13:15:56 +0400
> > Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
> >
> >> Currently there is two types of reclaim-stat counters:
> >> recent_scanned (pages picked from from lru),
> >> recent_rotated (pages putted back to active lru).
> >> Reclaimer uses ratio recent_rotated / recent_scanned
> >> for balancing pressure between file and anon pages.
> >>
> >> But if we pick page from lru we can either reclaim it or put it back to lru, thus:
> >> recent_scanned == recent_rotated[inactive] + recent_rotated[active] + reclaimed
> >> This can be called "The Law of Conservation of Memory" =)
> >>
> > I'm sorry....where is the count for active->incative ?
> 
> If reclaimer deactivates page it will bump recent_rotated[LRU_INACTIVE_ANON/FILE],
> (if I understand your question right) recent_rotated[] now count each evictable lru independently
> 

Hm, then

	active -> active   : recent_rotated[active]   += 1 
	active -> inactive : recent_rotated[inacitve] += 1
	inactive->inactive : recent_rotated[inactive] += 1
	inactive->active   : recent_rotated[active]   += 1 ?

Ok, it seems rotated[active] + rotated[inactive] == scan.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
