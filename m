Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5D7176B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 20:55:04 -0400 (EDT)
Message-ID: <4FEA59EE.8060804@kernel.org>
Date: Wed, 27 Jun 2012 09:55:10 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: needed lru_add_drain_all() change
References: <20120626143703.396d6d66.akpm@linux-foundation.org>
In-Reply-To: <20120626143703.396d6d66.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On 06/27/2012 06:37 AM, Andrew Morton wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=43811
> 
> lru_add_drain_all() uses schedule_on_each_cpu().  But
> schedule_on_each_cpu() hangs if a realtime thread is spinning, pinned
> to a CPU.  There's no intention to change the scheduler behaviour, so I
> think we should remove schedule_on_each_cpu() from the kernel.
> 
> The biggest user of schedule_on_each_cpu() is lru_add_drain_all().
> 
> Does anyone have any thoughts on how we can do this?  The obvious
> approach is to declare these:
> 
> static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
> static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);


One more 
static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);

> 
> to be irq-safe and use on_each_cpu().  lru_rotate_pvecs is already
> irq-safe and converting lru_add_pvecs and lru_deactivate_pvecs looks
> pretty simple.


Yes. Changing looks simple.
I'm okay with lru_[activate_page|deactivate]_pvecs because it's not hot
but lru_rotate_pvecs is hotter than others. Considering mlock and CPU pinning
of realtime thread is very rare, it might be rather expensive solution.
Unfortunately, I have no idea better than you suggested. :(

And looking 8891d6da17, mlock's lru_add_drain_all isn't must.
If it's really bother us, couldn't we remove it?



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
