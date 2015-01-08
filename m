Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id F0C986B0073
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 04:09:05 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id q59so1309505wes.8
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 01:09:05 -0800 (PST)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com. [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id hh5si8411670wjb.161.2015.01.08.01.09.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 01:09:05 -0800 (PST)
Received: by mail-wg0-f45.google.com with SMTP id b13so1420217wgh.4
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 01:09:04 -0800 (PST)
Date: Thu, 8 Jan 2015 10:09:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [LSF/MM TOPIC ATTEND]
Message-ID: <20150108090901.GB5658@dhcp22.suse.cz>
References: <20150106161435.GF20860@dhcp22.suse.cz>
 <20150107085828.GA2110@esperanza>
 <20150107143858.GE16553@dhcp22.suse.cz>
 <20150108083353.GB2110@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150108083353.GB2110@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Thu 08-01-15 11:33:53, Vladimir Davydov wrote:
> On Wed, Jan 07, 2015 at 03:38:58PM +0100, Michal Hocko wrote:
> > On Wed 07-01-15 11:58:28, Vladimir Davydov wrote:
> > > On Tue, Jan 06, 2015 at 05:14:35PM +0100, Michal Hocko wrote:
> > > [...]
> > > > And as a memcg co-maintainer I would like to also discuss the following
> > > > topics.
> > > > - We should finally settle down with a set of core knobs exported with
> > > >   the new unified hierarchy cgroups API. I have proposed this already
> > > >   http://marc.info/?l=linux-mm&m=140552160325228&w=2 but there is no
> > > >   clear consensus and the discussion has died later on. I feel it would
> > > >   be more productive to sit together and come up with a reasonable
> > > >   compromise between - let's start from the begining and keep useful and
> > > >   reasonable features.
> > > >   
> > > > - kmem accounting is seeing a lot of activity mainly thanks to Vladimir.
> > > >   He is basically the only active developer in this area. I would be
> > > >   happy if he can attend as well and discuss his future plans in the
> > > >   area. The work overlaps with slab allocators and slab shrinkers so
> > > >   having people familiar with these areas would be more than welcome
> > > 
> > > One more memcg related topic that is worth discussing IMO:
> > > 
> > >  - On global memory pressure we walk over all memory cgroups and scan
> > >    pages from each of them. Since there can be hundreds or even
> > >    thousands of memory cgroups, such a walk can be quite expensive,
> > >    especially if the cgroups are small so that to reclaim anything from
> > >    them we have to descend to a lower scan priority.
> > 
> >      We do not get to lower priorities just to scan small cgroups. They
> >      will simply get ignored unless we are force scanning them.
> 
> That means that small cgroups (< 16 M) may not be scanned at all if
> there are enough reclaimable pages in bigger cgroups. I'm not sure if
> anyone will mix small and big cgroups on the same host though. However,
> currently this may render offline memory cgroups hanging around forever
> if they have some memory on destruction, because they will become small
> due to global reclaim sooner or later. OTOH, we could always forcefully
> scan lruvecs that belong to dead cgroups, or limit the maximal number of
> dead cgroups, w/o reworking the reclaimer.

Makes sense! Now that we do not reparent on offline this might indeed be
a problem. Care to send a patch? I will cook up something if you do not
have time for that.

Something along these lines should work but I haven't thought about that
very much to be honest:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e29f411b38ac..277585176a9e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1935,7 +1935,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	 * latencies, so it's better to scan a minimum amount there as
 	 * well.
 	 */
-	if (current_is_kswapd() && !zone_reclaimable(zone))
+	if (current_is_kswapd() && (!zone_reclaimable(zone) || mem_cgroup_need_force_scan(sc->target_mem_cgroup)))
 		force_scan = true;
 	if (!global_reclaim(sc))
 		force_scan = true;
 
> > >    The problem is
> > >    augmented by offline memory cgroups, which now can be dangling for
> > >    indefinitely long time.
> > 
> > OK, but shrink_lruvec shouldn't do too much work on a memcg which
> > doesn't have any pages to scan for the given priority. Or have you
> > seen this in some profiles?
> 
> In real life, no.
> 
> > 
> > >    That's why I think we should work out a better algorithm for the
> > >    memory reclaimer. May be, we could rank memory cgroups somehow (by
> > >    their age, memory consumption?) and try to scan only the top ranked
> > >    cgroup during a reclaimer run.
> > 
> > We still have to keep some fairness and reclaim all groups
> > proportionally and balancing this would be quite non-trivial. I am not
> > saying we couldn't implement our iterators in a more intelligent way but
> > this code is quite complex already and I haven't seen this as a big
> > problem yet. Some overhead is to be expected when thousands of groups
> > are configured, right?
> 
> Right, sounds convincing. Let's cross out this topic then until we see
> complains from real users. No need to spend time on it right now.
> 
> Sorry for the noise.

No noise at all!

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
