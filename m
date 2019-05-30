Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9840C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:15:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77BA825D83
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:15:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="iLQl/tzl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77BA825D83
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D4BE6B0274; Thu, 30 May 2019 12:15:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 085F26B0275; Thu, 30 May 2019 12:15:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8EE16B0276; Thu, 30 May 2019 12:15:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B080F6B0274
	for <linux-mm@kvack.org>; Thu, 30 May 2019 12:15:57 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q2so4230346plr.19
        for <linux-mm@kvack.org>; Thu, 30 May 2019 09:15:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QdCnbVnvU3JKpvLwtQ0RZP1XXmjXKTawTWYBTDGInu4=;
        b=WUl4x9YohvEHBIy3Vg6ZQdGsyDYeQBayriT3LfXDcoCdPtp6eTcSHL9ufp5ovHPwHu
         cnH+0EEPA/sG5FlOI84HkTdhN7USgG5tt0EX5L+5hWZeASzy6q9o0tB5CNEFt6sheI01
         DoFZdZx9gdz4FW04vOCs/234EUBXi2WHi/qh3B6UpyswlintAjDq18+r7RQhjrZj7rxE
         OqyfRRJsDHmVcq+D7iJ9iYhbtmlQn8Zp+BDrYCeoOsBNftehgjaxY5htshpUoeP36Auz
         GEXpIpeF9+jbKT67ynwKwFJpcs/I0XEw4JgMb4p2NQnjByHnk/7vUKMeZZvUTAxnD9KH
         hWTA==
X-Gm-Message-State: APjAAAWDyq7x9p1rK+V1pMoS2HEWMnvZA4QmUUjubySeigER/N5nlErB
	WCvjg4Ac7muxlG7T2qAQUASrAjfhDGIUaEYiAGixvUSgqGPyAV/9GZdcKIUY3s7CIJMtyTDuzgb
	zOGt/B/lbnKI7gLjgf6IuHG+TMVwwa1p7bl1ULECaA21ytlyrHo/NNKy0e9rTDDnFJA==
X-Received: by 2002:a17:902:868b:: with SMTP id g11mr4311627plo.183.1559232957240;
        Thu, 30 May 2019 09:15:57 -0700 (PDT)
X-Received: by 2002:a17:902:868b:: with SMTP id g11mr4311558plo.183.1559232956184;
        Thu, 30 May 2019 09:15:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559232956; cv=none;
        d=google.com; s=arc-20160816;
        b=UQPQuVxLU0FYtzCuwS06vjK9lwvfn3sooIVQd2n7pejB2rp2nPoOYq+UwGjo0Ho2gL
         4az/teAvt8uHBNm/TCCtivtUa5/3eLj4PwkUuwQJAujMNjMN4TT7P0RreDZ5As2U4EZ9
         LPSeDuIWyBSY9OOQLjyPPDcitmADM/2Zh4zAyjrUER0bS+9ICrbylOSYXIUxZ4xnW1eW
         Ea9374L1f4R/kz0WpsoBqCfu+L5CfGrAHzXtP+i+DgwTl4uAVPO4g7R7oEEY6MZki2rO
         7iEZoLJ+13+QpHIw18XvpOlH9PlATnBaY+Ojym7a2l1gFMQpCBgQ0JyFaptkW/hXEGOw
         GeGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QdCnbVnvU3JKpvLwtQ0RZP1XXmjXKTawTWYBTDGInu4=;
        b=df8wfncKW/hb0uRXji49jcCq+b7+x5NlXNo5N1BhvmGgIiRv4s/Vu3eTKvcq2S3q52
         ZWmeBQLtKsgvH4DdD5bouYF5QVIjEqMN31BDZWbDy8la/vFOD0e872BURtO4X71SSurV
         /o8ZEeMdQBZL9FSC7/2D5yJe91At+bcAdkaIbu3CYvkfuXOxhm3nQManfY1s1Fy9Oo7U
         +3jyVfcslZssjZLhG0n4dAv/9tcSqvmUabTTqQ2vNw9AB2gROSGp16+auPSAQWYx+FlU
         7QlApnIuSKeFJmYyJXRET0weT28+B5e7F4wbF4LkH67bb0vsqlNVWAqjC2hIRbt4Ykc1
         Eq+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="iLQl/tzl";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a37sor3678189pje.3.2019.05.30.09.15.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 09:15:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="iLQl/tzl";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QdCnbVnvU3JKpvLwtQ0RZP1XXmjXKTawTWYBTDGInu4=;
        b=iLQl/tzlA9IoLss9iCFQI/uNGICbYiY4oejGcOmvASeKUe1o9NBlHzZdiKIU2xU58Y
         3pKqXYhhLPDvcUMN7eyQqGRC4IryxuvQMWpUXEv8jnvIzDG7kZZg9PxBjkDzEFxg+RQf
         IVDhR19utfM7z+cRwAL4kdXgETyC+JmOUaA4KHKVd+GagQ+bXc+lAzNsMdpe3bzXPDPx
         KDOv/heXOJc5v7KdT7sv1ibco32xt7Ynm8VHLcvCtns9QqQ/Lj7JCkgVMV9pp/OkoWPD
         Zcc+T3tyl96dUAbeOBndyhsXipIkP4D9akQIpA985eo1aayznx92rFD0B7fd/9tZaa6C
         VapA==
