Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E403BC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:22:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8B7220717
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:22:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8B7220717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A63D6B0006; Tue,  6 Aug 2019 14:22:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5539A6B0007; Tue,  6 Aug 2019 14:22:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46B2C6B0008; Tue,  6 Aug 2019 14:22:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 271636B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 14:22:17 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f28so79805997qtg.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 11:22:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=udIwRQKBxYqLyzD8onTe02z1jJFu+JV1PRVr7oBr+Ck=;
        b=crKwwONok23Ybm9vRUW87pfABjm2UHTfHt53T3Osp9/CHAsuFYCTn5OXqTZWXBq0OI
         o4jR6nvZg8rWjIkpLYj/jZOKQf1yLrgNR9eiotXzNzbED5NDkLf1VQTMDl3/w70nm04r
         YkiZRdqffKBiuGssFNJksYK2aux1JTdPHv+01SJiXhVmO2nTThmlvu2ajqY9QZewFF+k
         hA8zYzPQwidY2uH8jjUVRKBYjeGrFmrO7SaVKzJto4dl0MOurkt2yh41Cc403MUxJDLe
         hgc/hpCAjUXbpmOY4Y+sfAlf+BBmN03MYA/+R47v/Rp/v9wp05Y6CziQ97axnUOkJMEg
         rNEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW3k3W8QRv7SdwzSdFEkH9lVZDg7i5vymNWVQzcnIzvoJaOuW+G
	TwYf3cgMkktwKQl++UWsjthIsFArpvdnDNkpe7lMa4ILuJif78jGtSmS/xMzG26FcaPlqqsmFEe
	WrbwAcpe6/Y6JheRoivtgnyHP3KeKhkGrpHnpSXJf8sLZUzNez1Fi/1YUsNgNvKpCeA==
X-Received: by 2002:ad4:55a9:: with SMTP id f9mr4358018qvx.133.1565115736952;
        Tue, 06 Aug 2019 11:22:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIQjkW1IULOPqy75l4i/MDb/a0H9JSBVQyyeKvIdTXmBteX6I+QuVRe2Nl84H3S1N2Xjz9
X-Received: by 2002:ad4:55a9:: with SMTP id f9mr4357988qvx.133.1565115736384;
        Tue, 06 Aug 2019 11:22:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565115736; cv=none;
        d=google.com; s=arc-20160816;
        b=SeEOepRGVhlgPjbduJeV5Uc+Ro96/2teEZs6cZkewd6uXZ0fkK+JmYRRQeNoe6GFQ+
         oc9QmijGLEEv/swjGt79qCTYiCJFA+xr3udx54kYNp8gxWoI57FG56rz0MX7sqUc4rHR
         e9sd2JfX1+hhG6hj3YWiI/GGxfSsl+sdPW0b9fDVKvokdOMsDtLOAau+EFuHYivhxZgf
         42uSbQWKDP9aniwU3yPiQOuhYB+n8XCV/IR7lO3RO2tvgtyRHNJNFrx1op5IAGLJ9uJw
         BgyeuT4k5Fe1UjjgpYhBRu0bkcsP3yAgNaWEhyrkJwXMv4RjLJzFp81yJHLb1JIQANAf
         WVcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=udIwRQKBxYqLyzD8onTe02z1jJFu+JV1PRVr7oBr+Ck=;
        b=vZ4sR77mwxMv6Bhyh3AsK3nvVMUQ1j08sR1k720JMGRps4cHHHiINyMxjCdVW0zD6C
         SCdn50kVTwlY/MjmfJ6cV469L0nfeAcoLdFcd5ZD+CXM0WwgjMdj/3nufHZd0Z/7umWO
         xeJDa+GatE15CvCOatdq3n7A881qfLNT5JXl2UCA3Y+Twg8MLYqk4+MVzuG6RbVPfj8I
         0sKEpB66CoBocS+aBmp2LiCOX/QFL5BtzbxVB2ZH64H9ypN5zxzkLEWpQ+JsvjgVSGdF
         9EL/dyC0sM0jNFFX3fWoKxyo0aS1M1ndaRqUCbWr4sx17blDz3IA5svXc1HnEzcS62Wp
         /vVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c18si339683qte.53.2019.08.06.11.22.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 11:22:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 936F71E30F;
	Tue,  6 Aug 2019 18:22:15 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0E1B95C258;
	Tue,  6 Aug 2019 18:22:14 +0000 (UTC)
