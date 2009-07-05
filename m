Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C09DF6B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:15:29 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n65AcuZ3017297
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 5 Jul 2009 19:38:57 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 952A445DE57
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 19:38:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 66B1F45DE4F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 19:38:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 44E84E18001
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 19:38:56 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E53D21DB803C
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 19:38:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Found the commit that causes the OOMs
In-Reply-To: <20090705095520.GA31587@localhost>
References: <4A4AD07E.2040508@redhat.com> <20090705095520.GA31587@localhost>
Message-Id: <20090705193551.090E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  5 Jul 2009 19:38:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

> >> OK. thanks.
> >> I plan to submit this patch after small more tests. it is useful for OOM analysis.
> >
> > It is also useful for throttling page reclaim.
> >
> > If more than half of the inactive pages in a zone are
> > isolated, we are probably beyond the point where adding
> > additional reclaim processes will do more harm than good.
> 
> Maybe we can try limiting the isolation phase of direct reclaims to
> one per CPU?
> 
>         mutex_lock(per_cpu_lock);
>         isolate_pages();
>         shrink_page_list();
>         put_back_pages();
>         mutex_unlock(per_cpu_lock);
> 
> This way the isolated pages as well as major parts of direct reclaims
> will be bounded by CPU numbers. The added overheads should be trivial
> comparing to the reclaim costs.

hm, this idea makes performance degression on few CPU machine, I think.

e.g.
if system have only one cpu and sysmtem makes lumpy reclaim, lumpy reclaim
makes synchronous pageout and it makes very long waiting time.

I suspect per-cpu decision is not useful in this area.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
