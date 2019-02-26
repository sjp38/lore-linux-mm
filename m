Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1625FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:30:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B552E218FC
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:30:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B552E218FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E5848E0003; Tue, 26 Feb 2019 18:30:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BCF48E0001; Tue, 26 Feb 2019 18:30:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D33A8E0003; Tue, 26 Feb 2019 18:30:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE73C8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 18:30:02 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a5so11754460pfn.2
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:30:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Y4VAJElQjDlkrP8plUkFt/IG6tc13Say/YDa5CF7BmM=;
        b=AIgfCsKNChe+zeZXAGJoTaBSwRypguEHxySdEqBeMR3LKzKUdHsbcmm53jGM+2hUKW
         2O7MIjncpaPEMKCMZWpkSboU3B1AuE2C01uu2kvol6EdChFtezI+jS4uJ0chqyH4xJ5d
         kORCE96aCXJ47X4OyK2eTV+E8ROrHQZaSpYlyswjLpTQKGpcXc2Ee/iRe55XXjgG2rJV
         ExMDxV2npJoo6SulD+845D5Xppi3MerlVWwXja3m4UJdQ9eDbQgYZz8/+YIWu2CH5GIQ
         tskjFZ9ju7z44+gqEkz4zToV8Alk65jXGPiXUhHJgUksMiNRkqE8XmAIf8LMGWXsFi7a
         Bnxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuYqit69fAgpsHSFX1PWJmJyKWsVayRVWAiLJf2MakZ6zH9hZB5I
	qwsjlkZ60vcrdBZeTiNNHGqvG3tqal9htiIPP0+dSoDRSQ3MiOu301eKVIhkcU4xMZ1SuUFqJjB
	qtQz4oXnytogA/PgcoRwMgF3QvlHjEWIm4+y+UW+loyDKveXvHp6XW3jD+y7LEBBdWA==
X-Received: by 2002:a63:6196:: with SMTP id v144mr26687675pgb.137.1551223802445;
        Tue, 26 Feb 2019 15:30:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZt/EsL4QEaUNKUXSv8kvQOVbVlMih1ATbXFF4Spl0dVqncBj82KDeG9bCUtuhfS4EXhoq7
X-Received: by 2002:a63:6196:: with SMTP id v144mr26687570pgb.137.1551223800933;
        Tue, 26 Feb 2019 15:30:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551223800; cv=none;
        d=google.com; s=arc-20160816;
        b=WzFY6MX4uGf8n0CaJeBIrTK58BcCw86KJkS1HL/KrrlqCil+lj42zHpHntkEuE2Q80
         uM4r5G5MRnRLzX44cJ621RrF/0ri5zf9Iu1Om0GfgUrK2yLkWVeRFLZL993KgCe1Mg85
         ojC9rT4TUdx/3OJXTziAT4hCrp0atGIllR8QHnfusCDoKBozAB10LiN66TDGw8WKjLVY
         q0ENLg4YmNfjssBSaEumPwItigSAUkjOK6faFYO5bhA1P54FXC21+u5Yqnj4eB4VPMrH
         eGMVdhHwF+lrPhKUnoOfqh3l7X/xuRPQhRzIhjq4W6136Z7cD475euek0yFJzbYvz5We
         cM2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Y4VAJElQjDlkrP8plUkFt/IG6tc13Say/YDa5CF7BmM=;
        b=UidqsDBHF89AbizPB8/PL+4dCw9+g05IO2YrxC7OsN2p3TRTifWO1yrL5YEBDvljvG
         6hTDpAojjf0XXT+rZygIIsDFAKopXVhN+uwKOL4V5GKv5Agz5Op7UmGC//JvTqlBcDtg
         8tCl/8C7rlnPSvyTYKsKqBCgjjBCqPHHnHbYhwWjucWkgJI0LcQP2s+LoIhj3Sm74w5P
         O6W3OM1LN1sb9tYQ0kdxEjsjbFBM0N6PFW5IeHdmjUljERo87iPkCTyAT0tbV4zQovbt
         UsYF+wtd92i+dmha8TA4QejeF1jM7zuk3gs5AZOCwepevwKieD50GiNANjbjTUV2bXEL
         Syzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r15si13331760pls.374.2019.02.26.15.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 15:30:00 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 600E6832E;
	Tue, 26 Feb 2019 23:30:00 +0000 (UTC)
