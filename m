Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C782E6B0089
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 21:02:24 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB822LRa004376
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Dec 2010 11:02:21 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 800D245DE56
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 11:02:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5879445DE5F
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 11:02:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C6E2E18001
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 11:02:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 104B31DB8038
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 11:02:21 +0900 (JST)
Date: Wed, 8 Dec 2010 10:56:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 2/7] deactivate invalidated pages
Message-Id: <20101208105637.5103de75.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTimtkb7Nczhads4u3r21RJauZvviLFkXjaL1ErDb@mail.gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<d57730effe4b48012d31ceca07938ed3eb401aba.1291568905.git.minchan.kim@gmail.com>
	<20101207144923.GB2356@cmpxchg.org>
	<20101207150710.GA26613@barrios-desktop>
	<20101207151939.GF2356@cmpxchg.org>
	<20101207152625.GB608@barrios-desktop>
	<20101207155645.GG2356@cmpxchg.org>
	<AANLkTi=iNGT_p_VfW9GxdaKXLt2xBHM2jdwmCbF_u8uh@mail.gmail.com>
	<20101208095642.8128ab33.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimtkb7Nczhads4u3r21RJauZvviLFkXjaL1ErDb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 2010 10:43:08 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi Kame,
> 
Hi,

> > I wonder ...how about adding "victim" list for "Reclaim" pages ? Then, we don't need
> > extra LRU rotation.
> 
> It can make the code clean.
> As far as I think, victim list does following as.
> 
> 1. select victim pages by strong hint
> 2. move the page from LRU to victim
> 3. reclaimer always peeks victim list before diving into LRU list.
> 4-1. If the victim pages is used by others or dirty, it can be moved
> into LRU, again or remain the page in victim list.
> If the page is remained victim, when do we move it into LRU again if
> the reclaimer continues to fail the page?
When sometone touches it.

> We have to put the new rule.
> 4-2. If the victim pages isn't used by others and clean, we can
> reclaim the page asap.
> 
> AFAIK, strong hints are just two(invalidation, readahead max window heuristic).
> I am not sure it's valuable to add new hierarchy(ie, LRU, victim,
> unevictable) for cleaning the minor codes.
> In addition, we have to put the new rule so it would make the LRU code
> complicated.
> I remember how unevictable feature merge is hard.
> 
yes, it was hard.

> But I am not against if we have more usecases. In this case, it's
> valuable to implement it although it's not easy.
> 

I wonder "victim list" can be used for something like Cleancache, when
we have very-low-latency backend devices.
And we may able to have page-cache-limit, which Balbir proposed as.

  - kvictimed? will move unmappedd page caches to victim list
This may work like a InactiveClean list which we had before and make
sizing easy.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
