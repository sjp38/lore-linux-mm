Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 62E156B016B
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:48:21 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p9DKmGj2004572
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:48:17 -0700
Received: from pzk34 (pzk34.prod.google.com [10.243.19.162])
	by wpaz29.hot.corp.google.com with ESMTP id p9DKjUdH009991
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:48:15 -0700
Received: by pzk34 with SMTP id 34so4986397pzk.10
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:48:15 -0700 (PDT)
Date: Thu, 13 Oct 2011 13:48:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB516D459@USINDEVS02.corp.hds.com>
Message-ID: <alpine.DEB.2.00.1110131337580.24853@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com> <alpine.DEB.2.00.1110111612120.5236@chino.kir.corp.google.com> <65795E11DBF1E645A09CEC7EAEE94B9CB516D459@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu, 13 Oct 2011, Satoru Moriya wrote:

> My test case is just a simple one (maybe too simple), and I tried
> to demonstrate following issues that current kernel has with it.
> 
> 1. Current kernel uses free memory as pagecache.
> 2. Applications may allocate memory burstly and when it happens
>    they may get a latency issue because there are not enough free
>    memory. Also the amount of required memory is wide-ranging.

This is what the per-zone watermarks are intended to address and I 
understand that it's not doing a good enough job for your particular 
workloads.  I'm trying to find a solution that mitigates that for all 
threads that allocate faster than the kernel can reclaim, realtime or 
otherwise, without requiring the admin to set those watermarks himself, 
which is really what extra_free_kbytes is eventually leading to.

> 3. Some users would like to control the amount of free memory
>    to avoid the situation above.

The only possible way to do that is with min_free_kbytes right now and 
that would increase the amount of memory that realtime threads have 
exclusive access to.  Let's try not to add additional tunables so that 
admins need to find their own optimal watermarks for every kernel release.  
I see no reason why we can't add logic for rt-threads triggering reclaim 
to either reclaim faster (Con's patch) or more memory than normal (an 
ALLOC_HARDER type bonus in the reclaim path to reclaim 1.25 * high_wmark, 
for example).  We've had a rt-thread bonus in the page allocator for a 
long time, I'm not saying we don't need more elsewhere.

> 4. User can't setup the amount of free memory explicitly.
>    From user's point of view, the amount of free memory is the delta
>    between high watermark - min watermark because below min watermark
>    user applications incur a penalty (direct reclaim). The width of
>    delta depends on min_free_kbytes, actually min watermark / 2, and
>    so if we want to make free memory bigger, we must make
>    min_free_kbytes bigger. It's not a intuitive and it introduces
>    another problem that is possibility of direct reclaim is increased.
> 

So you're saying that we need to increase the space between high_wmark and 
min_wmark anytime that min_free_kbytes changes?  That certainly may be 
true and would hopefully mitigate direct reclaim becoming too intrusive 
for your workload.

We _really_ don't want to cause regressions for others, though, which 
extra_free_kbytes can easily do for cpu-intensive workloads if nothing is 
currently requiring that extra burst of memory (and occurs because 
extra_free_kbytes is a global tunable and not tied to any specific 
application [like testing for rt_task()] that we can identify when 
reclaiming).

> But my concern described above is still alive because whether
> latency issue happen or not depends on how heavily workloads
> allocate memory at a short time. Of cource we can say same
> things for extra_free_kbytes, but we can change it and test
> an effect easily.
> 

We'll never know the future and how much memory a latency-sensitive 
application will require 100ms from now.  The only thing that we can do is 
(i) identify the latency-sensitive app, (ii) reclaim more aggressively for 
them, and (iii) reclaim additional memory in preparation for another 
burst.  At some point, though, userspace needs to be responsible to not 
allocate enormous amounts of memory all at once and there's room for 
mitigation there too to preallocate ahead of what you actually need.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
