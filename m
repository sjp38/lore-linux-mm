Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5D4246B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 00:54:23 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3U4tCoW018578
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 30 Apr 2009 13:55:12 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F5C445DE51
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 13:55:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 257D445DE3E
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 13:55:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D35F8E08001
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 13:55:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E8DE11DB803C
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 13:55:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Swappiness vs. mmap() and interactive response
In-Reply-To: <20090429214332.a2b5b469.akpm@linux-foundation.org>
References: <20090430041439.GA6110@eskimo.com> <20090429214332.a2b5b469.akpm@linux-foundation.org>
Message-Id: <20090430135100.D21A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 30 Apr 2009 13:55:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Elladan <elladan@eskimo.com>, Theodore Tso <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Wed, 29 Apr 2009 21:14:39 -0700 Elladan <elladan@eskimo.com> wrote:
> 
> > > Elladan, have you checked to see whether the Mapped: number in
> > > /proc/meminfo is decreasing?
> > 
> > Yes, Mapped decreases while a large file copy is ongoing.  It increases again
> > if I use the GUI.
> 
> OK.  If that's still happening to an appreciable extent after you've
> increased /proc/sys/vm/swappiness then I'd wager that we have a
> bug/regression in that area.
> 
> Local variable `scan' in shrink_zone() is vulnerable to multiplicative
> overflows on large zones, but I doubt if you have enough memory to
> trigger that bug.
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Local variable `scan' can overflow on zones which are larger than
> 
> 	(2G * 4k) / 100 = 80GB.
> 
> Making it 64-bit on 64-bit will fix that up.

Agghh, thanks bugfix.

Note: His meminfo indicate his machine has 3.5GB ram. then this
patch don't fix his problem.



> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/vmscan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN mm/vmscan.c~vmscan-avoid-multiplication-overflow-in-shrink_zone mm/vmscan.c
> --- a/mm/vmscan.c~vmscan-avoid-multiplication-overflow-in-shrink_zone
> +++ a/mm/vmscan.c
> @@ -1479,7 +1479,7 @@ static void shrink_zone(int priority, st
>  
>  	for_each_evictable_lru(l) {
>  		int file = is_file_lru(l);
> -		int scan;
> +		unsigned long scan;
>  
>  		scan = zone_nr_pages(zone, sc, l);
>  		if (priority) {
> _
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
