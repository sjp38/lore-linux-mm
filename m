Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19A276B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 15:05:11 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y7so9354673wrc.7
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 12:05:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s62si93439wms.146.2017.02.09.12.05.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 12:05:09 -0800 (PST)
Date: Thu, 9 Feb 2017 21:05:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3 staging-next] mm: Remove RCU and tasklocks from lmk
Message-ID: <20170209200507.GE31906@dhcp22.suse.cz>
References: <6d83fb15-db88-52d3-bc24-2dd8b6d9b614@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6d83fb15-db88-52d3-bc24-2dd8b6d9b614@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Thu 09-02-17 14:21:52, peter enderborg wrote:
> Fundamental changes:
> 1 Does NOT take any RCU lock in shrinker functions.
> 2 It returns same result for scan and counts, so  we dont need to do
>   shinker will know when it is pointless to call scan.
> 3 It does not lock any other process than the one that is
>   going to be killed.
> 
> Background.
> The low memory killer scans for process that can be killed to free
> memory. This can be cpu consuming when there is a high demand for
> memory. This can be seen by analysing the kswapd0 task work.
> The stats function added in earler patch adds a counter for waste work.
> 
> How it works.
> This patch create a structure within the lowmemory killer that caches
> the user spaces processes that it might kill. It is done with a
> sorted rbtree so we can very easy find the candidate to be killed,
> and knows its properies as memory usage and sorted by oom_score_adj
> to look up the task with highest oom_score_adj. To be able to achive
> this it uses oom_score_notify events.
> 
> This patch also as a other effect, we are now free to do other
> lowmemorykiller configurations.  Without the patch there is a need
> for a tradeoff between freed memory and task and rcu locks. This
> is no longer a concern for tuning lmk. This patch is not intended
> to do any calculation changes other than we do use the cache for
> calculate the count values and that makes kswapd0 to shrink other
> areas.

I have to admit I really do not understand big part of the above
paragraph as well as how this all is supposed to work. A quick glance
over the implementation. __lmk_task_insert seems to be only called from
the oom_score notifier context. If nobody updates the value then no task
will get into the tree. Or am I missing something really obvious here?
Moreover oom scores tend to be mostly same for tasks. That means that
your sorted tree will become sorted by pids in most cases. I do not see
any sorting based on the rss nor any updates that would reflect updates
of rss. How can this possibly work?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
