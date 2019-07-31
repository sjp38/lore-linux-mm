Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88F1EC41514
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:59:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 421F72089E
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:59:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 421F72089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1E4C8E0003; Wed, 31 Jul 2019 05:59:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCED58E0001; Wed, 31 Jul 2019 05:59:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBE448E0003; Wed, 31 Jul 2019 05:59:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 829458E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:59:55 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id v125so12845826wme.5
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:59:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KfQ1GOxa2gwawYjZESEw8m6ZN1EOeLyab9IzRAQRkB8=;
        b=aUK4oSR4GcOZYTj+pnHk1lwW+A250PBbNQZLdta5eGEb2HNQSlXmJu8xlqIrSLTtz8
         Kvqq/1i2Wh7+H+I2e/SnAamQRM35PAIkK7wXoO32fot+/V5XqXKUSC5Oye+cGP9Vnh7N
         rULovRzSNkLIRJ7XA7f96dlfHch+soo0JE+YIbkHrcw2xm7g9OQW5kSTQmiaG8llkFBg
         gE2NZqRoqHcWJmt5snmstGQwFMoYmuknqA3/8VPoXf7DCg7SVgOSeog143hAN14Iq57/
         EWeuZr+tP1oH44YGMJT39jPOrkeoo0op+nzCygdCEPufi8CMMpE5jemm98hZd5fFm6u+
         e9Bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sgarzare@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sgarzare@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV0GuIjbVxmNZu9SkCR9HSqfcAtbcepKFCvMHxMd4gpteqd+apF
	bl/1WIZnBG9Dq5wbdJRrmPC+7JhXei7mBMSiLI2h1dyKmgilkMPC/34aHQ226mxAzurH3rLPjv/
	COP+7B7kXUVaSzt/w+uSg1Rijs5PvnSQ/WvZI1HkYp1GoFw0R/LlO6Ox5BVt+Luq4yQ==
X-Received: by 2002:adf:da4d:: with SMTP id r13mr31221580wrl.281.1564567195046;
        Wed, 31 Jul 2019 02:59:55 -0700 (PDT)
X-Received: by 2002:adf:da4d:: with SMTP id r13mr31221478wrl.281.1564567194251;
        Wed, 31 Jul 2019 02:59:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564567194; cv=none;
        d=google.com; s=arc-20160816;
        b=x+SNPg3ktAh9TB2ktjCiTGbrgni+X1kLkFIdDA86bdaAfBintRecsCZJBlCheofcho
         xnQ1mp2Xs5z4lyoCMUXfr5ecgAFHZBEuE89ivvrviQ/K/TUDBVCr4s41Yhtt0bcoLxMt
         MZL0bwqLsIZi8yQ9pUSK2lUSvq8y6N14Ru52Whgi5e+yJ5pq1gm/ieTdnPxk9VWZRsug
         wxLAa1OS71MfjbZftNl5kP5HotT9PkltUNkcGmE2oRSfLlNTRlpPMqjzn9dHEh7bboHb
         QNP7ytRtSIOYbnXsuGoC+1AlxCRq2A6UV35HwDdkuBv2K7l0MD/DdYtmE2WCNOPHOAT9
         xXnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KfQ1GOxa2gwawYjZESEw8m6ZN1EOeLyab9IzRAQRkB8=;
        b=GHmaSUts+oW3Fn+kHxDtGYprhMtHU0Zv/UOsK51tXHykQydiNA4MeYr59a58yed+qY
         dxpeXLu3sSUn0p9VAmZuGxsP4ccpPy0xC/v3MhMVR7Gmgbfejo4DGhIIzmNXspBpyeWP
         CP072vhtVkxKWnmsKak143qMyVu0cLLmtjEPSCrJkOibgdPPYdm5TQVCmJJVgyu6cP0v
         QXJsSFNPJGQm8NlmL+Lqpp/PLlbL2FJQeZJTMXOca0RMEhVW1b65fYpjpqfbhBL5QLA5
         sBwF5wOEOlSG0wz+egahu9Sl+9feco03zsc9yRNCqp3JPYI11wZ9/uz2d6wP3RWNm8Lo
         zQ4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sgarzare@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sgarzare@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s129sor38034219wmf.18.2019.07.31.02.59.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 02:59:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of sgarzare@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sgarzare@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sgarzare@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqy7/iEU1UrL2it0Ep7+ooQdkQ6xuUDFbcpqjrWR2xbr/ulDYf5qm8/eQpzBooD00tKHJ19RcQ==
