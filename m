Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74EF0C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:27:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3847F2087C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:27:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3847F2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2ED36B0006; Fri,  2 Aug 2019 11:27:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDF3E6B0008; Fri,  2 Aug 2019 11:27:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF4C86B000A; Fri,  2 Aug 2019 11:27:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC9FD6B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 11:27:41 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f28so68340911qtg.2
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 08:27:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5RapArjsF7mW3eo1495Qi0PwyW6i71GjMNBqii8jOL8=;
        b=ZihmsHJtaL+t2fRryLsjybZ+MUo6Cxi/+3GObk/SkF9dMeUWPTNuQLePdmrTyjzrdt
         4xLaOry6lHwW/LBp/oyOXp0tg/zgX11WISc+w+g/i9B/QlF1U258hh2oO6VSruw7lOhv
         sD9ed6raQ5d9Rs9mcrcC4Mar+mLfKgilQkngrmsTBFzzwxIahBdR7bSmk7L/TG/HTxsB
         fnKxzYUYu5t4VBg+vO0FUDU8HpKU3mUNOX1dRSHFjSJ2GKxGcvWNkZC+TVTP4Xhd87yO
         mmTZo16J/XODXk8ds7t78a1wFlcGNOyNsc6hRjqVNLxmOshu+hPtlF8QttaDFKMlEemZ
         Q7/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU+RQ5RO6oXLmlabkK3X6Kt+23zC/jYz/b/eoQmhJg/7qZnhWgB
	SupU77cWzA39f+XBzgmM2HMsxErJyCnBJDWwVh7gkfJ/zSBioCBXwiIvIw2RX8NthIGiuLzx46k
	TysFJ/x4q7GJw2zfC6RDkI7kHrR12tbBQ3GfryVfJ+bg9rPmwblpBoC4yH6I7jDPhPQ==
X-Received: by 2002:aed:2b01:: with SMTP id p1mr97543955qtd.33.1564759661477;
        Fri, 02 Aug 2019 08:27:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoUxw65ge/RcyWPnSfraVc+jVHeBPQeZGT9EXnBVKqsaCLjwcgkG/b9TNo//MYSQKpVkfB
X-Received: by 2002:aed:2b01:: with SMTP id p1mr97543906qtd.33.1564759660819;
        Fri, 02 Aug 2019 08:27:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564759660; cv=none;
        d=google.com; s=arc-20160816;
        b=yFrzMvdDhPqkyoBGuCGsEif5Zut9sa3LpM1fE2V+EQ4Ta6FYIdLYFrn2/Lw50qm1mu
         cXu2onae2tw5MsTLE5IdldVBaillrxVcD/b50NRVSZ4EFXkxggO/bb1ec8sPNnlW3G1x
         bElcrfsxWK2Ckrr29H6T/aDIRfpo5QCAHzLFZFmoYdIUoIkYa7sFfPeSuAlzWDXZOs1J
         TtVCwgo+dl9lUaeq6DDX5Xq+uKkRgw1svgJC9hle9Lin0T8Xz+ThxgCf6QdB134A1ovJ
         xc+YaBi29d9BsHNAXumnBC56b55o5GrTDF/ucjK+TqppUkr34+Z2zivgDCjjg30/X0ou
         vE1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5RapArjsF7mW3eo1495Qi0PwyW6i71GjMNBqii8jOL8=;
        b=hF8vtE94+bdngFyWYzrRlmEzkbZpGFcjt+aMVI+VPP+vicExte7B+9SGe7gzzoBlrk
         pYAJV5ubd4WViPm0vdWYX/Y2XQCJ1wAh9wxe6j87HUPueb4HImFnCMsu3ed4LZyy7+iw
         SuCRLbp4d6eBqSwygeBKBJJS4GfNKCK+Q2dWuWV67zYxRTal24q9VItYVcs+5lGSFYaC
         jKmX1ppdBcAlwpsM5AThITVTfEtxZjYosHOEJwxk9RfqQghvNJ8wCvR/SpzX9ftylucv
         zNzkzxebpM7wNq83ap7ZgMVtf8cJ+7Ne3shUt8fwReqjA9BuQ/8epQK1Jg6n/HU66QAO
         +t7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q31si3559419qvf.103.2019.08.02.08.27.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 08:27:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1098B307D985;
	Fri,  2 Aug 2019 15:27:40 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 83B935D9D3;
	Fri,  2 Aug 2019 15:27:39 +0000 (UTC)
