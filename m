Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EF3DC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:31:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF224217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:31:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="z485kAr9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF224217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55D636B0005; Fri, 24 May 2019 11:31:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50E5B6B0006; Fri, 24 May 2019 11:31:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AEEF6B000A; Fri, 24 May 2019 11:31:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id F32FC6B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 11:31:55 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e16so6519309pga.4
        for <linux-mm@kvack.org>; Fri, 24 May 2019 08:31:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=xax+Itit2redxrlh2xu6KH2UMjJ3BZeeSxkOY3WyROU=;
        b=QG60oNqBVSbn4yDQeNBuuexuB+8gpIOPu5XNndw3Hs5GhdqxpeLX3mlSt90BEFefjS
         VKf6ke65NARek9EeBk7CCkT4EJnNeYuMJL4qoYv5B3wRDgycDqAyePXjscKAS9tRy/gq
         W8Pa1HEKTuoqMxPcF4i4Alqs1hyR7A0WLJIBBQlxj9rZq6AiH34qtsL32pPgqr6TZyel
         jLGUIitI1A0ci4pLUOZ4jjTV5bKkuPhogQm6XtHRpjmEElERdDEhbnYbN4LgRvvZAnh5
         axDIEiXBhC7C0Z3hVhlW8SrChkzl/WF4C0IwiYlcLcokNkHWwtkoK8nvyjbzjtpngsyA
         ffKw==
X-Gm-Message-State: APjAAAXemRA10RJuPJhCpyomZq0LSrkCfHpE7SOQe7YBzlhZ5MNivjER
	ckAnSpC9/oJyVRAzqkmRH8fYKh3NLj4QJoKjbzX8oD8bDpGunH9PeoCFFWr+LxPcCjlOSUGnVw1
	9luBjwPWlsTWo1o1zzZupO9CVntvO+rgEgln3ABAxCKLfiiUx2YEcn5RfKHf9jZE0zg==
X-Received: by 2002:a63:2b96:: with SMTP id r144mr92338598pgr.314.1558711915463;
        Fri, 24 May 2019 08:31:55 -0700 (PDT)
X-Received: by 2002:a63:2b96:: with SMTP id r144mr92338457pgr.314.1558711914213;
        Fri, 24 May 2019 08:31:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558711914; cv=none;
        d=google.com; s=arc-20160816;
        b=gg7N+6wmbzEoKgLRkHDxK2VBIrg+2R1dP4eb5KsqNPCI6bj0SRqVI7QrvzNXSAavCS
         CrRwyerKL6mEZ+qARM1PPVRj8eWbPk7wsf61g2KVldSxZcR2g6L2sTnILJVZ29gHXxAR
         lqGRpSY4WUfB34CVDsdYdV+DfDXs2zRXz+STYOPnfCnR7WHSdLkgxp1swstcLZHaaw54
         r9C1DHBRdezbrNg1FODkrJKzeHVrlxb4LIv8vEemBjxAz+hVxTF48BORpv0KZesVs2US
         Mae0buk4+CfZB4ab0Ns5cKjE2K2uWkMDvykBwUrWOyZgQOZOv4kg4QAxSlYIUWiqJvn/
         el6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=xax+Itit2redxrlh2xu6KH2UMjJ3BZeeSxkOY3WyROU=;
        b=MkW4sumTL5AeQqs5M4tmkXZnKJQJRaym5gy1A8XxPD6ulhG1y9LGs/eggdypjpSH7Z
         UpfhkkQ9t0OaAVF0FfFPwVlSCXMxtLeLZxa/Lth/2HI8LMrS9z/OiLCZXRmRMYmytC43
         sRSv3dUzcpcPPlYCuzAe8m3J6t3SJxfmt6XQ2sVwcSwl/SL4aZ+cgKYz4NwdO1pskqVO
         7QryEZafvMBgNURCYBv83Ndyr9RYrA5yGP2gIrHv47VncMP/qPhjPeumsXS9aZZ5uPIC
         Y05PYekGKtgnQeqJx8l2bVeNANgBeh5mV1LQrXpOPtf7yt+63mL4kHETLBDahLjgO2Iq
         3aag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=z485kAr9;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q8sor3595043pll.16.2019.05.24.08.31.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 08:31:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=z485kAr9;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=xax+Itit2redxrlh2xu6KH2UMjJ3BZeeSxkOY3WyROU=;
        b=z485kAr9blKJo6NBcbFr+fn20i1azeIo3+m7fUvokaeqRUDgcc0Eo9zWEeVNtRD1lh
         y8wnAE4K60RClRAnK0p7rP6oJCWY56aQWFQyaaetR3chFQKdoud5UkTqffwxDnZrBC1c
         AKlGkIuVvJuetDxg4BKn90i8pRVi3aL3y5jwHOYTBIpTXcGfK/RFsXGI6ixujey85UfO
         RtIEsCCVTd7dqNaA4HkMOE5TGlTeIruWEdryqC1zR9XDeidfqPF5zSyeCCEzzgzUgrO7
         /xBYTJd7bBwfT2YNxIrnTJ7MrR6t2ftIbdJShesXRo+8/jmZqk7VE/n94cYHv6ZpW0HQ
         6uOw==
