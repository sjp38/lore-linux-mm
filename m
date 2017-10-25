Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE1FD6B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 10:12:25 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z55so58194wrz.2
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 07:12:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g50si1517255eda.8.2017.10.25.07.12.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 07:12:24 -0700 (PDT)
Date: Wed, 25 Oct 2017 16:12:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
References: <20171013152421.yf76n7jui3z5bbn4@dhcp22.suse.cz>
 <20171024160637.GB32340@cmpxchg.org>
 <20171024162213.n6jrpz3t5pldkgxy@dhcp22.suse.cz>
 <20171024172330.GA3973@cmpxchg.org>
 <20171024175558.uxqtxwhjgu6ceadk@dhcp22.suse.cz>
 <20171024185854.GA6154@cmpxchg.org>
 <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
 <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171025131151.GA8210@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed 25-10-17 09:11:51, Johannes Weiner wrote:
> On Wed, Oct 25, 2017 at 09:15:22AM +0200, Michal Hocko wrote:
[...]
> > ... we shouldn't make it more loose though.
> 
> Then we can end this discussion right now. I pointed out right from
> the start that the only way to replace -ENOMEM with OOM killing in the
> syscall is to force charges. If we don't, we either deadlock or still
> return -ENOMEM occasionally. Nobody has refuted that this is the case.

Yes this is true. I guess we are back to the non-failing allocations
discussion...  Currently we are too ENOMEM happy for memcg !PF paths which
can lead to weird issues Greg has pointed out earlier. Going to opposite
direction to basically never ENOMEM and rather pretend a success (which
allows runaways for extreme setups with no oom eligible tasks) sounds
like going from one extreme to another. This basically means that those
charges will effectively GFP_NOFAIL. Too much to guarantee IMHO.

> > > The current thread can loop in syscall exit until
> > > usage is reconciled (either via reclaim or kill).  This seems consistent
> > > with pagefault oom handling and compatible with overcommit use case.
> > 
> > But we do not really want to make the syscall exit path any more complex
> > or more expensive than it is. The point is that we shouldn't be afraid
> > about triggering the oom killer from the charge patch because we do have
> > async OOM killer. This is very same with the standard allocator path. So
> > why should be memcg any different?
> 
> I have nothing against triggering the OOM killer from the allocation
> path. I am dead-set against making the -ENOMEM return from syscalls
> rare and unpredictable.

Isn't that the case when we put memcg out of the picture already? More
on that below.

> They're a challenge as it is.  The only sane options are to stick with
> the status quo,

One thing that really worries me about the current status quo is that
the behavior depends on whether you run under memcg or not. The global
policy is "almost never fail unless something horrible is going on".
But we _do not_ guarantee that ENOMEM stays inside the kernel.

So if we need to do something about that I would think we need an
universal solution rather than something memcg specific. Sure global
ENOMEMs are so rare that nobody will probably trigger those but that is
just a wishful thinking...

So how about we start with a BIG FAT WARNING for the failure case?
Something resembling warn_alloc for the failure case.
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5d9323028870..3ba62c73eee5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1547,9 +1547,14 @@ static bool mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
 	 * we would fall back to the global oom killer in pagefault_out_of_memory
 	 */
-	if (!memcg->oom_kill_disable &&
-			mem_cgroup_out_of_memory(memcg, mask, order))
-		return true;
+	if (!memcg->oom_kill_disable) {
+		if (mem_cgroup_out_of_memory(memcg, mask, order))
+			return true;
+
+		WARN(!current->memcg_may_oom,
+				"Memory cgroup charge failed because of no reclaimable memory! "
+				"This looks like a misconfiguration or a kernel bug.");
+	}
 
 	if (!current->memcg_may_oom)
 		return false;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
