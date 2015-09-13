Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6786B0255
	for <linux-mm@kvack.org>; Sun, 13 Sep 2015 16:15:13 -0400 (EDT)
Received: by qkdw123 with SMTP id w123so51039719qkd.0
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 13:15:13 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id v88si9304010qkv.71.2015.09.13.13.15.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Sep 2015 13:15:12 -0700 (PDT)
Received: by qgev79 with SMTP id v79so100560569qge.0
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 13:15:12 -0700 (PDT)
Date: Sun, 13 Sep 2015 16:15:09 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/3] memcg: drop unnecessary cold-path tests from
 __memcg_kmem_bypass()
Message-ID: <20150913201509.GE25369@htj.duckdns.org>
References: <20150913201416.GC25369@htj.duckdns.org>
 <20150913201442.GD25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150913201442.GD25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

__memcg_kmem_bypass() decides whether a kmem allocation should be
bypassed to the root memcg.  Some conditions that it tests are valid
criteria regarding who should be held accountable; however, there are
a couple unnecessary tests for cold paths - __GFP_FAIL and
fatal_signal_pending().

The previous patch updated try_charge() to handle both __GFP_FAIL and
dying tasks correctly and the only thing these two tests are doing is
making accounting less accurate and sprinkling tests for cold path
conditions in the hot paths.  There's nothing meaningful gained by
these extra tests.

This patch removes the two unnecessary tests from
__memcg_kmem_bypass().

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h |   14 --------------
 1 file changed, 14 deletions(-)

--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -780,24 +780,10 @@ static inline bool __memcg_kmem_bypass(g
 {
 	if (!memcg_kmem_enabled())
 		return true;
-
 	if (gfp & __GFP_NOACCOUNT)
 		return true;
-	/*
-	 * __GFP_NOFAIL allocations will move on even if charging is not
-	 * possible. Therefore we don't even try, and have this allocation
-	 * unaccounted. We could in theory charge it forcibly, but we hope
-	 * those allocations are rare, and won't be worth the trouble.
-	 */
-	if (gfp & __GFP_NOFAIL)
-		return true;
 	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
 		return true;
-
-	/* If the test is dying, just let it go. */
-	if (unlikely(fatal_signal_pending(current)))
-		return true;
-
 	return false;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
