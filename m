Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41C9CC4321B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:17:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 100B520B7C
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:17:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 100B520B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6B2B6B0005; Fri, 26 Apr 2019 14:17:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A19D26B000D; Fri, 26 Apr 2019 14:17:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9308F6B000E; Fri, 26 Apr 2019 14:17:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 768366B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 14:17:56 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g28so3401743qtk.7
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 11:17:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MrGBVyYcXAJUXYimoyuqlFYoKGgcIHmFfttazTuK+7s=;
        b=eDE9aYOPHM5n+VMWreWQPFAVkgYr2l3EbYpozMFw4Kgu2ZpU4sozQ5Rg8bSsVsWzl6
         KElNHczBr24YLA2hPrOCf1510jesiUFIlS2e2QwqEl7CvHA6VwgGY6duRvwmp3nGSQHL
         G1KnXrEfCoR0Vvj6hQ6WrirpprZd1Cx1uXM+qnyJpi7Af9fbgE+TdFSbi1q8KIVNAvto
         ynqwyeDwsqxpyZ5T+mt/wM7HkyA1BalGKNYQEEbAL3PbDQ73nAKNQcfg+ZCi1UYy5wzp
         oWbjKiUwgTC9+HTCuiiJltHNfiZCFtf3boUz+yOXO6vN2H6wJX/wqJnV17P2/GIxyQc9
         cjLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX17/DKMjm0OSRWMe+bWxZoXAFUtASczqEnkk0CaauX6IJ2mk97
	XnNistaWeDi6uTozUSknXNEbmVST9gq2/U+3luZtGpu7FR1o0bXZsI6UaXa+BGZR5psK4PPRUWr
	7WzUfrbPjVmbsdgsX13Vp2UmEQwCIbzEYPHK2fMm4y1SfwypCq2nOIEZYwsILscdKSQ==
X-Received: by 2002:a37:79c3:: with SMTP id u186mr25746766qkc.135.1556302676296;
        Fri, 26 Apr 2019 11:17:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxL8J+UZ//ykZp0p4G6EKrd1pdNuH8DVzAgxtaJgKewFA6jMIjIE+9GcB3md/ijpH0DfL4F
X-Received: by 2002:a37:79c3:: with SMTP id u186mr25746726qkc.135.1556302675706;
        Fri, 26 Apr 2019 11:17:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556302675; cv=none;
        d=google.com; s=arc-20160816;
        b=o8WbqW2X7ZRFp+q64SJf4HHjtsAChEM5bXkW4aaHhRudfP164WvE7ksikjKPaJoMfA
         kduPFpRCx390IL/cP+7wlNRqr93I0toLeX0lzlRhXPcoibGLZekLMdBH34qaW58L3PLD
         vEQOaYazsZyxCvWx7loQ5B7DLE9AlFr1jSgfIYBm84W8Si1WGjo0MTWbdY7bvZLYMqo/
         5LPNzeLwr/9q+RRH3BLpoG8cHMbGIXIPYhwsy/qSG+gsWt6f1F5jTDit8Wjuev4SHzBt
         yZeurlIjMcRwMs98DxepBC4KqT/oDjkfTZ2DM+RKpU42kcSOZLZR+afebH4yofFNTMmv
         qhSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MrGBVyYcXAJUXYimoyuqlFYoKGgcIHmFfttazTuK+7s=;
        b=cM7ahchz5s5WKLAaL5KtgMx6NcQwcgt76Y0rbTSf7Bq/dgWP2Xivkl/28UqmPHrJU9
         KujonD0s7po2wwM+hezeD8vbvM1z+iJ3w/tt5CIpGvIoyLzTRGGANdGa21rbnsNZlvrX
         kS+d7EfsuMl3HwYizSh0vCxHl4CkyBSOB7XWTbR68qR+H49YFA3R9wn3pXx+EHU4/m/H
         pGhIi8SMc5u9cBoDQMkKijDUFMQXF9tNsSclGJdmzhnh2Eaw/RARSV+Eyc5LmumGYPsf
         900Ik+hBqN5g1YnF//D1yKVfMY+Hz/dtYhi+ecP1p15PHVttEvYhnMxkP3nf8X/C/aZr
         y4UA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x7si11696604qth.134.2019.04.26.11.17.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 11:17:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F0FE4308A124;
	Fri, 26 Apr 2019 18:17:54 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4B68C60BF3;
	Fri, 26 Apr 2019 18:17:54 +0000 (UTC)
Date: Fri, 26 Apr 2019 14:17:52 -0400
From: Brian Foster <bfoster@redhat.com>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 2/8] xfs: unlock inode when xfs_ioctl_setattr_get_trans
 can't get transaction
Message-ID: <20190426181749.GC34536@bfoster>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
 <155552787973.20411.3438010430489882890.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155552787973.20411.3438010430489882890.stgit@magnolia>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Fri, 26 Apr 2019 18:17:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 12:04:39PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> We passed an inode into xfs_ioctl_setattr_get_trans with join_flags
> indicating which locks are held on that inode.  If we can't allocate a
> transaction then we need to unlock the inode before we bail out.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---

Reviewed-by: Brian Foster <bfoster@redhat.com>

>  fs/xfs/xfs_ioctl.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> 
> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> index ae615a79b266..21d6f433c375 100644
> --- a/fs/xfs/xfs_ioctl.c
> +++ b/fs/xfs/xfs_ioctl.c
> @@ -1153,7 +1153,7 @@ xfs_ioctl_setattr_get_trans(
>  
>  	error = xfs_trans_alloc(mp, &M_RES(mp)->tr_ichange, 0, 0, 0, &tp);
>  	if (error)
> -		return ERR_PTR(error);
> +		goto out_unlock;
>  
>  	xfs_ilock(ip, XFS_ILOCK_EXCL);
>  	xfs_trans_ijoin(tp, ip, XFS_ILOCK_EXCL | join_flags);
> 

