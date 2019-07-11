Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 879C4C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:19:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C29C216B7
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:19:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="ZwUfn6Mp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C29C216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D52888E00E4; Thu, 11 Jul 2019 11:19:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDC2B8E00DB; Thu, 11 Jul 2019 11:19:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B558B8E00E4; Thu, 11 Jul 2019 11:19:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 777D88E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 11:19:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g21so3617893pfb.13
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 08:19:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4NNjEdQe9cxW5bppWPwas5ieRSfuuQXac2KsTN5EblY=;
        b=EvtKt30BX5+xsB9CTGmn5RZN6O3BT/MkieyJmZ9xOWxGi27Cy6zfgl1rCjsnvYRBAj
         eUdqEO7BncxcvyTc2ORBrLf1z63wHwflyVzQ+OQm/GY+h87rTydKFdz6JZSn+d+GHTZ5
         fR6+dAJnjI1Q3NL1oCcWERFee1uVpGCyHLd4mtb8w5WFWr9lyw2ioTKse+jIZK8Y4pBf
         kAOn34uFkicAwAnLLagGJvwZILkmkf5Ukzo6QNXdS5ZFSJB45DABJI6E5peiCc8G3+m+
         Sv6CYcSXY3GpRGnzws0oR04bJ7QjaXl5minN62IrczYzbhyW43uxE/aPhAyg9vAx/RZg
         gNow==
X-Gm-Message-State: APjAAAUciYP4Q5Bjja9qq6drjJGfPN68M2fjuWFqp2SkfCRMCZxLiGTu
	8m/9Rz9xp2RSN8Ma+vIUEb6Wn2gx+B+HM6H7QgjVi+oGua/Xc9Li6nqfGJYqC2/GzyLJCR2IuxL
	nfzg/wT9CdfRXj35ZBC4HkBz8gjI+Fh34WG7sXmfyivV/BRWo+EOCheElnujAh4pJ4w==
X-Received: by 2002:a17:902:b093:: with SMTP id p19mr5078717plr.141.1562858367008;
        Thu, 11 Jul 2019 08:19:27 -0700 (PDT)
X-Received: by 2002:a17:902:b093:: with SMTP id p19mr5078663plr.141.1562858366382;
        Thu, 11 Jul 2019 08:19:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562858366; cv=none;
        d=google.com; s=arc-20160816;
        b=Gcq6Z9pWWVm6PXYhiYSxYA70GIF4WdFhZzWx+CHilLtOxkNGusySH9l0NNWcozDPNA
         uxPNXU9c/Z5n5LpjrvatSw2Q+yPcExaT/sPUJcZR8+IuAkCtX5DVva/H2c5pZ/IL2Tma
         hne0twgt4YxttS+vTO5hmIG8Va+IFqYTLKOGIUJKONjKqr7UE8Xcji627fFBmuRb8lU5
         r8Z+BzmoWkesT3AF8QoaaBOj4/UWFTa57C4WX8GmfjDmRJV0ztvv/RnUBS6UIcIWKDX3
         xclRNepkXMbwK5+uSA89XU7U2FolFv2Y4tNBRC/nKYcpRtLqR9yTMnJhWLKROYkFJxxC
         0g8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=4NNjEdQe9cxW5bppWPwas5ieRSfuuQXac2KsTN5EblY=;
        b=DfxyequfiROK1aTO9PR5cnmuZblgNT+3DxJ9QuCNBiO3WZXC6Hbv7Qx/Jp8N48mef9
         xJQjo+XNm71iYmutqtnCieR899MaStx5zWg/dITx3alorKUwivGKFHzFHHaT5BiBvBHl
         0bkGIYDm+2MHbDheOo96/zpjcWagA8sOpMFXWzmFmyt2P55P1iKO/VEajgRAi91W4uLE
         kOBEg3pdGUmmUrdAE7Z3IwHWHBj5TTCHxhcBSwhJSjtgEvDL2hMhjP1WFRcEnVwjoiZw
         9PhKHLrqJifC97tPacbc7bk5cjiDwBGmgaTiwQmXajU6LJaAQxzEf1r0HN+cXRz91Mfc
         tWxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ZwUfn6Mp;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g71sor7275852pje.16.2019.07.11.08.19.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 08:19:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ZwUfn6Mp;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=4NNjEdQe9cxW5bppWPwas5ieRSfuuQXac2KsTN5EblY=;
        b=ZwUfn6MpOoPuiXZ7Iv5VsPD35P89EVD3e2s+zgajfkOErc5Tq2Rjjq/HrPzLFWqK8R
         Phx7XTBpPzXXO1lskS2QNPePTFTcB+TM2k4yaB/vdpQ8O1X1M6Vw4vXpV259bAkg6HOL
         8r7cHYN14eUoZFiRGIiugpyRJlVioFmioP60moWuA2z9ec6rJ5hAde1R9CY13eNgkQro
         dX4CWtM7i973tdSlXI6r4J2ChqxwTVQtVWNznyOt9UmAwurtrANt9fchQBzUipm/8oaw
         AMGV5fRrgpYKgWUwE0z8TCnIINJxH2HZrP3mPZaKfpJbPrIN/7qoJfrGaFq2DdfxpLcK
         +OsA==
X-Google-Smtp-Source: APXvYqw//XMf5iO/xqX9WkfLr6lxxusAG6t8rN1YMwfDJ1zuUDvdcOWoceJMctPu93NrMqY+9AsMEg==
X-Received: by 2002:a17:90a:28e4:: with SMTP id f91mr5274113pjd.99.1562858363368;
        Thu, 11 Jul 2019 08:19:23 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:91c7])
        by smtp.gmail.com with ESMTPSA id g1sm14863114pgg.27.2019.07.11.08.19.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 08:19:22 -0700 (PDT)
Date: Thu, 11 Jul 2019 11:19:20 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/memcontrol: keep local VM counters in sync with
 the hierarchical ones
Message-ID: <20190711151920.GA20341@cmpxchg.org>
References: <1562851979-10610-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562851979-10610-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 09:32:59AM -0400, Yafang Shao wrote:
> After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
> the local VM counters is not in sync with the hierarchical ones.
> 
> Bellow is one example in a leaf memcg on my server (with 8 CPUs),
> 	inactive_file 3567570944
> 	total_inactive_file 3568029696
> We can find that the deviation is very great, that is because the 'val' in
> __mod_memcg_state() is in pages while the effective value in
> memcg_stat_show() is in bytes.
> So the maximum of this deviation between local VM stats and total VM
> stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
> great value.
> 
> We should keep the local VM stats in sync with the total stats.
> In order to keep this behavior the same across counters, this patch updates
> __mod_lruvec_state() and __count_memcg_events() as well.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Yafang Shao <shaoyafang@didiglobal.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

