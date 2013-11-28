Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3DEBB6B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 22:20:43 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f11so5699078yha.14
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 19:20:42 -0800 (PST)
Received: from mail-yh0-x231.google.com (mail-yh0-x231.google.com [2607:f8b0:4002:c01::231])
        by mx.google.com with ESMTPS id o35si13158559yhp.41.2013.11.27.19.20.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 19:20:42 -0800 (PST)
Received: by mail-yh0-f49.google.com with SMTP id z20so5665086yhz.8
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 19:20:41 -0800 (PST)
Date: Wed, 27 Nov 2013 19:20:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [merged] mm-memcg-handle-non-error-oom-situations-more-gracefully.patch
 removed from -mm tree
In-Reply-To: <20131128031313.GK3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311271914460.5120@chino.kir.corp.google.com>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org> <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com> <20131127233353.GH3556@cmpxchg.org> <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com> <20131128021809.GI3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com> <20131128031313.GK3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 27 Nov 2013, Johannes Weiner wrote:

> > It appears as though this work is being developed in Linus's tree rather 
> > than -mm, so I'm asking if we should consider backing some of it out for 
> > 3.14 instead.
> 
> The changes fix a deadlock problem.  Are they creating problems that
> are worse than deadlocks, that would justify their revert?
> 

None that I am currently aware of, I'll continue to try them out.  I'd 
suggest just dropping the stable@kernel.org from the whole series though 
unless there is another report of such a problem that people are running 
into.

> Since we can't physically draw a perfect line, we should strive for a
> reasonable and intuitive line.  After that it's rapidly diminishing
> returns.  Killing something after that much reclaim effort without
> success is a completely reasonable and intuitive line to draw.  It's
> also the line that has been drawn a long time ago and we're not
> breaking this because of a micro optmimization.
> 

You don't think something like this is helpful after scanning a memcg will 
a large number of processes?

We've had this patch internally since we started using memcg, it has 
avoided some unnecessary oom killing.
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1836,6 +1836,13 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (!chosen)
 		return;
 	points = chosen_points * 1000 / totalpages;
+
+	/* One last chance to see if we really need to kill something */
+	if (mem_cgroup_margin(memcg) >= (1 << order)) {
+		put_task_struct(chosen);
+		return;
+	}
+
 	oom_kill_process(chosen, gfp_mask, order, points, totalpages, memcg,
 			 NULL, "Memory cgroup out of memory");
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