Date: Tue, 6 Aug 2019 14:22:13 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 18/24] xfs: reduce kswapd blocking on inode locking.
Message-ID: <20190806182213.GF2979@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-19-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-19-david@fromorbit.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 06 Aug 2019 18:22:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 12:17:46PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> When doing async node reclaiming, we grab a batch of inodes that we
> are likely able to reclaim and ignore those that are already
> flushing. However, when we actually go to reclaim them, the first
> thing we do is lock the inode. If we are racing with something
> else reclaiming the inode or flushing it because it is dirty,
> we block on the inode lock. Hence we can still block kswapd here.
> 
> Further, if we flush an inode, we also cluster all the other dirty
> inodes in that cluster into the same IO, flush locking them all.
> However, if the workload is operating on sequential inodes (e.g.
> created by a tarball extraction) most of these inodes will be
> sequntial in the cache and so in the same batch
> we've already grabbed for reclaim scanning.
> 
> As a result, it is common for all the inodes in the batch to be
> dirty and it is common for the first inode flushed to also flush all
> the inodes in the reclaim batch. In which case, they are now all
> going to be flush locked and we do not want to block on them.
> 

Hmm... I think I'm missing something with this description. For dirty
inodes that are flushed in a cluster via reclaim as described, aren't we
already blocking on all of the flush locks by virtue of the synchronous
I/O associated with the flush of the first dirty inode in that
particular cluster?

Brian

> Hence, for async reclaim (SYNC_TRYLOCK) make sure we always use
> trylock semantics and abort reclaim of an inode as quickly as we can
> without blocking kswapd.
> 
> Found via tracing and finding big batches of repeated lock/unlock
> runs on inodes that we just flushed by write clustering during
> reclaim.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/xfs_icache.c | 23 ++++++++++++++++++-----
>  1 file changed, 18 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
> index 2fa2f8dcf86b..e6b9030875b9 100644
> --- a/fs/xfs/xfs_icache.c
> +++ b/fs/xfs/xfs_icache.c
> @@ -1104,11 +1104,23 @@ xfs_reclaim_inode(
>  
>  restart:
>  	error = 0;
> -	xfs_ilock(ip, XFS_ILOCK_EXCL);
> -	if (!xfs_iflock_nowait(ip)) {
> -		if (!(sync_mode & SYNC_WAIT))
> +	/*
> +	 * Don't try to flush the inode if another inode in this cluster has
> +	 * already flushed it after we did the initial checks in
> +	 * xfs_reclaim_inode_grab().
> +	 */
> +	if (sync_mode & SYNC_TRYLOCK) {
> +		if (!xfs_ilock_nowait(ip, XFS_ILOCK_EXCL))
>  			goto out;
> -		xfs_iflock(ip);
> +		if (!xfs_iflock_nowait(ip))
> +			goto out_unlock;
> +	} else {
> +		xfs_ilock(ip, XFS_ILOCK_EXCL);
> +		if (!xfs_iflock_nowait(ip)) {
> +			if (!(sync_mode & SYNC_WAIT))
> +				goto out_unlock;
> +			xfs_iflock(ip);
> +		}
>  	}
>  
>  	if (XFS_FORCED_SHUTDOWN(ip->i_mount)) {
> @@ -1215,9 +1227,10 @@ xfs_reclaim_inode(
>  
>  out_ifunlock:
>  	xfs_ifunlock(ip);
> +out_unlock:
> +	xfs_iunlock(ip, XFS_ILOCK_EXCL);
>  out:
>  	xfs_iflags_clear(ip, XFS_IRECLAIM);
> -	xfs_iunlock(ip, XFS_ILOCK_EXCL);
>  	/*
>  	 * We could return -EAGAIN here to make reclaim rescan the inode tree in
>  	 * a short while. However, this just burns CPU time scanning the tree
> -- 
> 2.22.0
> 

