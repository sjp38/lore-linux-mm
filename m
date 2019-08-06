Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EEC4C32751
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:21:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1FFC2075B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:21:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1FFC2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B1A76B0005; Tue,  6 Aug 2019 14:21:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8629E6B0006; Tue,  6 Aug 2019 14:21:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 729956B0007; Tue,  6 Aug 2019 14:21:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54B516B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 14:21:35 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c1so76440876qkl.7
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 11:21:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vOoIs7ag780szsJEYI4Agd1WO4wtVluQLkkOWVNLUJo=;
        b=pcCVzOCbBBPy2rX3mdcty6k6Ya1J7Bmkq/cE6NrAjNEqQdX8UdiNEHHTw3v7/D/42g
         ldb3iA9rV8KJghQPRd84nj/uHKZZu/8z3+aXwFGFaQewzQtgoP3UK4Yxns4sUSv9Rthv
         G8ns8VmNP2IOzEHmiT/B31NrPWDyOQvYwMYHRQE/vKjuW+JR85NOEFIT14P1lgL+XUri
         Np3ia91QToMW0VN7Vi3lyP+tfLcTERnWOY3uH5WhbActUv75GB/56yBsANV3HdhGd9NL
         ZdIeP8f9jS/WG72PlgCwTAHQeILA1QjjssB6CfZRfy++ek8ZZXpxTln1c5wT7eitVO+b
         4+Zg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW0rXffhqJmgH+LTZv0pHEaTgNItKp6Y6dv7aX0/776XnO/la6M
	SxpyWm/1dyR3ZMqkSreVKoxSculD+7Vp3zeIWHkiZUmoEg7Kh4jr1/yzbWlxHRhl4jP2dWdCBHw
	WBoIEnzh2EoykAIXHKebx/sTy4rI8Naf9poKHtm0OffnsHse5u9YC6L8q/0zmjDSoog==
X-Received: by 2002:a37:4781:: with SMTP id u123mr4144664qka.263.1565115695133;
        Tue, 06 Aug 2019 11:21:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYtv6PdHlfCyqwQVR1WJDB5/gwWA8y0zCEEftA1VEgsX0slNhs6TPx3vovLGJ0TB6H7dGm
X-Received: by 2002:a37:4781:: with SMTP id u123mr4144636qka.263.1565115694614;
        Tue, 06 Aug 2019 11:21:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565115694; cv=none;
        d=google.com; s=arc-20160816;
        b=ivgo0ic3GgCFdBHnaUW5z6RGI20xFavpzBGCekE0jV15gFNf0+wVyT2enUXK3T8rjv
         vvn43Ph80BLzDtM5MjjluocX4MhVYpmE1f687OXRe2mqcakCWLe7M4ctnka+K0A/5pCk
         rF4ePJyfz8R4haVmC5Cbqg+XY2Yn0TQp3kXVnT75aZuRNghT5xpnVzH+FPAc/Qz4shBg
         RSfa4THQ5UaXQof1FuX2zvlxmfM46x7etYfG4e1df+WdIPJmee/1NruKtIkmX+i+UFEZ
         zQOUVkGcnecj6thKH0m1TYgZJSqwwz3xGVXZ29JXwGTVkm9EezJy1ByXG5T0v/QO1yt/
         8E4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vOoIs7ag780szsJEYI4Agd1WO4wtVluQLkkOWVNLUJo=;
        b=sqb2MUi/qqNgZ3Qp5brV4jPEmyLggDGM5I7eNHA3d3NpUhdzeo6C2RV9A7vv5RfAb5
         6353Q0xX4+xHjGc7HDAsbKkeAjfJ/8R/eZ12FRhNtoDppOvktrdbmrXRIlWJtFxlLTUk
         mM/dYqY0Y4yMUAdAi/3PJ9bB+n/59mFGsQCdoYn05Nhmcn8vctdRx6Xks6nxRE/A6dRU
         0vlF09LGhx3vlh4Qi0pcAQzSWJOFNnARjV60KQftrhsIZ7kkjMC5rAtxbqKqIlIyZPME
         QEiI/YmsFvoJF9kmw6Y6vL5w5MupbHIVcNYgLwqLRIlKRDfaXxyitS5saFMJoUTNi+tI
         Dnlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p7si12625216qvo.115.2019.08.06.11.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 11:21:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D25A730253EC;
	Tue,  6 Aug 2019 18:21:33 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 52B3A60BE1;
	Tue,  6 Aug 2019 18:21:33 +0000 (UTC)
Date: Tue, 6 Aug 2019 14:21:31 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 17/24] xfs: don't block kswapd in inode reclaim
Message-ID: <20190806182131.GE2979@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-18-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-18-david@fromorbit.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Tue, 06 Aug 2019 18:21:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 12:17:45PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> We have a number of reasons for blocking kswapd in XFS inode
> reclaim, mainly all to do with the fact that memory reclaim has no
> feedback mechanisms to throttle on dirty slab objects that need IO
> to reclaim.
> 
> As a result, we currently throttle inode reclaim by issuing IO in
> the reclaim context. The unfortunate side effect of this is that it
> can cause long tail latencies in reclaim and for some workloads this
> can be a problem.
> 
> Now that the shrinkers finally have a method of telling kswapd to
> back off, we can start the process of making inode reclaim in XFS
> non-blocking. The first thing we need to do is not block kswapd, but
> so that doesn't cause immediate serious problems, make sure inode
> writeback is always underway when kswapd is running.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/xfs_icache.c | 17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
> index 0b0fd10a36d4..2fa2f8dcf86b 100644
> --- a/fs/xfs/xfs_icache.c
> +++ b/fs/xfs/xfs_icache.c
> @@ -1378,11 +1378,22 @@ xfs_reclaim_inodes_nr(
>  	struct xfs_mount	*mp,
>  	int			nr_to_scan)
>  {
> -	/* kick background reclaimer and push the AIL */
> +	int			sync_mode = SYNC_TRYLOCK;
> +
> +	/* kick background reclaimer */
>  	xfs_reclaim_work_queue(mp);
> -	xfs_ail_push_all(mp->m_ail);
>  
> -	return xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan);
> +	/*
> +	 * For kswapd, we kick background inode writeback. For direct
> +	 * reclaim, we issue and wait on inode writeback to throttle
> +	 * reclaim rates and avoid shouty OOM-death.
> +	 */
> +	if (current_is_kswapd())
> +		xfs_ail_push_all(mp->m_ail);

So we're unblocking kswapd from dirty items, but we already kick the AIL
regardless of kswapd or not in inode reclaim. Why the change to no
longer kick the AIL in the !kswapd case? Whatever the reasoning, a
mention in the commit log would be helpful...

Brian

> +	else
> +		sync_mode |= SYNC_WAIT;
> +
> +	return xfs_reclaim_inodes_ag(mp, sync_mode, &nr_to_scan);
>  }
>  
>  /*
> -- 
> 2.22.0
> 

