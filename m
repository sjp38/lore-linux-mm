Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FAKE_REPLY_C,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0155DC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 09:28:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C12320679
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 09:28:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W1+dT3FF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C12320679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2BD68E0003; Tue, 30 Jul 2019 05:28:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDBE68E0001; Tue, 30 Jul 2019 05:28:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA3A78E0003; Tue, 30 Jul 2019 05:28:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 718728E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 05:28:53 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so34977238plo.10
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 02:28:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=YuvsEbvLeu9gpGlnWN7D2YTCXaShfpJvy1rRpc/g3Gw=;
        b=EgJ2AQFski8UXHzXl2L+GBSGNa0PlgWD/dlBsJoMlGsSgQJyH2Q1bvXToP5RMsqGq+
         G4764BXfRd4j2yuY88i5S/yMOt239+/4IDlt4LAHIinWZlylhib09jBshT0y1yNEwjTk
         9lO+xzV2pTN1J/HaELy8CmxHnakrLZM7MaLRI+Q5VAgWpjQO0pCgNp9qoOvJAnDe5RdI
         0R4Nk2ndangZ8Jh6Liy194p5Sxeey/8Pld53AwZYLmaqyk2RAIonk74Cz2uDvP6NVQVn
         9tUH3RmOhmfNI/6mjhKl96G5osCYf2gd1zSntqP5A5LAiy8tPJ3ItltdygULpWa60WnI
         2tZA==
X-Gm-Message-State: APjAAAUBEAqscjL4oLJAs/ofJBGhFEwqtXm+iDSVC82ZEBv6jFZO296c
	tigpYhWa0/O40yKYgTjFY5rPIq3LOyslwyODmds/G2VIhApjOYTuO0ezlqY2lC27Bc2/Lgp5h9i
	1mZNKu654S7tji//4aOw4DV4L+5INENqfGnt5v/tfL1BASYaazr6Qzo8lsS/u4LaTaw==
X-Received: by 2002:a17:902:6b85:: with SMTP id p5mr110372153plk.225.1564478932973;
        Tue, 30 Jul 2019 02:28:52 -0700 (PDT)
X-Received: by 2002:a17:902:6b85:: with SMTP id p5mr110372103plk.225.1564478932106;
        Tue, 30 Jul 2019 02:28:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564478932; cv=none;
        d=google.com; s=arc-20160816;
        b=IHUlghqjCh5lA8dVZrUaPttHvFuaZ+vU1Y2d20aPKdXJA4UX/jFvw12/S331WtNiQy
         iaqh1UJE3Sd8DH2hAKeXLzUQtI2HazU4zBhozhGuKiVDYAEK4LBbnSxYr+v/EtVR1+bE
         kRG0KgZASs1pG28FKaw+x+zyTvOz93p3p1JgE/N31Ug685v1rfYnA8UYsdajGcn8ayCT
         hMw1iHaHpBOdx6qtpv4+n4IrxUw9UF7M0QggfCluGtdrMrjMpnQTlEqPIGcdXJn1TIQ6
         1YZ3FTnM2srr0bpScz8eKFw3wO3eYqA6myZm8zlSeaaG5YBcwMsYGnf+LRgwdTJ+NxFC
         2vXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date:dkim-signature;
        bh=YuvsEbvLeu9gpGlnWN7D2YTCXaShfpJvy1rRpc/g3Gw=;
        b=w+YI7Yez84iti8hMCpVDYE/pexwbVSSFy2Sc8exm3PbgVoJ5Z4lulTpS4k7XHJwnoR
         DHbfncSL3sCA8yACLYL3a4WTX4oRZKOFPh2CvnHhPiNGSbvewnjPsTkGn2glEIVMuFLq
         7lnFrhUM1870cYKZS3RB7RPR1F/n1J5ownnJw0at2VbA4vxHIIXBd54bia6/f5M9XCFO
         CsA/KzV4sa9h8gxpuwkmGSj2ftKLKM6D98xi3q2XtT/HCB6jjNWYrEZJeGmBU5yMXeUQ
         u0DBZYp4RNLUahwPjwjZZBXAA/lsXwg5rNIVeV2ZVBLPgDOkuggw67npa/wA10f8jnTg
         NltA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=W1+dT3FF;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o21sor77338694pll.8.2019.07.30.02.28.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 02:28:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=W1+dT3FF;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=YuvsEbvLeu9gpGlnWN7D2YTCXaShfpJvy1rRpc/g3Gw=;
        b=W1+dT3FF153FvLmzoTVoZurqL3wtEb4gbI7pQA4NaeHwdA4jHLKXe/Y8AHo8GYMJJc
         FwYJwg+yfou7K8KVWBENyT27o41tc/NVPcWSnwtIjj7v1Elu/QZgVxi/WXMXzfCszk1P
         5MHRR/kHw3x8mDFbR8KEdbTUQ7u12A5LuEYutVQ2gWN6Aw+eDQBCjGh49nhPm49xAO29
         CK9UE/Kpx5xt2tNdczt1sFwipf2fPEhP+WTy8uAUDZC3g3h8aWQ3pQ3Pv2nZH87dq72n
         cXeqbo7zQRhHI1DBciVPgd39acSyhjfhEH3ggZz9a4MbBwfdvZ9n4R0VAXyPirTFAadh
         mxKA==