Date: Tue, 26 Feb 2019 15:29:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chris Down <chris@chrisdown.name>, Tetsuo Handa
 <penguin-kernel@i-love.sakura.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>,
 Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org,
 cgroups@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm, memcg: Handle cgroup_disable=memory when getting
 memcg protection
Message-Id: <20190226152958.726b921f0cb03ccc50144539@linux-foundation.org>
In-Reply-To: <20190201074809.GF11599@dhcp22.suse.cz>
References: <20190201045711.GA18302@chrisdown.name>
	<20190201071203.GD11599@dhcp22.suse.cz>
	<20190201074809.GF11599@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2019 08:48:09 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 01-02-19 08:12:03, Michal Hocko wrote:
> > On Thu 31-01-19 23:57:11, Chris Down wrote:
> > > memcg is NULL if we have CONFIG_MEMCG set, but cgroup_disable=memory on
> > > the kernel command line.
> > > 
> > > Fixes: 8a907cdf0177ab40 ("mm, memcg: proportional memory.{low,min} reclaim")
> > 
> > JFYI this is not a valid sha1. It is from linux next and it will change
> > with the next linux-next release.
> > 
> > Btw. I still didn't get to look at your patch and I am unlikely to do so
> > today. I will be offline next week but I will try to get to it after I
> > get back.
> 
> Btw. I would appreciate if you could post the patch with all fixups
> folded for the final review once things settle down.

Things settled down.  Here's the rolled-up patch.  Please review?

From: Chris Down <chris@chrisdown.name>
Subject: mm, memcg: proportional memory.{low,min} reclaim

cgroup v2 introduces two memory protection thresholds: memory.low
(best-effort) and memory.min (hard protection).  While they generally do
what they say on the tin, there is a limitation in their implementation
that makes them difficult to use effectively: that cliff behaviour often
manifests when they become eligible for reclaim.  This patch implements
more intuitive and usable behaviour, where we gradually mount more reclaim
pressure as cgroups further and further exceed their protection
thresholds.

This cliff edge behaviour happens because we only choose whether or not to
reclaim based on whether the memcg is within its protection limits (see
the use of mem_cgroup_protected in shrink_node), but we don't vary our
reclaim behaviour based on this information.  Imagine the following
timeline, with the numbers the lruvec size in this zone:

1. memory.low=1000000, memory.current=999999. 0 pages may be scanned.
2. memory.low=1000000, memory.current=1000000. 0 pages may be scanned.
3. memory.low=1000000, memory.current=1000001. 1000001* pages may be
   scanned. (?!)

* Of course, we won't usually scan all available pages in the zone even
  without this patch because of scan control priority, over-reclaim
  protection, etc.  However, as shown by the tests at the end, these
  techniques don't sufficiently throttle such an extreme change in input,
  so cliff-like behaviour isn't really averted by their existence alone.

Here's an example of how this plays out in practice.  At Facebook, we are
trying to protect various workloads from "system" software, like
configuration management tools, metric collectors, etc (see this[0] case
study).  In order to find a suitable memory.low value, we start by
determining the expected memory range within which the workload will be
comfortable operating.  This isn't an exact science -- memory usage deemed
"comfortable" will vary over time due to user behaviour, differences in
composition of work, etc, etc.  As such we need to ballpark memory.low,
but doing this is currently problematic:

1. If we end up setting it too low for the workload, it won't have
   *any* effect (see discussion above).  The group will receive the full
   weight of reclaim and won't have any priority while competing with the
   less important system software, as if we had no memory.low configured
   at all.

2. Because of this behaviour, we end up erring on the side of setting
   it too high, such that the comfort range is reliably covered.  However,
   protected memory is completely unavailable to the rest of the system,
   so we might cause undue memory and IO pressure there when we *know* we
   have some elasticity in the workload.

