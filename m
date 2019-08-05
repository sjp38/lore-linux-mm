Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D05AC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 18:03:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEC94206A2
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 18:03:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEC94206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 703A06B0005; Mon,  5 Aug 2019 14:03:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B3E86B0006; Mon,  5 Aug 2019 14:03:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C91C6B0007; Mon,  5 Aug 2019 14:03:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38FDD6B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 14:03:05 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 199so73446571qkj.9
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 11:03:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xtvtHFx28fQQ9VkwdoYkM5aGi6ibQWkc3tFRo/DhKss=;
        b=pTuFJjfRbCFryVPMSjo8VFKhxuXnNJmo8oGRvmcWEZOUMgW0UWdgxNdJbRTb08ZAFd
         g5fGQwwrZ6DW542Un3seaojJrtV8Pf6Lt3HWOEvWm29ZRNP3wFh9DUz32D1DQBcAFJNe
         286ZPPt6jrKmMbbnqrPF3+Tarn7Oxg+8hKC7Gi1y4xRCbsxyIXB72vVM9Ys8JJ6PnN4F
         Kdt382/ceEDpVi6IeZmoCEkyyveyKEyd1Y2OJ0IHYw3K7p7iPX4ky9Z9r+J0bf6ox/Ib
         AkTn/18UjAMHvofHeWXINXVkYWS3JSYm6jhg+GauCicwHfUO8IuekazESDuEBzGoS7bo
         ONhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWK+mbC4NrfnyRjyBuKLdqyKXRCRBiEEpOCA+nqS0zlLC8N/Rvk
	B81u4dqbu/XcGpKI4WHS6N9Tc6KStg7gdDPdTdhxGaLXNhbf+HH//RM2Z+t2GfNWhUE+zJVk8DN
	SW77eOHYmE27INjy7XKpVOejx6yuB3TPi0Vp4qk/wr4KsyEQcaZDEnrdTwgaQw/g4bg==
X-Received: by 2002:ac8:488a:: with SMTP id i10mr10264716qtq.93.1565028184995;
        Mon, 05 Aug 2019 11:03:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWZZlaFhy6zYWpfXq9aqrB5tgM7ipLrIqJJf2E10zKBroyZqhLf1hYE+9NL/UWwKtqKJEx
X-Received: by 2002:ac8:488a:: with SMTP id i10mr10264663qtq.93.1565028184299;
        Mon, 05 Aug 2019 11:03:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565028184; cv=none;
        d=google.com; s=arc-20160816;
        b=YgMc1DTc91bhEo7BggFIR7JDL4Ii4QuU7kLhw6jIZIBGsFEMemBIdUIDw/gywelpBV
         S4Vp/y12P69xRNA1gWuG3f5z4wUblajzkLcKSVlh6GrWT8cNiCDNv1If+u81RD0fWIkU
         c5w7rg5Gp2W4lOVqDwJ1bcr3uNy5k2jktxO/YFBEJJO7tKBlOh7iAQWtOEi5DVGu6Azn
         yoHAwkrXyAWqOvgSW9qwzMctuVhXW5eiMqVC5Y3pbIlqK2b6aV9F7LTnBg/OD8qp5zT2
         P9h/QWgoKXiC+3lXOJzp+XxUvPSV19WjKZxTOADSNAJh4GENA/+C8/g0VHnxfqoAQU7+
         HDOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xtvtHFx28fQQ9VkwdoYkM5aGi6ibQWkc3tFRo/DhKss=;
        b=lsSVn2rwv3J/64UxIj+zr+s3x7PQF9XrXTXVGBDCEjw4EE4Z49n5CNcnGaXkALTU6t
         mUph0vxrvAsxNBGK2JXdcGerWxKALM+k2EJ6hC3iHN4YJz7jmXQnPALaYbglgYy6OiB+
         4fSHmcfQkbYCW+8DdqpswVwCDBog64xObsHYM3M22RnBsUnxrwL6tIjDSLFVYnckcTPr
         CjP2H68bXzP0a27hs4PWP/DaN6HH5M6xj0Xwqsj7Q4BY77DR+rcmjDKS1WizolmvBsT0
         tFf9fNhLCGzs1pwrh4BIAp8/o+p2GjKwq6JU5jwnc2u4t4MAzg5xwTA81xI3+2PMfrq2
         iOtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 36si53844225qvr.14.2019.08.05.11.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 11:03:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 79A5930224AC;
	Mon,  5 Aug 2019 18:03:03 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EF9065C1D4;
	Mon,  5 Aug 2019 18:03:02 +0000 (UTC)
