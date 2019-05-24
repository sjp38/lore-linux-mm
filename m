Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E855C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:39:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB03021773
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:39:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="n6dbur+B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB03021773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C2A96B0278; Fri, 24 May 2019 13:39:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54B2C6B027A; Fri, 24 May 2019 13:39:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EC526B027B; Fri, 24 May 2019 13:39:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F37266B0278
	for <linux-mm@kvack.org>; Fri, 24 May 2019 13:39:04 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 97so3791978plb.7
        for <linux-mm@kvack.org>; Fri, 24 May 2019 10:39:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nyAGe/ZR2qCl2jcH2bXcLfSjZ2XY6PxF57WjX3zmMwM=;
        b=jQr4P1Z7zaw1mPgcvXLs/s7AGjdBPrWCsIQTd8tTrjjb2VWW/oPAQJ57XWXq58icAY
         K1C22kdak7fZ/HZnUWfqrXMjFc4IAV87bwEiMv18/XW2USj7yrOFigqDyUeOLKTJAJv4
         LZvyXG5wHrlHOp1p0C3h9eMjrlxx2vlmkrFWNLrLm9wgfrxdq+DkG3Q4yoWctziMziia
         uxI6gEbJ7044/b4Hr3teKz05JG58EuiQg8LlNrajEE4eVwZgWCuQ69CYbv4qTDHN7gB8
         OA5WBLMrKV1QWM2MXfqt3OfXXci1JOrBaW010nzOPF4SI68tQOyzxNzcBCA49hHbsZDK
         iT5g==
X-Gm-Message-State: APjAAAV7XJjo5ucpLVDdUS2A3zHQwhrENLWQh53Rkm/pXdks+Pbmubum
	q1E5gAJfPyhU3coYD0S1DlYuaXjy9iEdyayPShRfG0MyARksEZ+Pz4WzItxJE8/I3VJhhP2wTjr
	fPPpBwC+HUp5JvyBLADJWVn0czIneID2eAxeGoJXIRdQbbKD0Epn6gsaQoOVsVYGW8g==
X-Received: by 2002:a62:460a:: with SMTP id t10mr113194275pfa.3.1558719544501;
        Fri, 24 May 2019 10:39:04 -0700 (PDT)
X-Received: by 2002:a62:460a:: with SMTP id t10mr113194215pfa.3.1558719543679;
        Fri, 24 May 2019 10:39:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558719543; cv=none;
        d=google.com; s=arc-20160816;
        b=qxbaba/ff8QHEuTRG5K61HTRDqluMEQqTyKy9laarqwC4HKdqTN9IeE65ooV5hbJzQ
         /vPK9ab2PEcdA3CzFHKQT2O/okwT76dfT0ydnM/KHdNPddkSZCrvyPxRKsOmclJTo/IP
         xUsSfy/Ph8pSmTg+AtXkG5WslJYE6Hl4jfag4TxTxQS+kIajCHC1djK/2PWxxdFhwnPz
         hpEAk23QW9MVrUq+LbY9dcAzfKyEJ+ZicfvxOTnAekzEbe6bKKxrOwImc7x4d7na6oxU
         KfejCvH82MTRPEdQyWcm2jTexcnvtsY4OeugGtJlCc93HLd+2X4wtOAz2X5RudJeD/U2
         QO8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nyAGe/ZR2qCl2jcH2bXcLfSjZ2XY6PxF57WjX3zmMwM=;
        b=QtOCbtFpNaoyYLecrk8TAziEhKuyQY4BMPosuZ3QxIA81FZ+QLebFPOszss5curwaa
         4CUuvkCqJCBGESSvVOso73I/pSiadQ3lOykp39g2oKhBWCM+hI090L+nxM1ufaF0vAhs
         pltTbhh/FxBrtkurg1mlh4yaHOrIZ+cjddeOO4jsxpiqT5cybxD0l4l05PPNN2MegrS2
         YVxb6KGiDSuzkq928HNdumTOX71fpQmpLk8iFZPse0QH42e+9dcGr30Cwf8VPO5u0478
         tRHsdfCuOqcPUGEl5+kQ0SHFT/vcSkkcd3NZaX50l4jXexrZj8vOIGEZRBabn0p/rxa5
         xAnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=n6dbur+B;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m11sor4116787plt.30.2019.05.24.10.39.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 10:39:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=n6dbur+B;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=nyAGe/ZR2qCl2jcH2bXcLfSjZ2XY6PxF57WjX3zmMwM=;
        b=n6dbur+BmKYV6EDJkvnaZkqre40ZcNPejsdxgzNShah9xqH4f8tlzpnh/u0urSaM+h
         /1Bex7TxS4+BzabkWmnDSExzJav9EHmLOlwFUrTBOHuC2ppqxpmRitBTVw8gIgrgcU2J
         6QuCqiSGziEklgQoMfPMXD1KTR3+SLCjY/EuoArpsDuE59+kI2P6zrjQQw2k1WI/vpkd
         tIpgna7p1gY56VS4qtUdLXP87qyWkzgeRl/9trETyO3eZD9YFpZx/Fej5T4I9woAPXM7
         d2/ui0ktTyeQJ9tr5hUN7sy52JYWt6oaXNDdKdocc0DIc7c80I5ynG24LSKawjZ3oZV6
         34aQ==