Date: Fri, 2 Aug 2019 11:27:37 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 02/24] shrinkers: use will_defer for GFP_NOFS sensitive
 shrinkers
Message-ID: <20190802152737.GB60893@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-3-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-3-david@fromorbit.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 02 Aug 2019 15:27:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 12:17:30PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> For shrinkers that currently avoid scanning when called under
> GFP_NOFS contexts, conver them to use the new ->will_defer flag
> rather than checking and returning errors during scans.
> 
> This makes it very clear that these shrinkers are not doing any work
> because of the context limitations, not because there is no work
> that can be done.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  drivers/staging/android/ashmem.c |  8 ++++----
>  fs/gfs2/glock.c                  |  5 +++--
>  fs/gfs2/quota.c                  |  6 +++---
>  fs/nfs/dir.c                     |  6 +++---
>  fs/super.c                       |  6 +++---
>  fs/xfs/xfs_buf.c                 |  4 ++++
>  fs/xfs/xfs_qm.c                  | 11 ++++++++---
>  net/sunrpc/auth.c                |  5 ++---
>  8 files changed, 30 insertions(+), 21 deletions(-)
> 
...
> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> index ca0849043f54..6e0f76532535 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -1680,6 +1680,10 @@ xfs_buftarg_shrink_count(
>  {
>  	struct xfs_buftarg	*btp = container_of(shrink,
>  					struct xfs_buftarg, bt_shrinker);
> +
> +	if (!(sc->gfp_mask & __GFP_FS))
> +		sc->will_defer = true;
> +
>  	return list_lru_shrink_count(&btp->bt_lru, sc);
>  }

This hunk looks like a behavior change / bug fix..? The rest of the
patch converts existing logic to bail out of scans to use the new count
time defer mechanism. The change is probably fine, but I think we should
have a separate patch to introduce this behavior in the first place
(which BTW could be sent as a standalone patch and just picked up by
this on eventual rebase).

Brian

>  
> diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
> index 5e7a37f0cf84..13c842e8f13b 100644
> --- a/fs/xfs/xfs_qm.c
> +++ b/fs/xfs/xfs_qm.c
> @@ -502,9 +502,6 @@ xfs_qm_shrink_scan(
>  	unsigned long		freed;
>  	int			error;
>  
> -	if ((sc->gfp_mask & (__GFP_FS|__GFP_DIRECT_RECLAIM)) != (__GFP_FS|__GFP_DIRECT_RECLAIM))
> -		return 0;
> -
>  	INIT_LIST_HEAD(&isol.buffers);
>  	INIT_LIST_HEAD(&isol.dispose);
>  
> @@ -534,6 +531,14 @@ xfs_qm_shrink_count(
>  	struct xfs_quotainfo	*qi = container_of(shrink,
>  					struct xfs_quotainfo, qi_shrinker);
>  
> +	/*
> +	 * __GFP_DIRECT_RECLAIM is used here to avoid blocking kswapd
> +	 */
> +	if ((sc->gfp_mask & (__GFP_FS|__GFP_DIRECT_RECLAIM)) !=
> +					(__GFP_FS|__GFP_DIRECT_RECLAIM)) {
> +		sc->will_defer = true;
> +	}
> +
>  	return list_lru_shrink_count(&qi->qi_lru, sc);
>  }
>  
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index cdb05b48de44..6babcbac4a00 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -527,9 +527,6 @@ static unsigned long
>  rpcauth_cache_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  
>  {
> -	if ((sc->gfp_mask & GFP_KERNEL) != GFP_KERNEL)
> -		return SHRINK_STOP;
> -
>  	/* nothing left, don't come back */
>  	if (list_empty(&cred_unused))
>  		return SHRINK_STOP;
> @@ -541,6 +538,8 @@ static unsigned long
>  rpcauth_cache_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
>  
>  {
> +	if ((sc->gfp_mask & GFP_KERNEL) != GFP_KERNEL)
> +		sc->will_defer = true;
>  	return number_cred_unused * sysctl_vfs_cache_pressure / 100;
>  }
>  
> -- 
> 2.22.0
> 

