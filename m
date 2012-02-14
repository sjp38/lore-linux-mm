Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 59C536B13F1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 05:19:37 -0500 (EST)
Date: Tue, 14 Feb 2012 10:19:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
Message-ID: <20120214101931.GB5938@suse.de>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
 <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
 <20120210114706.GA4704@localhost>
 <20120211124445.GA10826@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120211124445.GA10826@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Sat, Feb 11, 2012 at 08:44:45PM +0800, Wu Fengguang wrote:
> <SNIP>
> --- linux.orig/mm/vmscan.c	2012-02-03 21:42:21.000000000 +0800
> +++ linux/mm/vmscan.c	2012-02-11 17:28:54.000000000 +0800
> @@ -813,6 +813,8 @@ static unsigned long shrink_page_list(st
>  
>  		if (PageWriteback(page)) {
>  			nr_writeback++;
> +			if (PageReclaim(page))
> +				congestion_wait(BLK_RW_ASYNC, HZ/10);
>  			/*
>  			 * Synchronous reclaim cannot queue pages for
>  			 * writeback due to the possibility of stack overflow

I didn't look closely at the rest of the patch, I'm just focusing on the
congestion_wait part. You called this out yourself but this is in fact
really really bad. If this is in place and a user copies a large amount of
data to slow storage like a USB stick, the system will stall severely. A
parallel streaming reader will certainly have major issues as it will enter
page reclaim, find a bunch of dirty USB-backed pages at the end of the LRU
(20% of memory potentially) and stall for HZ/10 on each one of them. How
badly each process is affected will vary.

For the OOM problem, a more reasonable stopgap might be to identify when
a process is scanning a memcg at high priority and encountered all
PageReclaim with no forward progress and to congestion_wait() if that
situation occurs. A preferable way would be to wait until the flusher
wakes up a waiter on PageReclaim pages to be written out because we want
to keep moving way from congestion_wait() if at all possible.

Another possibility would be to relook at LRU_IMMEDIATE but right now it
requires a page flag and I haven't devised a way around that. Besides,
it would only address the problem of PageREclaim pages being encountered,
it would not handle the case where a memcg was filled with PageReclaim pages.


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
