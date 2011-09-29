Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B64929000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 01:41:07 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F3EFE3EE0BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 14:41:03 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D538145DF4B
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 14:41:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B56FB45DE80
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 14:41:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A78891DB803B
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 14:41:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 61DBE1DB803E
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 14:41:03 +0900 (JST)
Date: Thu, 29 Sep 2011 14:40:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] kstaled: documentation and config option.
Message-Id: <20110929144015.e24eeeff.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CANN689G_ZT+M4XU+R-d+imDghO4DnvYsS3+=2G2B_5ioh=U7=w@mail.gmail.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-3-git-send-email-walken@google.com>
	<20110928155302.ca394980.kamezawa.hiroyu@jp.fujitsu.com>
	<CANN689G_ZT+M4XU+R-d+imDghO4DnvYsS3+=2G2B_5ioh=U7=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Wed, 28 Sep 2011 16:48:44 -0700
Michel Lespinasse <walken@google.com> wrote:

> On Tue, Sep 27, 2011 at 11:53 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 27 Sep 2011 17:49:00 -0700
> > Michel Lespinasse <walken@google.com> wrote:
> >> +* idle_2_clean, idle_2_dirty_file, idle_2_dirty_swap: same definitions as
> >> + A above, but for pages that have been untouched for at least two scan cycles.
> >> +* these fields repeat up to idle_240_clean, idle_240_dirty_file and
> >> + A idle_240_dirty_swap, allowing one to observe idle pages over a variety
> >> + A of idle interval lengths. Note that the accounting is cumulative:
> >> + A pages counted as idle for a given interval length are also counted
> >> + A as idle for smaller interval lengths.
> >
> > I'm sorry if you've answered already.
> >
> > Why 240 ? and above means we have idle_xxx_clean/dirty/ xxx is 'seq 2 240' ?
> > Isn't it messy ? Anyway, idle_1_clean etc should be provided.
> 
> We don't have all values - we export values for 1, 2, 5, 15, 30, 60,
> 120 and 240 idle scan intervals.
> In our production setup, the scan interval is set at 120 seconds.
> The exported histogram values are chosen so that each is approximately
> double as the previous, and they align with human units i.e. 30 scan
> intervals == 1 hour.
> We use one byte per page to track the number of idle cycles, which is
> why we don't export anything over 255 scan intervals
> 

If LRU is divided into 1,2,5,15,30,60,120,240 intervals, ok, I think having
this statistics in the kernel means something..
Do you have any plan to using the aging value for global LRU scheduling ?


BTW, how about having 'aging' and 'histgram' on demand ?

Now, you do all scan by a thread and does aging by counter. But having
   - scan thread per interval
   - alloc bitmap (for PG_young, PG_idle) per scan thread.
will allow you to have arbitrary scan_interval/histgram and to avoid
to have unnecessary data.
 
Then, the users can get the histgram they want. Users will be able to
get 12h, 24h histgram. But each threads will use 2bit per pages.

Off topic:
you allocated 'aging' array in pgdat. please allocate it per secion
if CONFIG_SPARSEMEM. Then, you can handle memory hotplug easily.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
