Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0AAD882F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 06:29:07 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so120670482pab.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 03:29:06 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q1si17091223par.200.2015.11.06.03.29.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Nov 2015 03:29:05 -0800 (PST)
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20151029022447.GB27115@mtj.duckdns.org>
	<20151029030822.GD27115@mtj.duckdns.org>
	<alpine.DEB.2.20.1510292000340.30861@east.gentwo.org>
	<201510311143.BIH87000.tOSVFHOFJMLFOQ@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.20.1511021011460.27740@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.20.1511021011460.27740@east.gentwo.org>
Message-Id: <201511062028.DFE13506.MtVSOOFJLFOHQF@I-love.SAKURA.ne.jp>
Date: Fri, 6 Nov 2015 20:28:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: htejun@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

Christoph Lameter wrote:
> On Sat, 31 Oct 2015, Tetsuo Handa wrote:
> 
> > Then, you need to update below description (or drop it) because
> > patch 3/3 alone will not guarantee that the counters are up to date.
> 
> The vmstat system does not guarantee that the counters are up to date
> always. The whole point is the deferral of updates for performance
> reasons. They are updated *at some point* within stat_interval. That needs
> to happen and that is what this patchset is fixing.

So, if you refer to the blocking of the execution of vmstat updates,
description for patch 3/3 sould be updated to something like below?

----------
Since __GFP_WAIT memory allocations do not call schedule()
when there is nothing to reclaim, and workqueue does not kick
remaining workqueue items unless in-flight workqueue item calls
schedule(), __GFP_WAIT memory allocation requests by workqueue
items can block vmstat_update work item forever.

Since zone_reclaimable() decision depends on vmstat counters
to be up to dated, a silent lockup occurs because a workqueue
item doing a __GFP_WAIT memory allocation request continues
using outdated vmstat counters.

In order to fix this problem, we need to allocate a dedicated
workqueue for vmstat. Note that this patch itself does not fix
lockup problem. Tejun will develop a patch which detects lockup
situation and kick remaining workqueue items.
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
