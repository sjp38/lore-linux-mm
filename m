Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 144BE6B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 03:16:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g66so462496pfj.11
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 00:16:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e63si868625pfb.268.2018.03.20.00.16.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 00:16:27 -0700 (PDT)
Date: Tue, 20 Mar 2018 08:16:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: do not cause memcg oom for thp
Message-ID: <20180320071624.GB23100@dhcp22.suse.cz>
References: <alpine.DEB.2.20.1803191409420.124411@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803191409420.124411@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 19-03-18 14:10:05, David Rientjes wrote:
> Commit 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and
> madvised allocations") changed the page allocator to no longer detect thp
> allocations based on __GFP_NORETRY.
> 
> It did not, however, modify the mem cgroup try_charge() path to avoid oom
> kill for either khugepaged collapsing or thp faulting.  It is never
> expected to oom kill a process to allocate a hugepage for thp; reclaim is
> governed by the thp defrag mode and MADV_HUGEPAGE, but allocations (and
> charging) should fallback instead of oom killing processes.

For some reason I thought that the charging path simply bails out for
costly orders - effectively the same thing as for the global OOM killer.
But we do not. Is there any reason to not do that though? Why don't we
simply do


diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d1a917b5b7b7..08accbcd1a18 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1493,7 +1493,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 
 static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
-	if (!current->memcg_may_oom)
+	if (!current->memcg_may_oom || order > PAGE_ALLOC_COSTLY_ORDER)
 		return;
 	/*
 	 * We are in the middle of the charge context here, so we
-- 
Michal Hocko
SUSE Labs
