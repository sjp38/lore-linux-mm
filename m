Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id E52176B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 19:18:32 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so4813671wgg.31
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 16:18:32 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id t9si474269wiw.26.2014.08.07.16.18.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 16:18:31 -0700 (PDT)
Date: Thu, 7 Aug 2014 19:18:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mm: memcontrol: rewrite uncharge API
Message-ID: <20140807231827.GI14734@cmpxchg.org>
References: <20140806135914.9fca00159f6e3298c24a4ab3@linux-foundation.org>
 <20140806140011.692985b45f8844706b17098e@linux-foundation.org>
 <20140806140055.40a48055f8797e159a894a68@linux-foundation.org>
 <20140806140235.f8fb69e76454af2ce935dc5b@linux-foundation.org>
 <20140807073825.GA12779@dhcp22.suse.cz>
 <20140807162507.GF14734@cmpxchg.org>
 <20140807154046.b8cce18325ade5b561475860@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140807154046.b8cce18325ade5b561475860@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Thu, Aug 07, 2014 at 03:40:46PM -0700, Andrew Morton wrote:
> On Thu, 7 Aug 2014 12:25:07 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > mem_cgroup_migrate() is suitable for replace_page_cache() as well,
> > which gets rid of mem_cgroup_replace_page_cache().
> > 
> > Could you please update it to say:
> > 
> > mem_cgroup_migrate() is suitable for replace_page_cache() as well,
> > which gets rid of mem_cgroup_replace_page_cache().  However, care
> > needs to be taken because both the source and the target page can
> > already be charged and on the LRU when fuse is splicing: grab the page
> > lock on the charge moving side to prevent changing pc->mem_cgroup of a
> > page under migration.  Also, the lruvecs of both pages change as we
> > uncharge the old and charge the new during migration, and putback may
> > race with us, so grab the lru lock and isolate the pages iff on LRU to
> > prevent races and ensure the pages are on the right lruvec afterward.
> 
> OK thanks, I did that, separated out
> mm-memcontrol-rewrite-uncharge-api-fix-page-cache-migration.patch again
> and copied the [0/n] changelog text into mm-memcontrol-rewrite-charge-api.patch.
> 
> I'll get these (presently at http://ozlabs.org/~akpm/mmots/broken-out/)
> 
> mm-memcontrol-rewrite-charge-api.patch
> mm-memcontrol-rewrite-uncharge-api.patch
> mm-memcontrol-rewrite-uncharge-api-fix-page-cache-migration.patch
> mm-memcontrol-use-page-lists-for-uncharge-batching.patch
> #
> page-cgroup-trivial-cleanup.patch
> page-cgroup-get-rid-of-nr_pcg_flags.patch
> #
> #
> memcg-remove-lookup_cgroup_page-prototype.patch

mm-memcontrol-avoid-charge-statistics-churn-during-page-migration.patch
came a bit later, but it's a small optimization directly relevant to
the above changes, so you may want to send it along with them.

Michal already acked it on the list:
http://marc.info/?l=linux-mm&m=140724569618836&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
