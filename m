Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47CFFC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:50:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D0A9208CB
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:50:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D0A9208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 971B06B0003; Thu, 20 Jun 2019 01:50:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 922188E0002; Thu, 20 Jun 2019 01:50:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 810908E0001; Thu, 20 Jun 2019 01:50:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 31C646B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:50:33 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so2657512ede.23
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:50:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3T44utvmtBO3o2QILLRC35Gdr9y9LM81Qc8eYWW3mvg=;
        b=C9LWZb8XOdKfsJYFvjusCtZW58Fp8ozGF8SQ08lpR+2prkDHKjKkTBnZbijqct/ZH2
         JRgDN5T+YCDgQsLNBaeDyPEGPdZik6bV/bNCvUZjbx5qKvvTcGFQzhVxqXuWweLH0DxQ
         6Cwpjd4dNExUwIsuYiMzPa4S2AZ+KCWhVr+I5kRZTw+h84Y5DhVLUZgtfVz0EFWQrazo
         3Kdrq+hJAEpJPeTxoVwqoW9Kbe8zA3JxUS3kjuA1+Hcvmy9Srvzn75CYQIm+fzBgmLlD
         4x6JUMrTzLFKwF2wcovzCutO7ta5bpaw5IrsuOdwGTgkgAvt629fxqh0puM7FzgH6+PC
         RwrQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVOQbLw+dV4dy50vGCNcBcC/CrIUa+v8UAKvGMah34L7h1KVDBO
	CDnlI1RH45gBpqwh54VOzhSYkcLOs5aI168Lar0pYrqSM5MUcL0bIh9/xErpL6TlTpjjnhbNFQD
	SOmLinvujq8AmfmkBLW78OvBG8OdZTtijjMs5C3pspR9K8SabkGh37wLbcFXksVA=
X-Received: by 2002:a50:8e9d:: with SMTP id w29mr108115659edw.103.1561009832753;
        Wed, 19 Jun 2019 22:50:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdnjPGOukQSb7RQWK8EOuaY+XAhJFQaOrkmM0OurIXfWF+cU+1VQhc0jcDCzUjZS5jxzsS
X-Received: by 2002:a50:8e9d:: with SMTP id w29mr108115607edw.103.1561009831963;
        Wed, 19 Jun 2019 22:50:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561009831; cv=none;
        d=google.com; s=arc-20160816;
        b=mKDgQnduEGdnSdTBDXIcfNkyBPBr7OYcTJJevL1pwax/QoYYNc/iWalxSoqpVaPJ7Q
         HZhh5VG7izaKHkZ+8ldsnFF4LbJKWfcttBDUPwYG8JikKBNDn4wOBNYAewFV9+gS95iS
         j+T5Sg80+eTK0WzLiMmUoUGGiRR70ubHL2TTb1mDdT+9JUQh4C2e2TeKZKZ9eZiqGcP8
         2uuzfkkisSG2K9olsKze6q9WQP9MGObCmLWQscR9pXnVvsblf4xrjwdudMdkXjb66bKe
         KwF+OkC+/LvJ/S5eHz1ErHgTCqoiiUWOw/P5iSAOjJyJOhoXLDAxIisiBljneEm6si7K
         u4/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3T44utvmtBO3o2QILLRC35Gdr9y9LM81Qc8eYWW3mvg=;
        b=bd/ymmjelntAMpgnCpQf6ZEBxJm1D86g4dCQq61e2vmfDxF665933yWdt3oT9tPa2T
         ApHE8gGHX/w19c5/Pww2zocx8Iqqd8OKxIqwYGkaanLPDTcQK+wo7R8NmtH5YVH2gzYo
         0U+IAZQOBufk9ST2GDLz+Xwx49+VNyUvnL7pLR7gGcMBAvBF2Gy5mZTDGLLzoah8dxhF
         bO4bl96wGu6RSXf8EhQxP3rFIc40Xr11o1jGjJbTOnEHlKdj0wb7QmmKuWVxgXL5bVRS
         o8CPRPzo1IZ0d7OuAkF86UYqySdIMFe78rik2MmAYBrLH9Nh4DkrqlvUWN/r3bnq2viP
         OfsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k49si16457130ede.209.2019.06.19.22.50.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 22:50:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4B5A0AC2C;
	Thu, 20 Jun 2019 05:50:31 +0000 (UTC)
Date: Thu, 20 Jun 2019 07:50:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, cgroups@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: [PATCH] slub: Don't panic for memcg kmem cache creation failure
Message-ID: <20190620055028.GA12083@dhcp22.suse.cz>
References: <20190619232514.58994-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619232514.58994-1-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 19-06-19 16:25:14, Shakeel Butt wrote:
> Currently for CONFIG_SLUB, if a memcg kmem cache creation is failed and
> the corresponding root kmem cache has SLAB_PANIC flag, the kernel will
> be crashed. This is unnecessary as the kernel can handle the creation
> failures of memcg kmem caches.

AFAICS it will handle those by simply not accounting those objects
right?

> Additionally CONFIG_SLAB does not
> implement this behavior. So, to keep the behavior consistent between
> SLAB and SLUB, removing the panic for memcg kmem cache creation
> failures. The root kmem cache creation failure for SLAB_PANIC correctly
> panics for both SLAB and SLUB.

I do agree that panicing is really dubious especially because it opens
doors to shut the system down from a restricted environment. So the
patch makes sesne to me.

I am wondering whether SLAB_PANIC makes sense in general though. Why is
it any different from any other essential early allocations? We tend to
not care about allocation failures for those on bases that the system
must be in a broken state to fail that early already. Do you think it is
time to remove SLAB_PANIC altogether?

> Reported-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/slub.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 6a5174b51cd6..84c6508e360d 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3640,10 +3640,6 @@ static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
>  
>  	free_kmem_cache_nodes(s);
>  error:
> -	if (flags & SLAB_PANIC)
> -		panic("Cannot create slab %s size=%u realsize=%u order=%u offset=%u flags=%lx\n",
> -		      s->name, s->size, s->size,
> -		      oo_order(s->oo), s->offset, (unsigned long)flags);
>  	return -EINVAL;
>  }
>  
> -- 
> 2.22.0.410.gd8fdbe21b5-goog

-- 
Michal Hocko
SUSE Labs

