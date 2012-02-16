Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 28A566B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 19:02:03 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 376593EE0BD
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:02:01 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 20E4245DE59
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:02:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F17C745DE55
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:02:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E5475E08002
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:02:00 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F80F1DB803F
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:02:00 +0900 (JST)
Date: Thu, 16 Feb 2012 09:00:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
Message-Id: <20120216090037.31d04ec7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120214131812.GA17625@localhost>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
	<20120208093120.GA18993@localhost>
	<CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
	<20120210114706.GA4704@localhost>
	<20120211124445.GA10826@localhost>
	<20120214101931.GB5938@suse.de>
	<20120214131812.GA17625@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Tue, 14 Feb 2012 21:18:12 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> 
> --- linux.orig/include/linux/backing-dev.h	2012-02-14 19:43:06.000000000 +0800
> +++ linux/include/linux/backing-dev.h	2012-02-14 19:49:26.000000000 +0800
> @@ -304,6 +304,8 @@ void clear_bdi_congested(struct backing_
>  void set_bdi_congested(struct backing_dev_info *bdi, int sync);
>  long congestion_wait(int sync, long timeout);
>  long wait_iff_congested(struct zone *zone, int sync, long timeout);
> +long reclaim_wait(long timeout);
> +void reclaim_rotated(void);
>  
>  static inline bool bdi_cap_writeback_dirty(struct backing_dev_info *bdi)
>  {
> --- linux.orig/mm/backing-dev.c	2012-02-14 19:26:15.000000000 +0800
> +++ linux/mm/backing-dev.c	2012-02-14 20:09:45.000000000 +0800
> @@ -873,3 +873,38 @@ out:
>  	return ret;
>  }
>  EXPORT_SYMBOL(wait_iff_congested);
> +
> +static DECLARE_WAIT_QUEUE_HEAD(reclaim_wqh);
> +
> +/**
> + * reclaim_wait - wait for some pages being rotated to the LRU tail
> + * @timeout: timeout in jiffies
> + *
> + * Wait until @timeout, or when some (typically PG_reclaim under writeback)
> + * pages rotated to the LRU so that page reclaim can make progress.
> + */
> +long reclaim_wait(long timeout)
> +{
> +	long ret;
> +	unsigned long start = jiffies;
> +	DEFINE_WAIT(wait);
> +
> +	prepare_to_wait(&reclaim_wqh, &wait, TASK_KILLABLE);
> +	ret = io_schedule_timeout(timeout);
> +	finish_wait(&reclaim_wqh, &wait);
> +
> +	trace_writeback_reclaim_wait(jiffies_to_usecs(timeout),
> +				     jiffies_to_usecs(jiffies - start));
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(reclaim_wait);
> +
> +void reclaim_rotated()
> +{
> +	wait_queue_head_t *wqh = &reclaim_wqh;
> +
> +	if (waitqueue_active(wqh))
> +		wake_up(wqh);
> +}
> +

Thank you.

I like this approach. A nitpick is that this may wake up all waiters 
in the system when a memcg is rotated.

How about wait_event() + condition by bitmap (using per memcg unique IDs.) ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
