Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 063076B0253
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 18:44:52 -0500 (EST)
Received: by wmec201 with SMTP id c201so232753887wme.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 15:44:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t11si30416019wjr.220.2015.11.24.15.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 15:44:50 -0800 (PST)
Date: Tue, 24 Nov 2015 15:44:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, vmstat: Allow WQ concurrency to discover memory
 reclaim doesn't make any progress
Message-Id: <20151124154448.ac124e62528db313279224ef@linux-foundation.org>
In-Reply-To: <1447936253-18134-1-git-send-email-mhocko@kernel.org>
References: <1447936253-18134-1-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, Cristopher Lameter <clameter@sgi.com>, Arkadiusz =?UTF-8?Q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux.com>

On Thu, 19 Nov 2015 13:30:53 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> Tetsuo Handa has reported that the system might basically livelock in OOM
> condition without triggering the OOM killer. The issue is caused by
> internal dependency of the direct reclaim on vmstat counter updates (via
> zone_reclaimable) which are performed from the workqueue context.
> If all the current workers get assigned to an allocation request,
> though, they will be looping inside the allocator trying to reclaim
> memory but zone_reclaimable can see stalled numbers so it will consider
> a zone reclaimable even though it has been scanned way too much. WQ
> concurrency logic will not consider this situation as a congested workqueue
> because it relies that worker would have to sleep in such a situation.
> This also means that it doesn't try to spawn new workers or invoke
> the rescuer thread if the one is assigned to the queue.
> 
> In order to fix this issue we need to do two things. First we have to
> let wq concurrency code know that we are in trouble so we have to do
> a short sleep. In order to prevent from issues handled by 0e093d99763e
> ("writeback: do not sleep on the congestion queue if there are no
> congested BDIs or if significant congestion is not being encountered in
> the current zone") we limit the sleep only to worker threads which are
> the ones of the interest anyway.
> 
> The second thing to do is to create a dedicated workqueue for vmstat and
> mark it WQ_MEM_RECLAIM to note it participates in the reclaim and to
> have a spare worker thread for it.

This vmstat update thing is being a problem.  Please see Joonsoo's
"mm/vmstat: retrieve more accurate vmstat value".

Joonsoo, might this patch help with that issue?

> 
> The original issue reported by Tetsuo [1] has seen multiple attempts for
> a fix. The easiest one being [2] which was targeted to the particular
> problem. There was a more general concern that looping inside the
> allocator without ever sleeping breaks the basic assumption of worker
> concurrency logic so the fix should be more general. Another attempt [3]
> therefore added a short (1 jiffy) sleep into the page allocator. This
> would, however, introduce sleeping for all callers of the page allocator
> which is not really needed. This patch tries to be a compromise and
> introduce sleeping only where it matters - for kworkers.
> 
> Even though we haven't seen bug reports in the past I would suggest
> backporting this to the stable trees. The issue is present since we have
> stopped useing congestion_wait in the retry loop because WQ concurrency
> is older as well as vmstat worqueue based refresh AFAICS.

hm, I'm reluctant.  If the patch fixes something that real people are
really hurting from then yes.  But I suspect this is just one fly-swat
amongst many.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