3. Even if we get the value totally right, smack in the middle of the
   comfort zone, we get extreme jumps between no pressure and full
   pressure that cause unpredictable pressure spikes in the workload due
   to the current binary reclaim behaviour.

With this patch, we can set it to our ballpark estimation without too much
worry.  Any undesirable behaviour, such as too much or too little reclaim
pressure on the workload or system will be proportional to how far our
estimation is off.  This means we can set memory.low much more
conservatively and thus waste less resources *without* the risk of the
workload falling off a cliff if we overshoot.

As a more abstract technical description, this unintuitive behaviour
results in having to give high-priority workloads a large protection
buffer on top of their expected usage to function reliably, as otherwise
we have abrupt periods of dramatically increased memory pressure which
hamper performance.  Having to set these thresholds so high wastes
resources and generally works against the principle of work conservation. 
In addition, having proportional memory reclaim behaviour has other
benefits.  Most notably, before this patch it's basically mandatory to set
memory.low to a higher than desirable value because otherwise as soon as
you exceed memory.low, all protection is lost, and all pages are eligible
to scan again.  By contrast, having a gradual ramp in reclaim pressure
means that you now still get some protection when thresholds are exceeded,
which means that one can now be more comfortable setting memory.low to
lower values without worrying that all protection will be lost.  This is
important because workingset size is really hard to know exactly,
especially with variable workloads, so at least getting *some* protection
if your workingset size grows larger than you expect increases user
confidence in setting memory.low without a huge buffer on top being
needed.

Thanks a lot to Johannes Weiner and Tejun Heo for their advice and
assistance in thinking about how to make this work better.

In testing these changes, I intended to verify that:

1. Changes in page scanning become gradual and proportional instead of
   binary.

   To test this, I experimented stepping further and further down
   memory.low protection on a workload that floats around 19G workingset
   when under memory.low protection, watching page scan rates for the
   workload cgroup:

   +------------+-----------------+--------------------+--------------+
   | memory.low | test (pgscan/s) | control (pgscan/s) | % of control |
   +------------+-----------------+--------------------+--------------+
   |        21G |               0 |                  0 | N/A          |
   |        17G |             867 |               3799 | 23%          |
   |        12G |            1203 |               3543 | 34%          |
   |         8G |            2534 |               3979 | 64%          |
   |         4G |            3980 |               4147 | 96%          |
   |          0 |            3799 |               3980 | 95%          |
   +------------+-----------------+--------------------+--------------+

   As you can see, the test kernel (with a kernel containing this
   patch) ramps up page scanning significantly more gradually than the
   control kernel (without this patch).

2. More gradual ramp up in reclaim aggression doesn't result in
   premature OOMs.

   To test this, I wrote a script that slowly increments the number of
   pages held by stress(1)'s --vm-keep mode until a production system
   entered severe overall memory contention.  This script runs in a highly
   protected slice taking up the majority of available system memory. 
   Watching vmstat revealed that page scanning continued essentially
   nominally between test and control, without causing forward reclaim
   progress to become arrested.

[0]: https://facebookmicrosites.github.io/cgroup2/docs/overview.html#case-study-the-fbtax2-project

[akpm@linux-foundation.org: reflow block comments to fit in 80 cols]
[chris@chrisdown.name: handle cgroup_disable=memory when getting memcg protection]
  Link: http://lkml.kernel.org/r/20190201045711.GA18302@chrisdown.name
Link: http://lkml.kernel.org/r/20190124014455.GA6396@chrisdown.name
Signed-off-by: Chris Down <chris@chrisdown.name>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Dennis Zhou <dennis@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/admin-guide/cgroup-v2.rst |   20 +++--
 include/linux/memcontrol.h              |   20 +++++
 mm/memcontrol.c                         |    5 +
 mm/vmscan.c                             |   82 ++++++++++++++++++++--
 4 files changed, 115 insertions(+), 12 deletions(-)

--- a/Documentation/admin-guide/cgroup-v2.rst~mm-proportional-memorylowmin-reclaim
+++ a/Documentation/admin-guide/cgroup-v2.rst
@@ -606,8 +606,8 @@ on an IO device and is an example of thi
 Protections
 -----------
 
