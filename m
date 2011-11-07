Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 80D006B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2011 21:35:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5CD8E3EE0C1
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:35:22 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 40DA045DE4E
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:35:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BEA845DE6B
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:35:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 025AF1DB803A
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:35:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BAE9B1DB8044
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:35:21 +0900 (JST)
Date: Mon, 7 Nov 2011 11:34:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc 2/3] mm: vmscan: treat inactive cycling as neutral
Message-Id: <20111107113417.1b7581a5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111102163213.GI19965@redhat.com>
References: <20110808110658.31053.55013.stgit@localhost6>
	<CAOJsxLF909NRC2r6RL+hm1ARve+3mA6UM_CY9epJaauyqJTG8w@mail.gmail.com>
	<4E3FD403.6000400@parallels.com>
	<20111102163056.GG19965@redhat.com>
	<20111102163213.GI19965@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@parallels.com>, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Gene Heskett <gene.heskett@gmail.com>

On Wed, 2 Nov 2011 17:32:13 +0100
Johannes Weiner <jweiner@redhat.com> wrote:

> Each page that is scanned but put back to the inactive list is counted
> as a successful reclaim, which tips the balance between file and anon
> lists more towards the cycling list.
> 
> This does - in my opinion - not make too much sense, but at the same
> time it was not much of a problem, as the conditions that lead to an
> inactive list cycle were mostly temporary - locked page, concurrent
> page table changes, backing device congested - or at least limited to
> a single reclaimer that was not allowed to unmap or meddle with IO.
> More important than being moderately rare, those conditions should
> apply to both anon and mapped file pages equally and balance out in
> the end.
> 
> Recently, we started cycling file pages in particular on the inactive
> list much more aggressively, for used-once detection of mapped pages,
> and when avoiding writeback from direct reclaim.
> 
> Those rotated pages do not exactly speak for the reclaimability of the
> list they sit on and we risk putting immense pressure on file list for
> no good reason.
> 
> Instead, count each page not reclaimed and put back to any list,
> active or inactive, as rotated, so they are neutral with respect to
> the scan/rotate ratio of the list class, as they should be.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

I think this makes sense.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I wonder it may be better to have victim list for written-backed pages..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
