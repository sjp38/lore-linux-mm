Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3235F6B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 07:22:54 -0500 (EST)
Received: by pablf10 with SMTP id lf10so27148907pab.6
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 04:22:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id zg6si459542pac.237.2015.02.23.04.22.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 04:22:52 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150220231511.GH12722@dastard>
	<20150221032000.GC7922@thunk.org>
	<20150221011907.2d26c979.akpm@linux-foundation.org>
	<20150222002058.GB25079@phnom.home.cmpxchg.org>
	<20150223104810.GD24272@dhcp22.suse.cz>
In-Reply-To: <20150223104810.GD24272@dhcp22.suse.cz>
Message-Id: <201502232023.BBG39069.SHOQLFtJFOOFMV@I-love.SAKURA.ne.jp>
Date: Mon, 23 Feb 2015 20:23:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, tytso@mit.edu, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org

Michal Hocko wrote:
> On Sat 21-02-15 19:20:58, Johannes Weiner wrote:
> > On Sat, Feb 21, 2015 at 01:19:07AM -0800, Andrew Morton wrote:
> > > Short term, we need to fix 3.19.x and 3.20 and that appears to be by
> > > applying Johannes's akpm-doesnt-know-why-it-works patch:
> > > 
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -2382,8 +2382,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> > >  		if (high_zoneidx < ZONE_NORMAL)
> > >  			goto out;
> > >  		/* The OOM killer does not compensate for light reclaim */
> > > -		if (!(gfp_mask & __GFP_FS))
> > > +		if (!(gfp_mask & __GFP_FS)) {
> > > +			/*
> > > +			 * XXX: Page reclaim didn't yield anything,
> > > +			 * and the OOM killer can't be invoked, but
> > > +			 * keep looping as per should_alloc_retry().
> > > +			 */
> > > +			*did_some_progress = 1;
> > >  			goto out;
> > > +		}
> > >  		/*
> > >  		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
> > >  		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
> > > 
> > > Have people adequately confirmed that this gets us out of trouble?
> > 
> > I'd be interested in this too.  Who is seeing these failures?

So far ext4 and xfs. I don't have environment to test other filesystems.

> > 
> > Andrew, can you please use the following changelog for this patch?
> > 
> > ---
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > mm: page_alloc: revert inadvertent !__GFP_FS retry behavior change
> > 
> > Historically, !__GFP_FS allocations were not allowed to invoke the OOM
> > killer once reclaim had failed, but nevertheless kept looping in the
> > allocator.  9879de7373fc ("mm: page_alloc: embed OOM killing naturally
> > into allocation slowpath"), which should have been a simple cleanup
> > patch, accidentally changed the behavior to aborting the allocation at
> > that point.  This creates problems with filesystem callers (?) that
> > currently rely on the allocator waiting for other tasks to intervene.
> > 
> > Revert the behavior as it shouldn't have been changed as part of a
> > cleanup patch.
> 
> OK, if this a _short term_ change. I really think that all the requests
> except for __GFP_NOFAIL should be able to fail. I would argue that it
> should be the caller who should be fixed but it is true that the patch
> was introduced too late (rc7) and so it caught other subsystems
> unprepared so backporting to stable makes sense to me. But can we please
> move on and stop pretending that allocations do not fail for the
> upcoming release?
> 
> > Fixes: 9879de7373fc ("mm: page_alloc: embed OOM killing naturally into allocation slowpath")
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>
> 

Without this patch, I think the system becomes unusable under OOM.
However, with this patch, I know the system may become unusable under
OOM. Please do write patches for handling below condition.

  Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Johannes's patch will get us out of filesystem error troubles, at
the cost of getting us into stall troubles (as with until 3.19-rc6).

I retested http://marc.info/?l=linux-ext4&m=142443125221571&w=2
with debug printk patch shown below.

---------- debug printk patch ----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d503e9c..5144506 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -610,6 +610,8 @@ void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_mask)
 	spin_unlock(&zone_scan_lock);
 }
 
+atomic_t oom_killer_skipped_count = ATOMIC_INIT(0);
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @zonelist: zonelist pointer
@@ -679,6 +681,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 				 nodemask, "Out of memory");
 		killed = 1;
 	}
+	else
+		atomic_inc(&oom_killer_skipped_count);
 out:
 	/*
 	 * Give the killed threads a good chance of exiting before trying to
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8e20f9c..eaea16b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2382,8 +2382,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		if (high_zoneidx < ZONE_NORMAL)
 			goto out;
 		/* The OOM killer does not compensate for light reclaim */
