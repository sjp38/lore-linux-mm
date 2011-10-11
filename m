Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A35B36B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 17:04:59 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p9BL4tHA023851
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 14:04:55 -0700
Received: from qap1 (qap1.prod.google.com [10.224.4.1])
	by wpaz21.hot.corp.google.com with ESMTP id p9BL3MLD003445
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 14:04:54 -0700
Received: by qap1 with SMTP id 1so31620qap.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2011 14:04:49 -0700 (PDT)
Date: Tue, 11 Oct 2011 14:04:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB516CBBC@USINDEVS02.corp.hds.com>
Message-ID: <alpine.DEB.2.00.1110111343070.29761@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBBC@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Tue, 11 Oct 2011, Satoru Moriya wrote:

> > I also
> > think that it will cause regressions on other cpu intensive workloads 
> > that don't require this extra freed memory because it works as a 
> > global heuristic and is not tied to any specific application.
> 
> It's yes and no. It may cause regressions on the workloads due to
> less amount of available memory. But it may improve the workloads'
> performance because they can avoid direct reclaim due to extra
> free memory.
> 

There's only a memory-availability regression if background reclaim is 
actually triggered in the first place, i.e. extra_free_kbytes doesn't 
affect the watermarks themselves when reclaim is started but rather causes 
it to, when set, reclaim more memory than otherwise.

That's not really what I was referring to; I was referring to cpu 
intensive workloads that now incur a regression because kswapd is now 
doing more work (potentially a significant amount of work since 
extra_free_kbytes is unbounded) on shared machines.  These applications 
may not be allocating memory at all and now they incur a performance 
penalty because kswapd is taking away one of their cores.

In other words, I think it's a fine solution if you're running a single 
application with very bursty memory allocations so you need to reclaim 
more memory when low, but that solution is troublesome if it comes at 
the penalty of other applications and that's a direct consequence of it 
being a global tunable.  I'd much rather identify memory allocations in 
the kernel that causing the pain here and mitigate it by (i) attempting to 
sanely rate limit those allocations, (ii) preallocate at least a partial 
amount of those allocations ahead of time so avoid significant reclaim 
all at one, or (iii) annotate memory allocations with such potential so 
that the page allocator can add this reclaim bonus itself only in these 
conditions.

> Of course if one doesn't need extra free memory, one can turn it
> off. I think we can add this feature to cgroup if we want to set
> it for any specific process or process group. (Before that we
> need to implement min_free_kbytes for cgroup and the implementation
> of extra free kbytes strongly depends on it.)
> 

That would allow you to only reclaim additional memory when certain 
applications tirgger it, but it's not actually a solution since another 
task can hit a zone's low watermark and kick kswapd and then the bursty 
memory allocations happen immediately following that and doesn't actually 
do anything because kswapd was already running.  So I disagree, as I did 
when per-cgroup watermark tunables were proposed, that watermarks should 
be changed for a subset of applications unless you guarantee memory 
isolation such that that subset of applications has exclusive access to 
the memory zones being tuned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
