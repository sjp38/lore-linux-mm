Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7126B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 19:19:25 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f11so4582485yha.0
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:19:24 -0800 (PST)
Received: from mail-yh0-x233.google.com (mail-yh0-x233.google.com [2607:f8b0:4002:c01::233])
        by mx.google.com with ESMTPS id q66si10408242yhm.104.2013.12.10.16.19.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 16:19:24 -0800 (PST)
Received: by mail-yh0-f51.google.com with SMTP id c41so4495918yho.38
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:19:23 -0800 (PST)
Date: Tue, 10 Dec 2013 16:19:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch alternative] mm, page_alloc: warn for non-blockable __GFP_NOFAIL
 allocation failure
In-Reply-To: <alpine.DEB.2.02.1312101504120.22701@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1312101618530.22701@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1312091355360.11026@chino.kir.corp.google.com> <20131209152202.df3d4051d7dc61ada7c420a9@linux-foundation.org> <alpine.DEB.2.02.1312101504120.22701@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

__GFP_NOFAIL may return NULL when coupled with GFP_NOWAIT or GFP_ATOMIC.

Luckily, nothing currently does such craziness.  So instead of causing
such allocations to loop (potentially forever), we maintain the current
behavior and also warn about the new users of the deprecated flag.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2536,8 +2536,15 @@ rebalance:
 	}
 
 	/* Atomic allocations - we can't balance anything */
-	if (!wait)
+	if (!wait) {
+		/*
+		 * All existing users of the deprecated __GFP_NOFAIL are
+		 * blockable, so warn of any new users that actually allow this
+		 * type of allocation to fail.
+		 */
+		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
 		goto nopage;
+	}
 
 	/* Avoid recursion of direct reclaim */
 	if (current->flags & PF_MEMALLOC)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