X-Google-Smtp-Source: APXvYqzdneacRJ3jMe8/a4aYeOWI8YILi6WoYZXJpCLl8ovLvQkhojhfLpNV90VPB11YoHs72pAphw==
X-Received: by 2002:a17:90a:240c:: with SMTP id h12mr4366079pje.12.1559232951269;
        Thu, 30 May 2019 09:15:51 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::7ef9])
        by smtp.gmail.com with ESMTPSA id s42sm7645186pjc.5.2019.05.30.09.15.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 09:15:50 -0700 (PDT)
Date: Thu, 30 May 2019 12:15:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: fix page cache convergence regression
Message-ID: <20190530161548.GA8415@cmpxchg.org>
References: <20190524153148.18481-1-hannes@cmpxchg.org>
 <20190524160417.GB1075@bombadil.infradead.org>
 <20190524173900.GA11702@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524173900.GA11702@cmpxchg.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Are there any objections or feedback on the proposed fix below? This
is kind of a serious regression.

On Fri, May 24, 2019 at 01:39:00PM -0400, Johannes Weiner wrote:
> From 63a0dbc571ff38f7c072c62d6bc28192debe37ac Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Fri, 24 May 2019 10:12:46 -0400
> Subject: [PATCH] mm: fix page cache convergence regression
> 
> Since a28334862993 ("page cache: Finish XArray conversion"), on most
> major Linux distributions, the page cache doesn't correctly transition
> when the hot data set is changing, and leaves the new pages thrashing
> indefinitely instead of kicking out the cold ones.
> 
> On a freshly booted, freshly ssh'd into virtual machine with 1G RAM
> running stock Arch Linux:
> 
> [root@ham ~]# ./reclaimtest.sh
> + dd of=workingset-a bs=1M count=0 seek=600
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + ./mincore workingset-a
> 153600/153600 workingset-a
> + dd of=workingset-b bs=1M count=0 seek=600
> + cat workingset-b
> + cat workingset-b
> + cat workingset-b
> + cat workingset-b
> + ./mincore workingset-a workingset-b
> 104029/153600 workingset-a
> 120086/153600 workingset-b
> + cat workingset-b
> + cat workingset-b
> + cat workingset-b
> + cat workingset-b
> + ./mincore workingset-a workingset-b
> 104029/153600 workingset-a
> 120268/153600 workingset-b
> 
> workingset-b is a 600M file on a 1G host that is otherwise entirely
> idle. No matter how often it's being accessed, it won't get cached.
> 
> While investigating, I noticed that the non-resident information gets
> aggressively reclaimed - /proc/vmstat::workingset_nodereclaim. This is
> a problem because a workingset transition like this relies on the
> non-resident information tracked in the page cache tree of evicted
> file ranges: when the cache faults are refaults of recently evicted
> cache, we challenge the existing active set, and that allows a new
> workingset to establish itself.
> 
> Tracing the shrinker that maintains this memory revealed that all page
> cache tree nodes were allocated to the root cgroup. This is a problem,
> because 1) the shrinker sizes the amount of non-resident information
> it keeps to the size of the cgroup's other memory and 2) on most major
> Linux distributions, only kernel threads live in the root cgroup and
> everything else gets put into services or session groups:
> 
> [root@ham ~]# cat /proc/self/cgroup
> 0::/user.slice/user-0.slice/session-c1.scope
> 
> As a result, we basically maintain no non-resident information for the
> workloads running on the system, thus breaking the caching algorithm.
> 
> Looking through the code, I found the culprit in the above-mentioned
> patch: when switching from the radix tree to xarray, it dropped the
> __GFP_ACCOUNT flag from the tree node allocations - the flag that
> makes sure the allocated memory gets charged to and tracked by the
> cgroup of the calling process - in this case, the one doing the fault.
> 
> To fix this, allow xarray users to specify per-tree flag that makes
> xarray allocate nodes using __GFP_ACCOUNT. Then restore the page cache
> tree annotation to request such cgroup tracking for the cache nodes.
> 
> With this patch applied, the page cache correctly converges on new
> workingsets again after just a few iterations:
> 
> [root@ham ~]# ./reclaimtest.sh
> + dd of=workingset-a bs=1M count=0 seek=600
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + cat workingset-a
> + ./mincore workingset-a
> 153600/153600 workingset-a
> + dd of=workingset-b bs=1M count=0 seek=600
> + cat workingset-b
> + ./mincore workingset-a workingset-b
> 124607/153600 workingset-a
> 87876/153600 workingset-b
> + cat workingset-b
> + ./mincore workingset-a workingset-b
> 81313/153600 workingset-a
> 133321/153600 workingset-b
> + cat workingset-b
> + ./mincore workingset-a workingset-b
> 63036/153600 workingset-a
> 153600/153600 workingset-b
> 
> Cc: stable@vger.kernel.org # 4.20+
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  fs/inode.c             |  2 +-
>  include/linux/xarray.h |  1 +
>  lib/xarray.c           | 12 ++++++++++--
>  3 files changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index e9d18b2c3f91..cd67859dbaf1 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -361,7 +361,7 @@ EXPORT_SYMBOL(inc_nlink);
>  
>  static void __address_space_init_once(struct address_space *mapping)
>  {
> -	xa_init_flags(&mapping->i_pages, XA_FLAGS_LOCK_IRQ);
> +	xa_init_flags(&mapping->i_pages, XA_FLAGS_LOCK_IRQ | XA_FLAGS_ACCOUNT);
>  	init_rwsem(&mapping->i_mmap_rwsem);
>  	INIT_LIST_HEAD(&mapping->private_list);
>  	spin_lock_init(&mapping->private_lock);
> diff --git a/include/linux/xarray.h b/include/linux/xarray.h
> index 0e01e6129145..5921599b6dc4 100644
> --- a/include/linux/xarray.h
> +++ b/include/linux/xarray.h
> @@ -265,6 +265,7 @@ enum xa_lock_type {
>  #define XA_FLAGS_TRACK_FREE	((__force gfp_t)4U)
>  #define XA_FLAGS_ZERO_BUSY	((__force gfp_t)8U)
>  #define XA_FLAGS_ALLOC_WRAPPED	((__force gfp_t)16U)
> +#define XA_FLAGS_ACCOUNT	((__force gfp_t)32U)
>  #define XA_FLAGS_MARK(mark)	((__force gfp_t)((1U << __GFP_BITS_SHIFT) << \
>  						(__force unsigned)(mark)))
>  
> diff --git a/lib/xarray.c b/lib/xarray.c
> index 6be3acbb861f..446b956c9188 100644
> --- a/lib/xarray.c
> +++ b/lib/xarray.c
> @@ -298,6 +298,8 @@ bool xas_nomem(struct xa_state *xas, gfp_t gfp)
>  		xas_destroy(xas);
>  		return false;
>  	}
> +	if (xas->xa->xa_flags & XA_FLAGS_ACCOUNT)
> +		gfp |= __GFP_ACCOUNT;
>  	xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
>  	if (!xas->xa_alloc)
>  		return false;
> @@ -325,6 +327,8 @@ static bool __xas_nomem(struct xa_state *xas, gfp_t gfp)
>  		xas_destroy(xas);
>  		return false;
>  	}
> +	if (xas->xa->xa_flags & XA_FLAGS_ACCOUNT)
> +		gfp |= __GFP_ACCOUNT;
>  	if (gfpflags_allow_blocking(gfp)) {
>  		xas_unlock_type(xas, lock_type);
>  		xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
> @@ -358,8 +362,12 @@ static void *xas_alloc(struct xa_state *xas, unsigned int shift)
>  	if (node) {
>  		xas->xa_alloc = NULL;
>  	} else {
> -		node = kmem_cache_alloc(radix_tree_node_cachep,
> -					GFP_NOWAIT | __GFP_NOWARN);
> +		gfp_t gfp = GFP_NOWAIT | __GFP_NOWARN;
> +
> +		if (xas->xa->xa_flags & XA_FLAGS_ACCOUNT)
> +			gfp |= __GFP_ACCOUNT;
> +
> +		node = kmem_cache_alloc(radix_tree_node_cachep, gfp);
>  		if (!node) {
>  			xas_set_err(xas, -ENOMEM);
>  			return NULL;
> -- 
> 2.21.0
> 