X-Google-Smtp-Source: APXvYqzJDR+ptpnVNFiBcyHOv6NHmG2mK8rNF3q+c/HygM64gpdEeAHy3TO3MHZ4nC0zBp3xVj++ag==
X-Received: by 2002:a17:902:8c8f:: with SMTP id t15mr51364381plo.87.1558711911326;
        Fri, 24 May 2019 08:31:51 -0700 (PDT)
Received: from localhost ([2620:10d:c090:180::805])
        by smtp.gmail.com with ESMTPSA id j2sm4862174pfb.157.2019.05.24.08.31.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 08:31:50 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH] mm: fix page cache convergence regression
Date: Fri, 24 May 2019 11:31:48 -0400
Message-Id: <20190524153148.18481-1-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since a28334862993 ("page cache: Finish XArray conversion"), on most
major Linux distributions, the page cache doesn't correctly transition
when the hot data set is changing, and leaves the new pages thrashing
indefinitely instead of kicking out the cold ones.

On a freshly booted, freshly ssh'd into virtual machine with 1G RAM
running stock Arch Linux:

[root@ham ~]# ./reclaimtest.sh
+ dd of=workingset-a bs=1M count=0 seek=600
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ ./mincore workingset-a
153600/153600 workingset-a
+ dd of=workingset-b bs=1M count=0 seek=600
+ cat workingset-b
+ cat workingset-b
+ cat workingset-b
+ cat workingset-b
+ ./mincore workingset-a workingset-b
104029/153600 workingset-a
120086/153600 workingset-b
+ cat workingset-b
+ cat workingset-b
+ cat workingset-b
+ cat workingset-b
+ ./mincore workingset-a workingset-b
104029/153600 workingset-a
120268/153600 workingset-b

workingset-b is a 600M file on a 1G host that is otherwise entirely
idle. No matter how often it's being accessed, it won't get cached.

While investigating, I noticed that the non-resident information gets
aggressively reclaimed - /proc/vmstat::workingset_nodereclaim. This is
a problem because a workingset transition like this relies on the
non-resident information tracked in the page cache tree of evicted
file ranges: when the cache faults are refaults of recently evicted
cache, we challenge the existing active set, and that allows a new
workingset to establish itself.

Tracing the shrinker that maintains this memory revealed that all page
cache tree nodes were allocated to the root cgroup. This is a problem,
because 1) the shrinker sizes the amount of non-resident information
it keeps to the size of the cgroup's other memory and 2) on most major
Linux distributions, only kernel threads live in the root cgroup and
everything else gets put into services or session groups:

[root@ham ~]# cat /proc/self/cgroup
0::/user.slice/user-0.slice/session-c1.scope

As a result, we basically maintain no non-resident information for the
workloads running on the system, thus breaking the caching algorithm.

