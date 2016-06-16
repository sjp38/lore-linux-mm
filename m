Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC20E6B0253
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:53:24 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id c1so10830812lbw.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:53:24 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id gh2si6099497wjd.127.2016.06.16.08.53.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 08:53:22 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 4CFA299241
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 15:53:22 +0000 (UTC)
Date: Thu, 16 Jun 2016 16:53:20 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 13/27] mm, memcg: Move memcg limit enforcement from zones
 to nodes
Message-ID: <20160616155320.GJ1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-14-git-send-email-mgorman@techsingularity.net>
 <2aea9490-99aa-4e55-e7ca-22b695eee1da@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2aea9490-99aa-4e55-e7ca-22b695eee1da@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 16, 2016 at 05:06:46PM +0200, Vlastimil Babka wrote:
> >@@ -323,13 +319,10 @@ EXPORT_SYMBOL(memcg_kmem_enabled_key);
> >
> > #endif /* !CONFIG_SLOB */
> >
> >-static struct mem_cgroup_per_zone *
> >-mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
> >+static struct mem_cgroup_per_node *
> >+mem_cgroup_nodeinfo(struct mem_cgroup *memcg, pg_data_t *pgdat)
> > {
> >-	int nid = zone_to_nid(zone);
> >-	int zid = zone_idx(zone);
> >-
> >-	return &memcg->nodeinfo[nid]->zoneinfo[zid];
> >+	return memcg->nodeinfo[pgdat->node_id];
> 
> I've noticed most callers pass NODE_DATA(nid) as second parameter, which is
> quite wasteful to just obtain back the node_id (I doubt the compiler can
> know that they will be the same?). So it would be more efficient to use nid
> instead of pg_data_t pointer in the signature.
> 

No harm in making the conversion, done now.

> > }
> >
> > /**
> >@@ -383,37 +376,35 @@ ino_t page_cgroup_ino(struct page *page)
> > 	return ino;
> > }
> >
> >-static struct mem_cgroup_per_zone *
> >+static struct mem_cgroup_per_node *
> > mem_cgroup_page_zoneinfo(struct mem_cgroup *memcg, struct page *page)
> 
> This could be renamed to _nodeinfo()?
> 

Renamed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
