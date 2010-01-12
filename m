Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 237626B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:10:56 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C2Aqar001325
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Jan 2010 11:10:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C955A45DE4E
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:10:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AF81045DE4F
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:10:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F5C51DB803A
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:10:52 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A1831DB8038
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:10:52 +0900 (JST)
Date: Tue, 12 Jan 2010 11:07:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
 memory free
Message-Id: <20100112110740.54813cf6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B4BD849.7050007@gmail.com>
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com>
	<1263191277-30373-1-git-send-email-shijie8@gmail.com>
	<20100111153802.f3150117.minchan.kim@barrios-desktop>
	<20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com>
	<4B4BD849.7050007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jan 2010 10:02:49 +0800
Huang Shijie <shijie8@gmail.com> wrote:

> 
> >> Thanks, Huang.
> >>
> >> Frankly speaking, I am not sure this ir right way.
> >> This patch is adding to fine-grained locking overhead
> >>
> >> As you know, this functions are one of hot pathes.
> >> In addition, we didn't see the any problem, until now.
> >> It means out of synchronization in ZONE_ALL_UNRECLAIMABLE
> >> and pages_scanned are all right?
> >>
> >> If it is, we can move them out of zone->lock, too.
> >> If it isn't, we need one more lock, then.
> >>
> >>      
> > I don't want to see additional spin_lock, here.
> >    
> I don't want it either.
> > About ZONE_ALL_UNRECLAIMABLE, it's not necessary to be handled in atomic way.
> > If you have concerns with other flags, please modify this with single word,
> > instead of a bit field.
> >
> >    
> How about the `pages_scanned' ?
> It's protected by the zone->lru_lock in shrink_{in}active_list().
> 
Zero-clear by page-scanned is done by a write (atomic). Then, possible race
will be this update,

	zone->pages_scanend += scanned;

And failing to reset the number. But, IMHO, failure to reset this counter
is not a big problem. We'll finally reset this when we free the next
page. So, I have no concerns about resetting this counter.

My only concern is race with other flags.

Thanks,
-Kame


  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