Looking through the code, I found the culprit in the above-mentioned
patch: when switching from the radix tree to xarray, it dropped the
__GFP_ACCOUNT flag from the tree node allocations - the flag that
makes sure the allocated memory gets charged to and tracked by the
cgroup of the calling process - in this case, the one doing the fault.

To fix this, allow xarray users to specify per-tree gfp flags that
supplement the hardcoded gfp flags inside the xarray expansion code.
This is analogous to the radix tree API. Then restore the page cache
tree annotation that passes the __GFP_ACCOUNT flag during expansions.

With this patch applied, the page cache correctly converges on new
workingsets again after just a few iterations:

[root@ham ~]# ./reclaimtest.sh
+ dd of=workingset-a bs=1M count=0 seek=600
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ cat workingset-a
+ ./mincore workingset-a
153600/153600 workingset-a
+ dd of=workingset-b bs=1M count=0 seek=600
+ cat workingset-b
+ ./mincore workingset-a workingset-b
124607/153600 workingset-a
87876/153600 workingset-b
+ cat workingset-b
+ ./mincore workingset-a workingset-b
81313/153600 workingset-a
133321/153600 workingset-b
+ cat workingset-b
+ ./mincore workingset-a workingset-b
63036/153600 workingset-a
153600/153600 workingset-b

Cc: stable@vger.kernel.org # 4.20+
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/inode.c             | 1 +
 include/linux/xarray.h | 2 ++
 lib/xarray.c           | 8 ++++++--
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index e9d18b2c3f91..3b454d2119c4 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -362,6 +362,7 @@ EXPORT_SYMBOL(inc_nlink);
 static void __address_space_init_once(struct address_space *mapping)
 {
 	xa_init_flags(&mapping->i_pages, XA_FLAGS_LOCK_IRQ);
+	mapping->i_pages.xa_gfp = __GFP_ACCOUNT;
 	init_rwsem(&mapping->i_mmap_rwsem);
 	INIT_LIST_HEAD(&mapping->private_list);
 	spin_lock_init(&mapping->private_lock);
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 0e01e6129145..cbbf76e4c973 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -292,6 +292,7 @@ struct xarray {
 	spinlock_t	xa_lock;
 /* private: The rest of the data structure is not to be used directly. */
 	gfp_t		xa_flags;
+	gfp_t		xa_gfp;
 	void __rcu *	xa_head;
 };
 
@@ -374,6 +375,7 @@ static inline void xa_init_flags(struct xarray *xa, gfp_t flags)
 {
 	spin_lock_init(&xa->xa_lock);
 	xa->xa_flags = flags;
+	xa->xa_gfp = 0;
 	xa->xa_head = NULL;
 }
 
diff --git a/lib/xarray.c b/lib/xarray.c
index 6be3acbb861f..324be9534861 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -298,6 +298,7 @@ bool xas_nomem(struct xa_state *xas, gfp_t gfp)
 		xas_destroy(xas);
 		return false;
 	}
+	gfp |= xas->xa->xa_gfp;
 	xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
 	if (!xas->xa_alloc)
 		return false;
@@ -325,6 +326,7 @@ static bool __xas_nomem(struct xa_state *xas, gfp_t gfp)
 		xas_destroy(xas);
 		return false;
 	}
+	gfp |= xas->xa->xa_gfp;
 	if (gfpflags_allow_blocking(gfp)) {
 		xas_unlock_type(xas, lock_type);
 		xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
@@ -358,8 +360,10 @@ static void *xas_alloc(struct xa_state *xas, unsigned int shift)
 	if (node) {
 		xas->xa_alloc = NULL;
 	} else {
-		node = kmem_cache_alloc(radix_tree_node_cachep,
-					GFP_NOWAIT | __GFP_NOWARN);
+		gfp_t gfp;
+
+		gfp = GFP_NOWAIT | __GFP_NOWARN | xas->xa->xa_gfp;
+		node = kmem_cache_alloc(radix_tree_node_cachep, gfp);
 		if (!node) {
 			xas_set_err(xas, -ENOMEM);
 			return NULL;
-- 
2.21.0

