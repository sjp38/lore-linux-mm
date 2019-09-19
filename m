Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A2BDC4CEC4
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:26:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B66C21929
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:26:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AvugnqvM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B66C21929
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBE436B031E; Wed, 18 Sep 2019 21:26:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B48CE6B031F; Wed, 18 Sep 2019 21:26:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0F566B0320; Wed, 18 Sep 2019 21:26:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0149.hostedemail.com [216.40.44.149])
	by kanga.kvack.org (Postfix) with ESMTP id 717996B031E
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:26:25 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0353A8122
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:26:25 +0000 (UTC)
X-FDA: 75949929888.18.bike20_37f3ca0f11e0c
X-HE-Tag: bike20_37f3ca0f11e0c
X-Filterd-Recvd-Size: 3862
Received: from mail-wr1-f65.google.com (mail-wr1-f65.google.com [209.85.221.65])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:26:24 +0000 (UTC)
Received: by mail-wr1-f65.google.com with SMTP id v8so1293368wrt.2
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 18:26:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Fq+RpFCn2McWuMg3C5OlmcYZSlU9P8enqlr/h4VhVAg=;
        b=AvugnqvMBEU2/e4eEo1SBrNXBDNXJgxlc+8OulchbPWmdEAonz0hLIBLOVLlL9G+q6
         F0DT9/X4lY65BMyqV6XI7DiNNDQF9bm1hFV4roW8v/5Q4SFZEtwjpk+X0dSaeb5g6rAF
         NBDKiBJ8in6K9vJGs3YiBBKvICzIsloJLgxrz0dmtAuExPQyOEZ7wkXAaN37jOvsH3Ct
         MfqejGKk9X4FVBLosvLumd0vUakjx3eG2Wco6D2tThQL6rsG02giNV2o62u3WzZqDQeq
         Js3I5VuDMmddVuCG+N2ye4LcOj/X1bocqfx84VXMYFO5KItYOd06OB8sI9DVZdp8Dfvf
         1Ejg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=Fq+RpFCn2McWuMg3C5OlmcYZSlU9P8enqlr/h4VhVAg=;
        b=PdV69ABaVYfUF+w/Zw+sRoReKMoMtPi35BXqB0xdK2hLnI2QKmH4GRREpvVpSN2aKo
         qLHRIa90WnWbJznt5gr7nTkwMyg8QHs+TgJJLFw3xi3z2IEj/+HCCT+auX6iM9MZOEE0
         8ngLK7WCSIJ7lQs4z/5CsMUSLx6YUbEyQR08TZGFJZwwQPVKAbbJkIv86+/w65lmv/ww
         jAh70bbgICGxgEwuBNI1NFSeE3/i3dLWvrZvmp/fcltwS0MEyIr+5T/DOz7vSMxWH9gA
         Jec3GNvg1dAUTId/F8idNAWbUnY5Rv6yQzCpJcQL4lFpuKuJBei2tg2nzVe8lxiExeBu
         Y9lw==
X-Gm-Message-State: APjAAAXMLFWxa+b72gmGkdxTA+aRIf7L26cj2twXo10zPaoyeBGDbsa+
	rynpRvkNSp8Qy1g/ehTy1D4=
X-Google-Smtp-Source: APXvYqycZBvXFbe7Rt4Loa6FLejQrVV/zV6+SXTUHjTMG5YBdUo3RXSkmobHDRFcivZ/nknGK8MI3w==
X-Received: by 2002:adf:9083:: with SMTP id i3mr5434855wri.310.1568856382862;
        Wed, 18 Sep 2019 18:26:22 -0700 (PDT)
Received: from archlinux-threadripper ([2a01:4f8:222:2f1b::2])
        by smtp.gmail.com with ESMTPSA id f13sm4400000wmj.17.2019.09.18.18.26.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Sep 2019 18:26:22 -0700 (PDT)
Date: Wed, 18 Sep 2019 18:26:20 -0700
From: Nathan Chancellor <natechancellor@gmail.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	clang-built-linux@googlegroups.com,
	Davidlohr Bueso <dave@stgolabs.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Ilie Halip <ilie.halip@gmail.com>,
	David Bolvansky <david.bolvansky@gmail.com>
Subject: Re: [PATCH] hugetlbfs: hugetlb_fault_mutex_hash cleanup
Message-ID: <20190919012620.GA72561@archlinux-threadripper>
References: <20190919011847.18400-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190919011847.18400-1-mike.kravetz@oracle.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 18, 2019 at 06:18:47PM -0700, Mike Kravetz wrote:
> A new clang diagnostic (-Wsizeof-array-div) warns about the calculation
> to determine the number of u32's in an array of unsigned longs. Suppress
> warning by adding parentheses.
> 
> While looking at the above issue, noticed that the 'address' parameter
> to hugetlb_fault_mutex_hash is no longer used. So, remove it from the
> definition and all callers.
> 
> No functional change.
> 
> Reported-by: Nathan Chancellor <natechancellor@gmail.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks for the patch!

Reviewed-by: Nathan Chancellor <natechancellor@gmail.com>

