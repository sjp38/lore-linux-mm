Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D49F76B0005
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:37:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q3-v6so10182285wrm.8
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:37:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3-v6si2379027edc.272.2018.05.23.01.37.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 01:37:58 -0700 (PDT)
Date: Wed, 23 May 2018 10:37:56 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC] trace when adding memory to an offline nod
Message-ID: <20180523083756.GJ20441@dhcp22.suse.cz>
References: <20180523080108.GA30350@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523080108.GA30350@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, vbabka@suse.cz, pasha.tatashin@oracle.com, dan.j.williams@intel.com

On Wed 23-05-18 10:01:08, Oscar Salvador wrote:
> Hi guys,
> 
> while testing memhotplug, I spotted the following trace:
> 
> =====
> linux kernel: WARNING: CPU: 0 PID: 64 at ./include/linux/gfp.h:467 vmemmap_alloc_block+0x4e/0xc9

This warning is too loud and not really helpful. We are doing
		gfp_t gfp_mask = GFP_KERNEL|__GFP_RETRY_MAYFAIL|__GFP_NOWARN;

		page = alloc_pages_node(node, gfp_mask, order);

so we do not really insist on the allocation succeeding on the requested
node (it is more a hint which node is the best one but we can fallback
to any other node). Moreover we do explicitly do not care about
allocation warnings by __GFP_NOWARN. So maybe we want to soften the
warning like this?

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 036846fc00a6..7f860ea29ec6 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -464,7 +464,7 @@ static inline struct page *
 __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 {
 	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
-	VM_WARN_ON(!node_online(nid));
+	VM_WARN_ON((gfp_mask & __GFP_THISNODE) && !node_online(nid));
 
 	return __alloc_pages(gfp_mask, order, nid);
 }
-- 
Michal Hocko
SUSE Labs