X-Google-Smtp-Source: APXvYqzFawM3FsxaN8KrS37GCCwDD6pToqDos87g5+9DlQY2z4p0UPRIlClDsQs+/e4Ob2Kp2KHscQ==
X-Received: by 2002:a17:902:a407:: with SMTP id p7mr17759721plq.41.1558719542879;
        Fri, 24 May 2019 10:39:02 -0700 (PDT)
Received: from localhost ([2620:10d:c090:180::805])
        by smtp.gmail.com with ESMTPSA id a66sm3340142pfa.89.2019.05.24.10.39.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 10:39:01 -0700 (PDT)
Date: Fri, 24 May 2019 13:39:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: fix page cache convergence regression
Message-ID: <20190524173900.GA11702@cmpxchg.org>
References: <20190524153148.18481-1-hannes@cmpxchg.org>
 <20190524160417.GB1075@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524160417.GB1075@bombadil.infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 09:04:17AM -0700, Matthew Wilcox wrote:
> On Fri, May 24, 2019 at 11:31:48AM -0400, Johannes Weiner wrote:
> > diff --git a/include/linux/xarray.h b/include/linux/xarray.h
> > index 0e01e6129145..cbbf76e4c973 100644
> > --- a/include/linux/xarray.h
> > +++ b/include/linux/xarray.h
> > @@ -292,6 +292,7 @@ struct xarray {
> >  	spinlock_t	xa_lock;
> >  /* private: The rest of the data structure is not to be used directly. */
> >  	gfp_t		xa_flags;
> > +	gfp_t		xa_gfp;
> >  	void __rcu *	xa_head;
> >  };
> 
> No.  I'm willing to go for a xa_flag which says to use __GFP_ACCOUNT, but
> you can't add another element to the struct xarray.

Ok, we can generalize per-tree gfp flags later if necessary.

Below is the updated fix that uses an XA_FLAGS_ACCOUNT flag instead.

---
From 63a0dbc571ff38f7c072c62d6bc28192debe37ac Mon Sep 17 00:00:00 2001
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Fri, 24 May 2019 10:12:46 -0400
Subject: [PATCH] mm: fix page cache convergence regression

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

To fix this, allow xarray users to specify per-tree flag that makes
xarray allocate nodes using __GFP_ACCOUNT. Then restore the page cache
tree annotation to request such cgroup tracking for the cache nodes.

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
 fs/inode.c             |  2 +-
 include/linux/xarray.h |  1 +
 lib/xarray.c           | 12 ++++++++++--
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index e9d18b2c3f91..cd67859dbaf1 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -361,7 +361,7 @@ EXPORT_SYMBOL(inc_nlink);
 
 static void __address_space_init_once(struct address_space *mapping)
 {
-	xa_init_flags(&mapping->i_pages, XA_FLAGS_LOCK_IRQ);
+	xa_init_flags(&mapping->i_pages, XA_FLAGS_LOCK_IRQ | XA_FLAGS_ACCOUNT);
 	init_rwsem(&mapping->i_mmap_rwsem);
 	INIT_LIST_HEAD(&mapping->private_list);
 	spin_lock_init(&mapping->private_lock);
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 0e01e6129145..5921599b6dc4 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -265,6 +265,7 @@ enum xa_lock_type {
 #define XA_FLAGS_TRACK_FREE	((__force gfp_t)4U)
 #define XA_FLAGS_ZERO_BUSY	((__force gfp_t)8U)
 #define XA_FLAGS_ALLOC_WRAPPED	((__force gfp_t)16U)
+#define XA_FLAGS_ACCOUNT	((__force gfp_t)32U)
 #define XA_FLAGS_MARK(mark)	((__force gfp_t)((1U << __GFP_BITS_SHIFT) << \
 						(__force unsigned)(mark)))
 
diff --git a/lib/xarray.c b/lib/xarray.c
index 6be3acbb861f..446b956c9188 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -298,6 +298,8 @@ bool xas_nomem(struct xa_state *xas, gfp_t gfp)
 		xas_destroy(xas);
 		return false;
 	}
+	if (xas->xa->xa_flags & XA_FLAGS_ACCOUNT)
+		gfp |= __GFP_ACCOUNT;
 	xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
 	if (!xas->xa_alloc)
 		return false;
@@ -325,6 +327,8 @@ static bool __xas_nomem(struct xa_state *xas, gfp_t gfp)
 		xas_destroy(xas);
 		return false;
 	}
+	if (xas->xa->xa_flags & XA_FLAGS_ACCOUNT)
+		gfp |= __GFP_ACCOUNT;
 	if (gfpflags_allow_blocking(gfp)) {
 		xas_unlock_type(xas, lock_type);
 		xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
@@ -358,8 +362,12 @@ static void *xas_alloc(struct xa_state *xas, unsigned int shift)
 	if (node) {
 		xas->xa_alloc = NULL;
 	} else {
-		node = kmem_cache_alloc(radix_tree_node_cachep,
-					GFP_NOWAIT | __GFP_NOWARN);
+		gfp_t gfp = GFP_NOWAIT | __GFP_NOWARN;
+
+		if (xas->xa->xa_flags & XA_FLAGS_ACCOUNT)
+			gfp |= __GFP_ACCOUNT;
+
+		node = kmem_cache_alloc(radix_tree_node_cachep, gfp);
 		if (!node) {
 			xas_set_err(xas, -ENOMEM);
 			return NULL;
-- 
2.21.0