-A cgroup is protected to be allocated upto the configured amount of
-the resource if the usages of all its ancestors are under their
+A cgroup is protected upto the configured amount of the resource
+as long as the usages of all its ancestors are under their
 protected levels.  Protections can be hard guarantees or best effort
 soft boundaries.  Protections can also be over-committed in which case
 only upto the amount available to the parent is protected among
@@ -1020,7 +1020,10 @@ PAGE_SIZE multiple when read back.
 	is within its effective min boundary, the cgroup's memory
 	won't be reclaimed under any conditions. If there is no
 	unprotected reclaimable memory available, OOM killer
-	is invoked.
+	is invoked. Above the effective min boundary (or
+	effective low boundary if it is higher), pages are reclaimed
+	proportionally to the overage, reducing reclaim pressure for
+	smaller overages.
 
        Effective min boundary is limited by memory.min values of
 	all ancestor cgroups. If there is memory.min overcommitment
@@ -1042,7 +1045,10 @@ PAGE_SIZE multiple when read back.
 	Best-effort memory protection.  If the memory usage of a
 	cgroup is within its effective low boundary, the cgroup's
 	memory won't be reclaimed unless memory can be reclaimed
-	from unprotected cgroups.
+	from unprotected cgroups.  Above the effective low boundary (or
+	effective min boundary if it is higher), pages are reclaimed
+	proportionally to the overage, reducing reclaim pressure for
+	smaller overages.
 
 	Effective low boundary is limited by memory.low values of
 	all ancestor cgroups. If there is memory.low overcommitment
@@ -2283,8 +2289,10 @@ system performance due to overreclaim, t
 becomes self-defeating.
 
 The memory.low boundary on the other hand is a top-down allocated
-reserve.  A cgroup enjoys reclaim protection when it's within its low,
-which makes delegation of subtrees possible.
+reserve.  A cgroup enjoys reclaim protection when it's within its
+effective low, which makes delegation of subtrees possible. It also
+enjoys having reclaim pressure proportional to its overage when
+above its effective low.
 
 The original high boundary, the hard limit, is defined as a strict
 limit that can not budge, even if the OOM killer has to be called.
--- a/include/linux/memcontrol.h~mm-proportional-memorylowmin-reclaim
+++ a/include/linux/memcontrol.h
@@ -333,6 +333,14 @@ static inline bool mem_cgroup_disabled(v
 	return !cgroup_subsys_enabled(memory_cgrp_subsys);
 }
 
+static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg)
+{
+	if (mem_cgroup_disabled())
+		return 0;
+
+	return max(READ_ONCE(memcg->memory.emin), READ_ONCE(memcg->memory.elow));
+}
+
 enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 						struct mem_cgroup *memcg);
 
@@ -531,6 +539,8 @@ void mem_cgroup_handle_over_high(void);
 
 unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg);
 
+unsigned long mem_cgroup_size(struct mem_cgroup *memcg);
+
 void mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
 				struct task_struct *p);
 
@@ -824,6 +834,11 @@ static inline void memcg_memory_event_mm
 {
 }
 
+static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+
 static inline enum mem_cgroup_protection mem_cgroup_protected(
 	struct mem_cgroup *root, struct mem_cgroup *memcg)
 {
@@ -980,6 +995,11 @@ static inline unsigned long mem_cgroup_g
 {
 	return 0;
 }
+
+static inline unsigned long mem_cgroup_size(struct mem_cgroup *memcg)
+{
+	return 0;
+}
 
 static inline void
 mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p)
--- a/mm/memcontrol.c~mm-proportional-memorylowmin-reclaim
+++ a/mm/memcontrol.c
@@ -1377,6 +1377,11 @@ unsigned long mem_cgroup_get_max(struct
 	return max;
 }
 