Date: Mon, 5 Aug 2019 14:03:01 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 15/24] xfs: eagerly free shadow buffers to reduce CIL
 footprint
Message-ID: <20190805180300.GE14760@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-16-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-16-david@fromorbit.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 05 Aug 2019 18:03:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 12:17:43PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> The CIL can pin a lot of memory and effectively defines the lower
> free memory boundary of operation for XFS. The way we hang onto
> log item shadow buffers "just in case" effectively doubles the
> memory footprint of the CIL for dubious reasons.
> 
> That is, we hang onto the old shadow buffer in case the next time
> we log the item it will fit into the shadow buffer and we won't have
> to allocate a new one. However, we only ever tend to grow dirty
> objects in the CIL through relogging, so once we've allocated a
> larger buffer the old buffer we set as a shadow buffer will never
> get reused as the amount we log never decreases until the item is
> clean. And then for buffer items we free the log item and the shadow
> buffers, anyway. Inode items will hold onto their shadow buffer
> until they are reclaimed - this could double the inode's memory
> footprint for it's lifetime...
> 
> Hence we should just free the old log item buffer when we replace it
> with a new shadow buffer rather than storing it for later use. It's
> not useful, get rid of it as early as possible.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/xfs_log_cil.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/xfs/xfs_log_cil.c b/fs/xfs/xfs_log_cil.c
> index fa5602d0fd7f..1863a9bdf4a9 100644
> --- a/fs/xfs/xfs_log_cil.c
> +++ b/fs/xfs/xfs_log_cil.c
> @@ -238,9 +238,7 @@ xfs_cil_prepare_item(
>  	/*
>  	 * If there is no old LV, this is the first time we've seen the item in
>  	 * this CIL context and so we need to pin it. If we are replacing the
> -	 * old_lv, then remove the space it accounts for and make it the shadow
> -	 * buffer for later freeing. In both cases we are now switching to the
> -	 * shadow buffer, so update the the pointer to it appropriately.
> +	 * old_lv, then remove the space it accounts for and free it.
>  	 */

The comment above xlog_cil_alloc_shadow_bufs() needs a similar update
around how we handle the old buffer when the shadow buffer is used.

>  	if (!old_lv) {
>  		if (lv->lv_item->li_ops->iop_pin)
> @@ -251,7 +249,8 @@ xfs_cil_prepare_item(
>  
>  		*diff_len -= old_lv->lv_bytes;
>  		*diff_iovecs -= old_lv->lv_niovecs;
> -		lv->lv_item->li_lv_shadow = old_lv;
> +		kmem_free(old_lv);
> +		lv->lv_item->li_lv_shadow = NULL;
>  	}

So IIUC this is the case where we allocated a shadow buffer, the item
was already pinned (so old_lv is still around) but we ended up using the
shadow buffer for this relog. Instead of keeping the old buffer around
as a new shadow, we toss it. That makes sense, but if the objective is
to not leave dangling shadow buffers around as such, what about the case
where we allocated a shadow buffer but didn't end up using it because
old_lv was reusable? It looks like we still keep the shadow buffer
around in that scenario with a similar lifetime as the swapout scenario
this patch removes. Hm?

Brian

>  
>  	/* attach new log vector to log item */
> -- 
> 2.22.0
> 

