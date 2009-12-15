Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 08FB86B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:54:55 -0500 (EST)
Received: by ywh3 with SMTP id 3so490029ywh.22
        for <linux-mm@kvack.org>; Tue, 15 Dec 2009 15:54:53 -0800 (PST)
Date: Wed, 16 Dec 2009 08:48:59 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [mmotm][PATCH 2/5] mm : avoid  false sharing on mm_counter
Message-Id: <20091216084859.a93c9727.minchan.kim@barrios-desktop>
In-Reply-To: <alpine.DEB.2.00.0912150920160.16754@router.home>
References: <20091215180904.c307629f.kamezawa.hiroyu@jp.fujitsu.com>
	<20091215181337.1c4f638d.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0912150920160.16754@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Hi, Christoph. 

On Tue, 15 Dec 2009 09:25:01 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Tue, 15 Dec 2009, KAMEZAWA Hiroyuki wrote:
> 
> >  #if USE_SPLIT_PTLOCKS
> > +#define SPLIT_RSS_COUNTING
> >  struct mm_rss_stat {
> >  	atomic_long_t count[NR_MM_COUNTERS];
> >  };
> > +/* per-thread cached information, */
> > +struct task_rss_stat {
> > +	int events;	/* for synchronization threshold */
> 
> Why count events? Just always increment the task counters and fold them
> at appropriate points into mm_struct. Or get rid of the mm_struct counters
> and only sum them up on the fly if needed?

We are now suffering from finding appropriate points you mentioned.
That's because we want to remove read-side overhead with no regression.
So I think Kame removed schedule update hook.

Although the hooks is almost no overhead, I don't want to make mm counters
stale because it depends on schedule point.
If any process makes many faults in its time slice and it's not preempted
(ex, RT) as extreme case, we could show stale counters. 

But now it makes consistency to merge counters.
Worst case is 64. 

In this aspect, I like this idea. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
