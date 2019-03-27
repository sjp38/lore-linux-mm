Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E89C1C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:44:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DC7A2075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:44:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DC7A2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF2AC6B0003; Wed, 27 Mar 2019 04:44:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA4196B0006; Wed, 27 Mar 2019 04:44:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B92C36B0007; Wed, 27 Mar 2019 04:44:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 694DB6B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:44:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k8so3231811edl.22
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 01:44:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PKLJpfaatigxa/68bz3dhGB2fcN+C6M6PSNO0Uj1Zd8=;
        b=mISWyhT+38nUe6YjHGzVY33awdhb4Ngzpo683GR1uMSRIj35WIotjHbEYxTMMonM7f
         AKoPUV/WgcdSt0f5HuqVveOxePnYqIdIfoROqEE+BK3nV46l7dfPnhbtgPPpP98K2MG+
         yWhFASqOlD8kho+XWnok28sPoW44UVbLXl2IBEkAAHSdCdv6+DyQzNod/Tf3UHMrIf0C
         2rWY/Ox2cQzfWU6/erPBz74vVVTzxUDAI9G7hkyS93WwlTin0bTAH7O6klp29+0+TFDC
         j5VpnN6Ja8YATu9ZuSMQyqYLNJJr0ryrPeca5daiBqvhodn01B+86/dW+ElBopIusIKd
         aMBQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXdRvELtrQenuzGVlWoTApo5EoRNbmEC64y7x5HbFSDmJ+OmYFN
	SMXiM7V530ANXP0fE8zutTF+cvBXa4y1TgphWK5ulYeLdRp36plDU6jC+nZ7m91WOwd/ndqJOq8
	IkCOct2Yb4REEIPnq+HZMK5ktzMrq8ZbV0m8J4L4ekE35DPQg0FCHCWH0hxhzxO0=
X-Received: by 2002:a17:906:4a48:: with SMTP id a8mr20544081ejv.57.1553676277956;
        Wed, 27 Mar 2019 01:44:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycmxK2iN/V9y70dhb4DzaaY4t4qLe2+c1RsmIfnGg7yV+akp23R++ABBcXfXDM+STnew84
X-Received: by 2002:a17:906:4a48:: with SMTP id a8mr20544030ejv.57.1553676276832;
        Wed, 27 Mar 2019 01:44:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553676276; cv=none;
        d=google.com; s=arc-20160816;
        b=TBNYMCwlc7SIbamx8qKOMvy85r871Lsu7GL2t9bWA6Pt1nWguyktmtag9dNQHaH3NP
         3uyDA4oBF6jUushCmfdM+7eE+ZcRDByJxmo+pyZEksOYicEpv3vzz99BAx1X0wn6Kpbm
         3apA0o5t0p8IOaZ4PseNtTZjET+qZRwRO2uDC1hQ3GYncgYPMhz1QkCcSruEuO8QIqZ1
         2OUxxBWQZN8UDcKiyfOSxWxbtjoa2XDqMDUFRk+O4bgyU1kS4x0n0E72sAkvuhYRLnbz
         UXtzI2S+iCKuaIz9Frc8gh5ZRT8HRGFLP5AwpCm4VE4X1LyluvAsslhXnDKtTUKLbkwi
         1rrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PKLJpfaatigxa/68bz3dhGB2fcN+C6M6PSNO0Uj1Zd8=;
        b=wpN/C7v5ECQpk1GyyokiKQqXfthwRaMirksntrzAMdjKXwlFAWTvx2/fesXUlYTdDk
         F/vYM3tySdAEwgNk85Um/xLkfd4ePYE3k7QKIbeWvtsj863B6Ijz/SEF4EtDYtIkbEPA
         FyDtFwtJ5QvqVRILrbmL2zBamZcyUKBBxYXXNlr4BTnbXl4WVAqYFgpdC+50iQfPzuIO
         pS8hSpxsnirwaejHXBYdYSnF8ZCZVSXWy166x7kLHcXOCnlPQb/us3BTr1uVfic3OzMM
         BpoV4B+hHihDQnQmP8JDXOf9tLG3tmj7ZGostF9hVZO2A2aTH+0HCTVnln9rrnNTrzig
         OIlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si3546530ejg.22.2019.03.27.01.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 01:44:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3FFF3AC3D;
	Wed, 27 Mar 2019 08:44:35 +0000 (UTC)
Date: Wed, 27 Mar 2019 09:44:32 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, cl@linux.com,
	willy@infradead.org, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190327084432.GA11927@dhcp22.suse.cz>
References: <20190327005948.24263-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190327005948.24263-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 20:59:48, Qian Cai wrote:
[...]
> Unless there is a brave soul to reimplement the kmemleak to embed it's
> metadata into the tracked memory itself in a foreseeable future, this
> provides a good balance between enabling kmemleak in a low-memory
> situation and not introducing too much hackiness into the existing
> code for now. Another approach is to fail back the original allocation
> once kmemleak_alloc() failed, but there are too many call sites to
> deal with which makes it error-prone.

As long as there is an implicit __GFP_NOFAIL then kmemleak is simply
broken no matter what other gfp flags you play with. Has anybody looked
at some sort of preallocation where gfpflags_allow_blocking context
allocate objects into a pool that non-sleeping allocations can eat from?

> kmemleak: Cannot allocate a kmemleak_object structure
> kmemleak: Kernel memory leak detector disabled
> kmemleak: Automatic memory scanning thread ended
> RIP: 0010:__alloc_pages_nodemask+0x242a/0x2ab0
> Call Trace:
>  allocate_slab+0x4d9/0x930
>  new_slab+0x46/0x70
>  ___slab_alloc+0x5d3/0x9c0
>  __slab_alloc+0x12/0x20
>  kmem_cache_alloc+0x30a/0x360
>  create_object+0x96/0x9a0
>  kmemleak_alloc+0x71/0xa0
>  kmem_cache_alloc+0x254/0x360
>  mempool_alloc_slab+0x3f/0x60
>  mempool_alloc+0x120/0x329
>  bio_alloc_bioset+0x1a8/0x510
>  get_swap_bio+0x107/0x470
>  __swap_writepage+0xab4/0x1650
>  swap_writepage+0x86/0xe0
> 
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
> 
> v4: Update the commit log.
>     Fix a typo in comments per Christ.
>     Consolidate the allocation.
> v3: Update the commit log.
>     Simplify the code inspired by graph_trace_open() from ftrace.
> v2: Remove the needless checking for NULL objects in slab_post_alloc_hook()
>     per Catalin.
> 
>  mm/kmemleak.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index a2d894d3de07..7f4545ab1f84 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -580,7 +580,16 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
>  	struct rb_node **link, *rb_parent;
>  	unsigned long untagged_ptr;
>  
> -	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> +	/*
> +	 * The tracked memory was allocated successful, if the kmemleak object
> +	 * failed to allocate for some reasons, it ends up with the whole
> +	 * kmemleak disabled, so try it harder.
> +	 */
> +	gfp = (in_atomic() || irqs_disabled()) ?
> +	       gfp_kmemleak_mask(gfp) | GFP_ATOMIC :
> +	       gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;


The comment for in_atomic says:
 * Are we running in atomic context?  WARNING: this macro cannot
 * always detect atomic context; in particular, it cannot know about
 * held spinlocks in non-preemptible kernels.  Thus it should not be
 * used in the general case to determine whether sleeping is possible.
 * Do not use in_atomic() in driver code.

-- 
Michal Hocko
SUSE Labs