-		if (!(gfp_mask & __GFP_FS))
+		if (!(gfp_mask & __GFP_FS)) {
+			/*
+			 * XXX: Page reclaim didn't yield anything,
+			 * and the OOM killer can't be invoked, but
+			 * keep looping as per should_alloc_retry().
+			 */
+			*did_some_progress = 1;
 			goto out;
+		}
 		/*
 		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
 		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.
@@ -2635,6 +2642,8 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
 }
 
+extern atomic_t oom_killer_skipped_count;
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
@@ -2649,6 +2658,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	unsigned long first_retried_time = 0;
+	unsigned long next_warn_time = 0;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -2821,6 +2832,19 @@ retry:
 			if (!did_some_progress)
 				goto nopage;
 		}
+		if (!first_retried_time) {
+			first_retried_time = jiffies;
+			if (!first_retried_time)
+				first_retried_time = 1;
+			next_warn_time = first_retried_time + 5 * HZ;
+		} else if (time_after(jiffies, next_warn_time)) {
+			printk(KERN_INFO "%d (%s) : gfp 0x%X : %lu seconds : "
+			       "OOM-killer skipped %u\n", current->pid,
+			       current->comm, gfp_mask,
+			       (jiffies - first_retried_time) / HZ,
+			       atomic_read(&oom_killer_skipped_count));
+			next_warn_time = jiffies + 5 * HZ;
+		}
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto retry;
---------- debug printk patch ----------

GFP_NOFS allocations stalled for 10 minutes waiting for somebody else
to volunteer memory. GFP_FS allocations stalled for 10 minutes waiting
for the OOM killer to kill somebody. The OOM killer stalled for 10
minutes waiting for GFP_NOFS allocations to complete.

I guess the system made forward progress because the number of remaining
a.out processes decreased over time.

(From http://I-love.SAKURA.ne.jp/tmp/serial-20150223-3.19-ext4-patched.txt.xz )
---------- ext4 / Linux 3.19 + patch ----------
[ 1335.187579] Out of memory: Kill process 14156 (a.out) score 760 or sacrifice child
[ 1335.189604] Killed process 14156 (a.out) total-vm:2167392kB, anon-rss:1360196kB, file-rss:0kB
[ 1335.191920] Kill process 14177 (a.out) sharing same memory
[ 1335.193465] Kill process 14178 (a.out) sharing same memory
[ 1335.195013] Kill process 14179 (a.out) sharing same memory
[ 1335.196580] Kill process 14180 (a.out) sharing same memory
[ 1335.198128] Kill process 14181 (a.out) sharing same memory
[ 1335.199674] Kill process 14182 (a.out) sharing same memory
[ 1335.201217] Kill process 14183 (a.out) sharing same memory
[ 1335.202768] Kill process 14184 (a.out) sharing same memory
[ 1335.204316] Kill process 14185 (a.out) sharing same memory
[ 1335.205871] Kill process 14186 (a.out) sharing same memory
[ 1335.207420] Kill process 14187 (a.out) sharing same memory
[ 1335.208974] Kill process 14188 (a.out) sharing same memory
[ 1335.210515] Kill process 14189 (a.out) sharing same memory
[ 1335.212063] Kill process 14190 (a.out) sharing same memory
[ 1335.213611] Kill process 14191 (a.out) sharing same memory
[ 1335.215165] Kill process 14192 (a.out) sharing same memory
[ 1335.216715] Kill process 14193 (a.out) sharing same memory
[ 1335.218286] Kill process 14194 (a.out) sharing same memory
[ 1335.219836] Kill process 14195 (a.out) sharing same memory
[ 1335.221378] Kill process 14196 (a.out) sharing same memory
[ 1335.222918] Kill process 14197 (a.out) sharing same memory
[ 1335.224461] Kill process 14198 (a.out) sharing same memory
[ 1335.225999] Kill process 14199 (a.out) sharing same memory
[ 1335.227545] Kill process 14200 (a.out) sharing same memory
[ 1335.229095] Kill process 14201 (a.out) sharing same memory
[ 1335.230643] Kill process 14202 (a.out) sharing same memory
[ 1335.232184] Kill process 14203 (a.out) sharing same memory
[ 1335.233738] Kill process 14204 (a.out) sharing same memory
[ 1335.235293] Kill process 14205 (a.out) sharing same memory
[ 1335.236834] Kill process 14206 (a.out) sharing same memory
[ 1335.238387] Kill process 14207 (a.out) sharing same memory
[ 1335.239930] Kill process 14208 (a.out) sharing same memory
[ 1335.241471] Kill process 14209 (a.out) sharing same memory
[ 1335.243011] Kill process 14210 (a.out) sharing same memory
[ 1335.244554] Kill process 14211 (a.out) sharing same memory
[ 1335.246101] Kill process 14212 (a.out) sharing same memory
[ 1335.247645] Kill process 14213 (a.out) sharing same memory
[ 1335.249182] Kill process 14214 (a.out) sharing same memory
[ 1335.250718] Kill process 14215 (a.out) sharing same memory
[ 1335.252305] Kill process 14216 (a.out) sharing same memory
[ 1335.253899] Kill process 14217 (a.out) sharing same memory
[ 1335.255443] Kill process 14218 (a.out) sharing same memory
[ 1335.256993] Kill process 14219 (a.out) sharing same memory
[ 1335.258531] Kill process 14220 (a.out) sharing same memory
[ 1335.260066] Kill process 14221 (a.out) sharing same memory
[ 1335.261616] Kill process 14222 (a.out) sharing same memory
[ 1335.263143] Kill process 14223 (a.out) sharing same memory
[ 1335.264647] Kill process 14224 (a.out) sharing same memory
[ 1335.266121] Kill process 14225 (a.out) sharing same memory
[ 1335.267598] Kill process 14226 (a.out) sharing same memory
[ 1335.269077] Kill process 14227 (a.out) sharing same memory
[ 1335.270560] Kill process 14228 (a.out) sharing same memory
[ 1335.272038] Kill process 14229 (a.out) sharing same memory
[ 1335.273508] Kill process 14230 (a.out) sharing same memory
[ 1335.274999] Kill process 14231 (a.out) sharing same memory
[ 1335.276469] Kill process 14232 (a.out) sharing same memory
[ 1335.277947] Kill process 14233 (a.out) sharing same memory
[ 1335.279428] Kill process 14234 (a.out) sharing same memory
[ 1335.280894] Kill process 14235 (a.out) sharing same memory
[ 1335.282361] Kill process 14236 (a.out) sharing same memory
[ 1335.283832] Kill process 14237 (a.out) sharing same memory
[ 1335.285304] Kill process 14238 (a.out) sharing same memory
[ 1335.286768] Kill process 14239 (a.out) sharing same memory
[ 1335.288242] Kill process 14240 (a.out) sharing same memory
[ 1335.289714] Kill process 14241 (a.out) sharing same memory
[ 1335.291196] Kill process 14242 (a.out) sharing same memory
[ 1335.292731] Kill process 14243 (a.out) sharing same memory
[ 1335.294258] Kill process 14244 (a.out) sharing same memory
[ 1335.295734] Kill process 14245 (a.out) sharing same memory
[ 1335.297215] Kill process 14246 (a.out) sharing same memory
[ 1335.298710] Kill process 14247 (a.out) sharing same memory
[ 1335.300188] Kill process 14248 (a.out) sharing same memory
[ 1335.301672] Kill process 14249 (a.out) sharing same memory
[ 1335.303157] Kill process 14250 (a.out) sharing same memory
[ 1335.304655] Kill process 14251 (a.out) sharing same memory
[ 1335.306141] Kill process 14252 (a.out) sharing same memory
[ 1335.307621] Kill process 14253 (a.out) sharing same memory
[ 1335.309107] Kill process 14254 (a.out) sharing same memory
[ 1335.310573] Kill process 14255 (a.out) sharing same memory
[ 1335.312052] Kill process 14256 (a.out) sharing same memory
[ 1335.313528] Kill process 14257 (a.out) sharing same memory
[ 1335.315039] Kill process 14258 (a.out) sharing same memory
[ 1335.316522] Kill process 14259 (a.out) sharing same memory
[ 1335.317992] Kill process 14260 (a.out) sharing same memory
[ 1335.319462] Kill process 14261 (a.out) sharing same memory
[ 1335.320965] Kill process 14262 (a.out) sharing same memory
[ 1335.322459] Kill process 14263 (a.out) sharing same memory
[ 1335.323958] Kill process 14264 (a.out) sharing same memory
[ 1335.325472] Kill process 14265 (a.out) sharing same memory
[ 1335.326966] Kill process 14266 (a.out) sharing same memory
[ 1335.328454] Kill process 14267 (a.out) sharing same memory
[ 1335.329945] Kill process 14268 (a.out) sharing same memory
[ 1335.331444] Kill process 14269 (a.out) sharing same memory
[ 1335.332944] Kill process 14270 (a.out) sharing same memory
[ 1335.334435] Kill process 14271 (a.out) sharing same memory
[ 1335.335930] Kill process 14272 (a.out) sharing same memory
[ 1335.337437] Kill process 14273 (a.out) sharing same memory
[ 1335.338927] Kill process 14274 (a.out) sharing same memory
[ 1335.340400] Kill process 14275 (a.out) sharing same memory
[ 1335.341890] Kill process 14276 (a.out) sharing same memory
[ 1339.640500] 464 (systemd-journal) : gfp 0x201DA : 5 seconds : OOM-killer skipped 22459181
[ 1339.649374] 615 (vmtoolsd) : gfp 0x201DA : 5 seconds : OOM-killer skipped 22459438
[ 1339.649611] 4079 (pool) : gfp 0x201DA : 5 seconds : OOM-killer skipped 22459447
[ 1340.343322] 14258 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478275
[ 1340.343331] 14194 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478275
[ 1340.343345] 14210 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478276
[ 1340.343360] 14179 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478277
[ 1340.345290] 14154 (su) : gfp 0x201DA : 5 seconds : OOM-killer skipped 22478339
[ 1340.345312] 14180 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478339
[ 1340.345319] 14260 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478339
[ 1340.345337] 14178 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478340
[ 1340.345345] 14245 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478340
[ 1340.345361] 14226 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478341
[ 1340.346119] 14256 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478368
[ 1340.346139] 14181 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478369
[ 1340.347082] 14274 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478402
[ 1340.347091] 14267 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478402
[ 1340.347095] 14189 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478402
[ 1340.347099] 14238 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478402
[ 1340.347107] 14276 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478403
[ 1340.347112] 14183 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478403
[ 1340.347397] 14254 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478413
[ 1340.347402] 14228 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478413
[ 1340.347414] 14185 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478414
[ 1340.347419] 14261 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478414
[ 1340.347423] 14217 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478414
[ 1340.347427] 14203 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478414
[ 1340.347439] 14234 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478415
[ 1340.347452] 14269 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478415
[ 1340.347461] 14255 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478416
[ 1340.347465] 14192 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478416
[ 1340.347473] 14259 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478416
[ 1340.347492] 14232 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478417
[ 1340.347497] 14223 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478417
[ 1340.347505] 14220 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478417
[ 1340.347523] 14252 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478418
[ 1340.347531] 14193 (a.out) : gfp 0x50 : 5 seconds : OOM-killer skipped 22478418
(...snipped...)
[ 1949.672951] 43 (kworker/1:1) : gfp 0x10 : 90 seconds : OOM-killer skipped 41315348
[ 1949.993045] 4079 (pool) : gfp 0x201DA : 615 seconds : OOM-killer skipped 41325108
[ 1950.694909] 14269 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41346727
[ 1950.703945] 14181 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41347003
[ 1950.742087] 14254 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41348208
[ 1950.744937] 14193 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41348299
[ 1950.748884] 2 (kthreadd) : gfp 0x2000D0 : 10 seconds : OOM-killer skipped 41348418
[ 1950.751565] 14203 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41348502
[ 1950.756955] 14232 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41348656
[ 1950.776918] 14185 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41349279
[ 1950.791214] 14217 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41349720
[ 1950.798961] 14179 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41349957
[ 1950.806551] 14255 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41350209
[ 1950.810860] 14234 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41350356
[ 1950.813821] 14258 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41350450
[ 1950.860422] 14261 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41351919
[ 1950.864015] 14210 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41352033
[ 1950.866636] 14226 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41352107
[ 1950.905003] 14238 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41353303
[ 1950.907813] 14180 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41353381
[ 1950.913963] 14276 (a.out) : gfp 0x50 : 615 seconds : OOM-killer skipped 41353567
[ 1952.238344] 649 (chronyd) : gfp 0x201DA : 25 seconds : OOM-killer skipped 41393388
[ 1952.243228] 4030 (gnome-shell) : gfp 0x201DA : 25 seconds : OOM-killer skipped 41393566
[ 1952.247225] 592 (audispd) : gfp 0x201DA : 25 seconds : OOM-killer skipped 41393701
[ 1952.258265] 1 (systemd) : gfp 0x201DA : 35 seconds : OOM-killer skipped 41394041
[ 1952.269296] 1691 (rpcbind) : gfp 0x201DA : 35 seconds : OOM-killer skipped 41394365
[ 1952.299073] 702 (rtkit-daemon) : gfp 0x201DA : 95 seconds : OOM-killer skipped 41395288
[ 1952.301231] 627 (lsmd) : gfp 0x201DA : 105 seconds : OOM-killer skipped 41395385
[ 1952.350200] 464 (systemd-journal) : gfp 0x201DA : 165 seconds : OOM-killer skipped 41396935
[ 1952.472040] 543 (auditd) : gfp 0x201DA : 95 seconds : OOM-killer skipped 41400669
[ 1952.475211] 14154 (su) : gfp 0x201DA : 95 seconds : OOM-killer skipped 41400795
[ 1952.527084] 3514 (smbd) : gfp 0x201DA : 35 seconds : OOM-killer skipped 41402412
[ 1952.543205] 613 (irqbalance) : gfp 0x201DA : 35 seconds : OOM-killer skipped 41402892
[ 1952.568276] 12672 (pickup) : gfp 0x201DA : 35 seconds : OOM-killer skipped 41403656
[ 1952.572329] 770 (tuned) : gfp 0x201DA : 95 seconds : OOM-killer skipped 41403784
[ 1952.578076] 3392 (master) : gfp 0x201DA : 35 seconds : OOM-killer skipped 41403955
[ 1952.597273] 615 (vmtoolsd) : gfp 0x201DA : 105 seconds : OOM-killer skipped 41404520
[ 1952.619187] 14146 (sleep) : gfp 0x201DA : 105 seconds : OOM-killer skipped 41405206
[ 1952.621214] 811 (NetworkManager) : gfp 0x201DA : 105 seconds : OOM-killer skipped 41405265
[ 1952.765035] 3700 (gnome-settings-) : gfp 0x201DA : 315 seconds : OOM-killer skipped 41409551
[ 1952.776099] 603 (alsactl) : gfp 0x201DA : 315 seconds : OOM-killer skipped 41409856
[ 1952.823163] 661 (crond) : gfp 0x201DA : 325 seconds : OOM-killer skipped 41411303
[ 1953.201269] SysRq : Resetting
---------- ext4 / Linux 3.19 + patch ----------

I also tested on XFS. One is Linux 3.19 and the other is Linux 3.19
with debug printk patch shown above. According to console logs,
oom_kill_process() is trivially called via pagefault_out_of_memory()
for the former kernel. Due to giving up !GFP_FS allocations immediately?

(From http://I-love.SAKURA.ne.jp/tmp/serial-20150223-3.19-xfs-unpatched.txt.xz )
---------- xfs / Linux 3.19 ----------
[  793.283099] su invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
[  793.283102] su cpuset=/ mems_allowed=0
[  793.283104] CPU: 3 PID: 9552 Comm: su Not tainted 3.19.0 #40
[  793.283159] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  793.283161]  0000000000000000 ffff88007ac03bf8 ffffffff816ae9d4 000000000000bebe
[  793.283162]  ffff880078b0d740 ffff88007ac03c98 ffffffff816ac7ac 0000000000000206
[  793.283163]  0000000481f30298 ffff880073e55850 ffff88007ac03c88 ffff88007a20bef8
[  793.283164] Call Trace:
[  793.283169]  [<ffffffff816ae9d4>] dump_stack+0x45/0x57
[  793.283171]  [<ffffffff816ac7ac>] dump_header+0x7f/0x1f1
[  793.283174]  [<ffffffff8114b36b>] oom_kill_process+0x22b/0x390
[  793.283177]  [<ffffffff810776d0>] ? has_capability_noaudit+0x20/0x30
[  793.283178]  [<ffffffff8114bb72>] out_of_memory+0x4b2/0x500
[  793.283179]  [<ffffffff8114bc37>] pagefault_out_of_memory+0x77/0x90
[  793.283180]  [<ffffffff816aab2c>] mm_fault_error+0x67/0x140
[  793.283182]  [<ffffffff8105a9f6>] __do_page_fault+0x3f6/0x580
[  793.283185]  [<ffffffff810aed1d>] ? remove_wait_queue+0x4d/0x60
[  793.283186]  [<ffffffff81070fcb>] ? do_wait+0x12b/0x240
[  793.283187]  [<ffffffff8105abb1>] do_page_fault+0x31/0x70
[  793.283189]  [<ffffffff816b83e8>] page_fault+0x28/0x30
---------- xfs / Linux 3.19 ----------

On the other hand, stall is observed for the latter kernel.
I guess that this time the system failed to make forward progress, for
oom_killer_skipped_count is increasing over time but the number of
remaining a.out processes remained unchanged.

(From http://I-love.SAKURA.ne.jp/tmp/serial-20150223-3.19-xfs-patched.txt.xz )
---------- xfs / Linux 3.19 + patch ----------
[ 2062.847965] 505 (abrt-watch-log) : gfp 0x2015A : 682 seconds : OOM-killer skipped 22388568
[ 2062.850270] 515 (lsmd) : gfp 0x2015A : 674 seconds : OOM-killer skipped 22388662
[ 2062.850389] 491 (audispd) : gfp 0x2015A : 666 seconds : OOM-killer skipped 22388667
[ 2062.850400] 346 (systemd-journal) : gfp 0x2015A : 683 seconds : OOM-killer skipped 22388667
[ 2062.850402] 610 (rtkit-daemon) : gfp 0x2015A : 677 seconds : OOM-killer skipped 22388667
[ 2062.850424] 494 (alsactl) : gfp 0x2015A : 546 seconds : OOM-killer skipped 22388668
[ 2062.850446] 558 (crond) : gfp 0x2015A : 645 seconds : OOM-killer skipped 22388669
[ 2062.850451] 25532 (su) : gfp 0x2015A : 682 seconds : OOM-killer skipped 22388669
[ 2062.850456] 516 (vmtoolsd) : gfp 0x2015A : 683 seconds : OOM-killer skipped 22388669
[ 2062.850494] 741 (NetworkManager) : gfp 0x2015A : 530 seconds : OOM-killer skipped 22388670
[ 2062.850503] 3132 (master) : gfp 0x2015A : 644 seconds : OOM-killer skipped 22388671
[ 2062.850508] 3144 (pickup) : gfp 0x2015A : 604 seconds : OOM-killer skipped 22388671
[ 2062.850512] 3145 (qmgr) : gfp 0x2015A : 526 seconds : OOM-killer skipped 22388671
[ 2062.850540] 25653 (a.out) : gfp 0x102005A : 683 seconds : OOM-killer skipped 22388672
[ 2062.850561] 655 (tuned) : gfp 0x2015A : 682 seconds : OOM-killer skipped 22388673
[ 2062.852404] 10429 (kworker/0:14) : gfp 0x2040D0 : 683 seconds : OOM-killer skipped 22388748
[ 2062.852430] 543 (chronyd) : gfp 0x2015A : 293 seconds : OOM-killer skipped 22388749
[ 2062.852436] 13012 (goa-daemon) : gfp 0x2015A : 679 seconds : OOM-killer skipped 22388749
[ 2062.852449] 1454 (rpcbind) : gfp 0x2015A : 662 seconds : OOM-killer skipped 22388749
[ 2062.854288] 466 (auditd) : gfp 0x2015A : 626 seconds : OOM-killer skipped 22388751
[ 2062.854305] 25622 (a.out) : gfp 0x102005A : 683 seconds : OOM-killer skipped 22388751
[ 2062.854426] 1419 (dhclient) : gfp 0x2015A : 388 seconds : OOM-killer skipped 22388751
[ 2062.854443] 25638 (a.out) : gfp 0x204250 : 683 seconds : OOM-killer skipped 22388751
[ 2062.854450] 25582 (a.out) : gfp 0x102005A : 683 seconds : OOM-killer skipped 22388751
[ 2062.854462] 25400 (sleep) : gfp 0x2015A : 635 seconds : OOM-killer skipped 22388751
[ 2062.854469] 532 (smartd) : gfp 0x2015A : 246 seconds : OOM-killer skipped 22388751
[ 2062.854486] 2 (kthreadd) : gfp 0x2040D0 : 682 seconds : OOM-killer skipped 22388752
[ 2062.854497] 3867 (gnome-shell) : gfp 0x2015A : 683 seconds : OOM-killer skipped 22388752
[ 2062.854502] 3562 (gnome-settings-) : gfp 0x2015A : 676 seconds : OOM-killer skipped 22388752
[ 2062.854524] 25641 (a.out) : gfp 0x102005A : 683 seconds : OOM-killer skipped 22388753
[ 2062.854536] 25566 (a.out) : gfp 0x102005A : 683 seconds : OOM-killer skipped 22388753
[ 2062.908915] 61 (kworker/3:1) : gfp 0x2040D0 : 682 seconds : OOM-killer skipped 22390715
[ 2062.913407] 531 (irqbalance) : gfp 0x2015A : 679 seconds : OOM-killer skipped 22390894
[ 2064.988155] SysRq : Resetting
---------- xfs / Linux 3.19 + patch ----------

Oh, current code is too hintless to determine whether forward progress is
made, for no kernel messages are printed when the OOM victim failed to die
immediately. I wish we had debug printk patch shown above and/or
like http://marc.info/?l=linux-mm&m=141671829611143&w=2 .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
