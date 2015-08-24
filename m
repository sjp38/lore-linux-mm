Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3662F6B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 09:16:20 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so71985855wic.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:16:19 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id lq5si31961424wjb.170.2015.08.24.06.16.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 06:16:18 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id E57BE99108
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 13:16:17 +0000 (UTC)
Date: Mon, 24 Aug 2015 14:16:16 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/12] mm, page_alloc: Only check cpusets when one exists
 that can be mem-controlled
Message-ID: <20150824131616.GK12432@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-5-git-send-email-mgorman@techsingularity.net>
 <55DB1015.4080103@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55DB1015.4080103@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 24, 2015 at 02:37:41PM +0200, Vlastimil Babka wrote:
> >
> >+/* Returns true if a cpuset exists that can set cpuset.mems */
> >+static inline bool cpusets_mems_enabled(void)
> >+{
> >+	return nr_cpusets() > 1;
> >+}
> >+
> 
> Hm, but this loses the benefits of static key branches?
> How about something like:
> 
>   if (static_key_false(&cpusets_enabled_key))
> 	return nr_cpusets() > 1
>   else
> 	return false;
> 

Will do.

> 
> 
> >  static inline void cpuset_inc(void)
> >  {
> >  	static_key_slow_inc(&cpusets_enabled_key);
> >@@ -104,7 +106,7 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
> >   */
> >  static inline unsigned int read_mems_allowed_begin(void)
> >  {
> >-	if (!cpusets_enabled())
> >+	if (!cpusets_mems_enabled())
> >  		return 0;
> >
> >  	return read_seqcount_begin(&current->mems_allowed_seq);
> >@@ -118,7 +120,7 @@ static inline unsigned int read_mems_allowed_begin(void)
> >   */
> >  static inline bool read_mems_allowed_retry(unsigned int seq)
> >  {
> >-	if (!cpusets_enabled())
> >+	if (!cpusets_mems_enabled())
> >  		return false;
> 
> Actually I doubt it's much of benefit for these usages, even if the static
> key benefits are restored. If there's a single root cpuset, we would check
> the seqlock prior to this patch, now we'll check static key value (which
> should have the same cost?). With >1 cpusets, we would check seqlock prior
> to this patch, now we'll check static key value *and* the seqlock...
> 

If the cpuset is enabled between the check, it still should retry.
Anyway, special casing this is overkill. It's a small
micro-optimisation.

> >
> >  	return read_seqcount_retry(&current->mems_allowed_seq, seq);
> >@@ -139,7 +141,7 @@ static inline void set_mems_allowed(nodemask_t nodemask)
> >
> >  #else /* !CONFIG_CPUSETS */
> >
> >-static inline bool cpusets_enabled(void) { return false; }
> >+static inline bool cpusets_mems_enabled(void) { return false; }
> >
> >  static inline int cpuset_init(void) { return 0; }
> >  static inline void cpuset_init_smp(void) {}
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 62ae28d8ae8d..2c1c3bf54d15 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -2470,7 +2470,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> >  		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
> >  			!zlc_zone_worth_trying(zonelist, z, allowednodes))
> >  				continue;
> >-		if (cpusets_enabled() &&
> >+		if (cpusets_mems_enabled() &&
> >  			(alloc_flags & ALLOC_CPUSET) &&
> >  			!cpuset_zone_allowed(zone, gfp_mask))
> >  				continue;
> 
> Here the benefits are less clear. I guess cpuset_zone_allowed() is
> potentially costly...
> 
> Heck, shouldn't we just start the static key on -1 (if possible), so that
> it's enabled only when there's 2+ cpusets?

It's overkill for the amount of benefit.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