X-Received: by 2002:a05:600c:230c:: with SMTP id 12mr12821673wmo.151.1564567193839;
        Wed, 31 Jul 2019 02:59:53 -0700 (PDT)
Received: from steredhat (host122-201-dynamic.13-79-r.retail.telecomitalia.it. [79.13.201.122])
        by smtp.gmail.com with ESMTPSA id d10sm79226236wro.18.2019.07.31.02.59.52
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 02:59:53 -0700 (PDT)
Date: Wed, 31 Jul 2019 11:59:50 +0200
From: Stefano Garzarella <sgarzare@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, jgg@ziepe.ca
Subject: Re: [PATCH V2 9/9] vhost: do not return -EAGIAN for non blocking
 invalidation too early
Message-ID: <20190731095950.d6zr472megt7rgkt@steredhat>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-10-jasowang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731084655.7024-10-jasowang@redhat.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A little typo in the title: s/EAGIAN/EAGAIN

Thanks,
Stefano

On Wed, Jul 31, 2019 at 04:46:55AM -0400, Jason Wang wrote:
> Instead of returning -EAGAIN unconditionally, we'd better do that only
> we're sure the range is overlapped with the metadata area.
> 
> Reported-by: Jason Gunthorpe <jgg@ziepe.ca>
> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/vhost.c | 32 +++++++++++++++++++-------------
>  1 file changed, 19 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index fc2da8a0c671..96c6aeb1871f 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -399,16 +399,19 @@ static void inline vhost_vq_sync_access(struct vhost_virtqueue *vq)
>  	smp_mb();
>  }
>  
> -static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
> -				      int index,
> -				      unsigned long start,
> -				      unsigned long end)
> +static int vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
> +				     int index,
> +				     unsigned long start,
> +				     unsigned long end,
> +				     bool blockable)
>  {
>  	struct vhost_uaddr *uaddr = &vq->uaddrs[index];
>  	struct vhost_map *map;
>  
>  	if (!vhost_map_range_overlap(uaddr, start, end))
> -		return;
> +		return 0;
> +	else if (!blockable)
> +		return -EAGAIN;
>  
>  	spin_lock(&vq->mmu_lock);
>  	++vq->invalidate_count;
> @@ -423,6 +426,8 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
>  		vhost_set_map_dirty(vq, map, index);
>  		vhost_map_unprefetch(map);
>  	}
> +
> +	return 0;
>  }
>  
>  static void vhost_invalidate_vq_end(struct vhost_virtqueue *vq,
> @@ -443,18 +448,19 @@ static int vhost_invalidate_range_start(struct mmu_notifier *mn,
>  {
>  	struct vhost_dev *dev = container_of(mn, struct vhost_dev,
>  					     mmu_notifier);
> -	int i, j;
> -
> -	if (!mmu_notifier_range_blockable(range))
> -		return -EAGAIN;
> +	bool blockable = mmu_notifier_range_blockable(range);
> +	int i, j, ret;
>  
>  	for (i = 0; i < dev->nvqs; i++) {
>  		struct vhost_virtqueue *vq = dev->vqs[i];
>  
> -		for (j = 0; j < VHOST_NUM_ADDRS; j++)
> -			vhost_invalidate_vq_start(vq, j,
> -						  range->start,
> -						  range->end);
> +		for (j = 0; j < VHOST_NUM_ADDRS; j++) {
> +			ret = vhost_invalidate_vq_start(vq, j,
> +							range->start,
> +							range->end, blockable);
> +			if (ret)
> +				return ret;
> +		}
>  	}
>  
>  	return 0;
> -- 
> 2.18.1
> 

-- 