+unsigned long mem_cgroup_size(struct mem_cgroup *memcg)
+{
+	return page_counter_read(&memcg->memory);
+}
+
 static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				     int order)
 {
--- a/mm/vmscan.c~mm-proportional-memorylowmin-reclaim
+++ a/mm/vmscan.c
@@ -2435,17 +2435,80 @@ out:
 	*lru_pages = 0;
 	for_each_evictable_lru(lru) {
 		int file = is_file_lru(lru);
-		unsigned long size;
+		unsigned long lruvec_size;
 		unsigned long scan;
+		unsigned long protection;
+
+		lruvec_size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
+		protection = mem_cgroup_protection(memcg);
+
+		if (protection > 0) {
+			/*
+			 * Scale a cgroup's reclaim pressure by proportioning
+			 * its current usage to its memory.low or memory.min
+			 * setting.
+			 *
+			 * This is important, as otherwise scanning aggression
+			 * becomes extremely binary -- from nothing as we
+			 * approach the memory protection threshold, to totally
+			 * nominal as we exceed it.  This results in requiring
+			 * setting extremely liberal protection thresholds. It
+			 * also means we simply get no protection at all if we
+			 * set it too low, which is not ideal.
+			 */
+			unsigned long cgroup_size = mem_cgroup_size(memcg);
+			unsigned long baseline = 0;
+
+			/*
+			 * During the reclaim first pass, we only consider
+			 * cgroups in excess of their protection setting, but if
+			 * that doesn't produce free pages, we come back for a
+			 * second pass where we reclaim from all groups.
+			 *
+			 * To maintain fairness in both cases, the first pass
+			 * targets groups in proportion to their overage, and
+			 * the second pass targets groups in proportion to their
+			 * protection utilization.
+			 *
+			 * So on the first pass, a group whose size is 130% of
+			 * its protection will be targeted at 30% of its size.
+			 * On the second pass, a group whose size is at 40% of
+			 * its protection will be
+			 * targeted at 40% of its size.
+			 */
+			if (!sc->memcg_low_reclaim)
+				baseline = lruvec_size;
+			scan = lruvec_size * cgroup_size / protection - baseline;
+
+			/*
+			 * Don't allow the scan target to exceed the lruvec
+			 * size, which otherwise could happen if we have >200%
+			 * overage in the normal case, or >100% overage when
+			 * sc->memcg_low_reclaim is set.
+			 *
+			 * This is important because other cgroups without
+			 * memory.low have their scan target initially set to
+			 * their lruvec size, so allowing values >100% of the
+			 * lruvec size here could result in penalising cgroups
+			 * with memory.low set even *more* than their peers in
+			 * some cases in the case of large overages.
+			 *
+			 * Also, minimally target SWAP_CLUSTER_MAX pages to keep
+			 * reclaim moving forwards.
+			 */
+			scan = clamp(scan, SWAP_CLUSTER_MAX, lruvec_size);
+		} else {
+			scan = lruvec_size;
+		}
+
+		scan >>= sc->priority;
 
-		size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
-		scan = size >> sc->priority;
 		/*
 		 * If the cgroup's already been deleted, make sure to
 		 * scrape out the remaining cache.
 		 */
 		if (!scan && !mem_cgroup_online(memcg))
-			scan = min(size, SWAP_CLUSTER_MAX);
+			scan = min(lruvec_size, SWAP_CLUSTER_MAX);
 
 		switch (scan_balance) {
 		case SCAN_EQUAL:
@@ -2465,7 +2528,7 @@ out:
 		case SCAN_ANON:
 			/* Scan one type exclusively */
 			if ((scan_balance == SCAN_FILE) != file) {
-				size = 0;
+				lruvec_size = 0;
 				scan = 0;
 			}
 			break;
@@ -2474,7 +2537,7 @@ out:
 			BUG();
 		}
 
-		*lru_pages += size;
+		*lru_pages += lruvec_size;
 		nr[lru] = scan;
 	}
 }
@@ -2735,6 +2798,13 @@ static bool shrink_node(pg_data_t *pgdat
 				memcg_memory_event(memcg, MEMCG_LOW);
 				break;
 			case MEMCG_PROT_NONE:
+				/*
+				 * All protection thresholds breached. We may
+				 * still choose to vary the scan pressure
+				 * applied based on by how much the cgroup in
+				 * question has exceeded its protection
+				 * thresholds (see get_scan_count).
+				 */
 				break;
 			}
 
_