X-Google-Smtp-Source: APXvYqxOaGD4tc0XVSmbTm2kbit39tXgiR323mk2jyG0N6edIIeiUIciSLvziX46b8Be1tKtESIWBw==
X-Received: by 2002:a17:902:2baa:: with SMTP id l39mr115483897plb.280.1564478931663;
        Tue, 30 Jul 2019 02:28:51 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id f3sm102458535pfg.165.2019.07.30.02.28.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 02:28:51 -0700 (PDT)
Date: Tue, 30 Jul 2019 14:58:44 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: gregkh@linuxfoundation.org, Matt.Sickler@daktronics.com
Cc: Ira Weiny <ira.weiny@intel.com>, John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v4] staging: kpc2000: Convert
 put_page to put_user_page*()
Message-ID: <20190730092843.GA5150@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

put_page() to put_user_page*()
Reply-To: 
In-Reply-To: <1564058658-3551-1-git-send-email-linux.bhar@gmail.com>

On Thu, Jul 25, 2019 at 06:14:18PM +0530, Bharath Vedartham wrote:
[Forwarding patch to linux-kernel-mentees mailing list]
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Matt Sickler <Matt.Sickler@daktronics.com>
> Cc: devel@driverdev.osuosl.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
> Changes since v1
>         - Improved changelog by John's suggestion.
>         - Moved logic to dirty pages below sg_dma_unmap
>          and removed PageReserved check.
> Changes since v2
>         - Added back PageResevered check as
>         suggested by John Hubbard.
> Changes since v3
>         - Changed the changelog as suggested by John.
>         - Added John's Reviewed-By tag.
> Changes since v4
>         - Rebased the patch on the staging tree.
>         - Improved commit log by fixing a line wrap.
> ---
>  drivers/staging/kpc2000/kpc_dma/fileops.c | 17 ++++++-----------
>  1 file changed, 6 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
> index 48ca88b..f15e292 100644
> --- a/drivers/staging/kpc2000/kpc_dma/fileops.c
> +++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
> @@ -190,9 +190,7 @@ static int kpc_dma_transfer(struct dev_private_data *priv,
>  	sg_free_table(&acd->sgt);
>   err_dma_map_sg:
>   err_alloc_sg_table:
> -	for (i = 0 ; i < acd->page_count ; i++) {
> -		put_page(acd->user_pages[i]);
> -	}
> +	put_user_pages(acd->user_pages, acd->page_count);
>   err_get_user_pages:
>  	kfree(acd->user_pages);
>   err_alloc_userpages:
> @@ -211,16 +209,13 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
>  	BUG_ON(acd->ldev == NULL);
>  	BUG_ON(acd->ldev->pldev == NULL);
>  
> -	for (i = 0 ; i < acd->page_count ; i++) {
> -		if (!PageReserved(acd->user_pages[i])) {
> -			set_page_dirty(acd->user_pages[i]);
> -		}
> -	}
> -
>  	dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
>  
> -	for (i = 0 ; i < acd->page_count ; i++) {
> -		put_page(acd->user_pages[i]);
> +	for (i = 0; i < acd->page_count; i++) {
> +		if (!PageReserved(acd->user_pages[i]))
> +			put_user_pages_dirty(&acd->user_pages[i], 1);
> +		else
> +			put_user_page(acd->user_pages[i]);
>  	}
>  
>  	sg_free_table(&acd->sgt);
> -- 
> 2.7.4
> 

