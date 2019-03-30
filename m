Return-Path: <SRS0=krm6=SB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B994C43381
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 15:33:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D32E5218A6
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 15:33:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="OTcZC1+D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D32E5218A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F7036B0003; Sat, 30 Mar 2019 11:33:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A5BF6B0006; Sat, 30 Mar 2019 11:33:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 296BB6B0007; Sat, 30 Mar 2019 11:33:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE70C6B0003
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 11:33:18 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id r190so1930965oie.13
        for <linux-mm@kvack.org>; Sat, 30 Mar 2019 08:33:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4GAUNn1jlLkHDaow21lIHTP+Puz2N/vLdbErLotRvmA=;
        b=PvXFPqadCQ3jouL5JMmyJAlw6e8f+RnYykb2kb6nhMf6wpMOGPJc22eJDNcGw81Pbs
         xLyukrnPinpp12uAOPk9HyfmE/yVzzbGCd0GmILffVPvDK05ussk4CJr9BZydSuzXWv6
         pye3CyelMaZIQ0mVUVjfrcqZDoayuqjT+RO4IO4UAWDcDGRr2WdRSQnZflEZ3TtMi3jv
         vAg56mY/igeWIVTBaZABIjNmthMm6nqVZbbEtAhjt67y19t9Xi3CQcbexHhr2cCOKab/
         ym8J4xhGVKKMYR98f8w80d+6VqcADUWTPLGz/l93/Gjfpii/rHIc8ktAG9FDeSlGXK5Q
         yXSQ==
X-Gm-Message-State: APjAAAXI8G6F0lEqIY/1wVPvwoKCJowjoNNVjRtrS6svGRKtxOqf6FRZ
	vAwbfCsh8jW0ydfUT8ggrypDem5JIzobOnyAZQmjze2T0blWFj+L/iisHWQpwbktxM+rX0cPe1O
	brM6btAGtFQyxSp9cr1ryrYAUtypnCHQ2uOEsunYs4CWExH0RHALF04whi/rbHZ9c7A==
X-Received: by 2002:a9d:6d92:: with SMTP id x18mr23257482otp.112.1553959998540;
        Sat, 30 Mar 2019 08:33:18 -0700 (PDT)
X-Received: by 2002:a9d:6d92:: with SMTP id x18mr23257448otp.112.1553959997903;
        Sat, 30 Mar 2019 08:33:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553959997; cv=none;
        d=google.com; s=arc-20160816;
        b=fPLHCy3s5A44uOxH3VYcG/chOSWL+GdBXNiFsl2FCIcavSP5pDRAVyidGlAYAOSMwV
         ncicD6iqe4yLBMZavCXMC3Bv1hDag1bYPXe+HolaVwAU63GsPwJoeiogDumL/0+rZ8pD
         t8TXLB6AoAysZl3nGKgpVZvPMKX9IY1jkswmlry19XBFsD46SJA9pvz57mP0rvk+6nuU
         z4rJQ5d/FadsCoOMEtPhrP20UPu3Mae8Rcla7ZrOyPnlAlZ2sTwbppVsD8BrWCc5b6Hl
         sunY54vqBUDdVmuvCunkRvcP9V0/0XZFmZtzqCeY0UwpK2xVN3REHs1uXqmYHbLtJyg5
         toBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4GAUNn1jlLkHDaow21lIHTP+Puz2N/vLdbErLotRvmA=;
        b=ou6pD+wPGSmRywHCCVqNTch/L8HjXbFP2wpS8pjSfpeacOHGtO+xiBFyBg5ywcvfEw
         cADIjNwNnqLTYs5O5xd9cDdw6kLEtD3XHCmxmDOBs6nvJ88jryrsutsmH0mxFVHcW1aq
         UQIqyrMGA9gjuQJUR1YwdFJyCqlE0iK3IWQAzoli5XRmMuDCUS1u9Y3MQdOEJt14519D
         fz59cgpQSbeHvLaiWcVAQz6vbCsP8QZpkks0EO4KF3wAnob/KZ0Fo5rBKiX+6aQ91LNI
         3upV7A0zxeqCPG5p9Qo66HNxnGdOopTwgMHx9isBi/SdLz/KwoVs930kXAX5yO0qjTHv
         MDVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=OTcZC1+D;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w85sor2951210oie.139.2019.03.30.08.33.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 30 Mar 2019 08:33:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=OTcZC1+D;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4GAUNn1jlLkHDaow21lIHTP+Puz2N/vLdbErLotRvmA=;
        b=OTcZC1+Dt6ADlK4IHQNx0ywCtFYFyG3aSyhIdIIkTnbYvgCqUDXgR7a0/kZjfTMTgV
         UnULf3uZMjUQFPBtxNWHJjiTiLWdo9BY7I3W8zBY+3Q1YpsFg/yMJzfflNCs+LUl39M2
         Bg3rKuRl4Ly/wKbIE3BFXgfu/nq7fGGKrjYQCHKqBqMOsfxEOBtYOdlG7rZC+DUuFpT2
         B9JU/LLUR2aBjjfB1UoVR/vEt+zgRhgYgNPtedsOGKZN1/QRY/KOhcFqV7Zt58z1Zu+B
         N8Q5Z6mymxjd3DJPq3vjf5ZQxaY6znI64vrd0HCKEIEK5tJ+i+Otzv2jezGInmZsaKCk
         12Yw==
X-Google-Smtp-Source: APXvYqyTSOpqIN7uIlKFUYlk5hlpF2z/2pdp+qirv56Y99XuV3yvIMDZKwXw04w36vdc1cu+n8LNwnd45GHpTlNqydQ=
X-Received: by 2002:aca:d513:: with SMTP id m19mr7133565oig.73.1553959997075;
 Sat, 30 Mar 2019 08:33:17 -0700 (PDT)
MIME-Version: 1.0
References: <20190330054205.28005-1-aneesh.kumar@linux.ibm.com>
In-Reply-To: <20190330054205.28005-1-aneesh.kumar@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 30 Mar 2019 08:33:05 -0700
Message-ID: <CAPcyv4h60V+1pnsF28AJQrFjNbU2jp6G+wVeEucxVbo-RETXOg@mail.gmail.com>
Subject: Re: [RFC PATCH] drivers/dax: Allow to include DEV_DAX_PMEM as builtin
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 10:42 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> This move the dependency to DEV_DAX_PMEM_COMPAT such that only
> if DEV_DAX_PMEM is built as module we can allow the compat support.
>
> This allows to test the new code easily in a emulation setup where we
> often build things without module support.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  drivers/dax/Kconfig | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/dax/Kconfig b/drivers/dax/Kconfig
> index 5ef624fe3934..e582e088b48c 100644
> --- a/drivers/dax/Kconfig
> +++ b/drivers/dax/Kconfig
> @@ -23,7 +23,6 @@ config DEV_DAX
>  config DEV_DAX_PMEM
>         tristate "PMEM DAX: direct access to persistent memory"
>         depends on LIBNVDIMM && NVDIMM_DAX && DEV_DAX
> -       depends on m # until we can kill DEV_DAX_PMEM_COMPAT
>         default DEV_DAX
>         help
>           Support raw access to persistent memory.  Note that this
> @@ -50,7 +49,7 @@ config DEV_DAX_KMEM
>
>  config DEV_DAX_PMEM_COMPAT
>         tristate "PMEM DAX: support the deprecated /sys/class/dax interface"
> -       depends on DEV_DAX_PMEM
> +       depends on DEV_DAX_PMEM=m

Looks ok, just also a needs a "depends on m" here, because
DEV_DAX_PMEM_COMPAT=y is an invalid config.

