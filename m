Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAH6Urim022970
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 17 Nov 2008 15:30:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2288F45DD74
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 15:30:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 01F1A45DD73
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 15:30:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D5C801DB803E
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 15:30:52 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 894D21DB8038
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 15:30:52 +0900 (JST)
Date: Mon, 17 Nov 2008 15:30:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: evict streaming IO cache first
Message-Id: <20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081116204720.1b8cbe18.akpm@linux-foundation.org>
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081115210039.537f59f5.akpm@linux-foundation.org>
	<alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
	<49208E9A.5080801@redhat.com>
	<20081116204720.1b8cbe18.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, 16 Nov 2008 20:47:20 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sun, 16 Nov 2008 16:20:26 -0500 Rik van Riel <riel@redhat.com> wrote:
> Anyway, we need to do something.
> 
> Shouldn't get_scan_ratio() be handling this case already?
> 
Hmm, could I make a question ?

I think

  - recent_rolated[LRU_FILE] is incremented when file cache is moved from
    ACTIVE_FILE to INACTIVE_FILE.
  - recent_scanned[LRU_FILE] is sum of scanning numbers on INACTIVE/ACTIVE list
    of file.
  - file caches are added to INACITVE_FILE, at first.
  - get_scan_ratio() calculates %file to be

                         file        recent rotated.
   %file = IO_cost * ------------ / -------------
                      anon + file    recent scanned.

But when "files are used by streaming or some touch once application",
there is no rotation because they are in INACTIVE FILE at first add_to_lru().
But recent_rotated will not increase while recent_scanned goes bigger and bigger.

Then %file goes to 0 rapidly.

Hmm?

Thanks,
-kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
