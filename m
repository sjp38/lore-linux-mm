Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D017C32750
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 22:34:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7D4C206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 22:34:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bujwWf5J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7D4C206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C0738E0003; Tue, 30 Jul 2019 18:34:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 797A88E0001; Tue, 30 Jul 2019 18:34:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AE8C8E0003; Tue, 30 Jul 2019 18:34:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0323F8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 18:34:14 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id w27so6832442lfk.22
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 15:34:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=W9OGjlOiuGBttY9lHWx9LPxLd92PhSuHcIdfhpDpvoE=;
        b=GXo6AzO3zwMrk46vRbR8UJ6uDGcMEkpnW5no+HW2HgZpPyWY4sAlvKPiOH7d09jFeY
         3ItbhMftdVzfAxx4XD5tk4F7VZO2tMU5qerS5m3sJsMWELbV9icajv+3KDV48x3G9pcG
         cdivQJOp1vGCFbKYnNnUU9He8HIYvT7jeJs1V/bGPOj2th/7L0uB9aUZet7iX3XHw7dC
         e2c84ly39T15j8/SRhuBfnLI7WMLP3fdMPJEkEkIkMVGhR+vKuj7n06WxKone8HgEXAm
         V9L5venxaLo5YpZznqfCKe7AsWq7+aeFxseC6odpcdzeGw/KrBo3dZKrBqx8gxnPxFHc
         kOUQ==
X-Gm-Message-State: APjAAAUH5Z8+9H/6cXOnu46r82Bxt5D2QyQ57yPsGrHvdZAyHUdVUusE
	cvPG6mV3cLgCGgiidbJ6TJMmsgHuJFd1EmkNRC5lw7061CAQgGWy/HUbyh7ngWeWrVii6kPQPgg
	UxNou9pArAhaUxBIcDZwR5JJ3AkndNGGUQxp3173NcG5SHakpiMu3Mjj4Q2cKA+niEg==
X-Received: by 2002:a2e:9997:: with SMTP id w23mr10267177lji.45.1564526053180;
        Tue, 30 Jul 2019 15:34:13 -0700 (PDT)
X-Received: by 2002:a2e:9997:: with SMTP id w23mr10267156lji.45.1564526052350;
        Tue, 30 Jul 2019 15:34:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564526052; cv=none;
        d=google.com; s=arc-20160816;
        b=cKsuVWW1ug/jsGTM9x22JwmUbrI7xjRtqD4HX2joLF0765s/XNoXPQcwESYuO9d1/3
         /F+eudNFmI7N+/ZHwODDUgby9EvJZ3FOgPQhhdgFkF8ePEUadrpzzEGh6jYWgHhaXy8x
         00+209XX+HsoP3fGjAYCtWYkIT13jBWDhwcntnex4hJMifjjCg2cRWTEYKtyJX1RSX1W
         7IiT+jarYbz47l0cM+paLSh2LS5/Dzzchn05h1IRpEhvXs54HgV/KHDN1x4v3JHp/yvR
         UtPwyZK8N5MikjvJBRUoWGAhsptqPf6BOokbEhqCofXMCfxmlhvq2JksI5Yp3DFCByTZ
         SLFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=W9OGjlOiuGBttY9lHWx9LPxLd92PhSuHcIdfhpDpvoE=;
        b=fjyIruVtzWl0EymniPirP8KW2Z8dABAR++l9W/dJuQXW00EnUI9vKhu9vfIdrZt90n
         Gu3LMgxUgZGwSBngicu6+AVGeuDMYEfrRJB3NreTCfyJytTK/27jQJMdw1Kt1RUn0Nnn
         JvhBvRB+JUFOp/2r7DjY8k0Eau9gfAYfSby2QSw12MXCJ+yicjkS6VCgLo1aCLnBIcb1
         bFWk4Ot/Li8jEqO3sawaUsPmN0XRxCFzpOyylUBYMjtl4TlRgi47Sfuv+BuJGQ3gcBP7
         ZDuJxn+z+EvYSgCJJ6vnGoZOApcQ0M2r+Tk42ln0fKki5dSTYEUKDWJfx5/lRLbu9Kam
         7zyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bujwWf5J;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m78sor17457116lfa.53.2019.07.30.15.34.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 15:34:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bujwWf5J;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=W9OGjlOiuGBttY9lHWx9LPxLd92PhSuHcIdfhpDpvoE=;
        b=bujwWf5JLRuD+uv5Vrf6d7xtiko4y6kxVh+VdzTzfqqt+SpAWjyUJCBjcOb2/0YUhT
         mtAWzoMhWMY5VROhMuCppQSSfaS05+Tl5kLPPrrWb4TrtPSMiGS8mLATh0hjQFkTYBPL
         IjyMsioCx8axzjOVtU00KN38V+wSg+lHhEbWgHiqSn/OwYRZSY+PieKWShFOOmps33ie
         cWMNRxIzZ7FX+rqRhqtIP7gIy4/YLO8q1jIyJvVAWoD4aosRFdFHuia/fAIx4NEibCFU
         rF8A9HhEKJkPTx0fQb9KudSvs8iSSyxmfEkqBMtVzYg4HhSqUTNHwwHUmoetDzxi7o3R
         vEOw==
X-Google-Smtp-Source: APXvYqylT1lor/fMtz/TfmJWdVozDsoadnNBs90hKZzNMn/xJ08p79neC6t1NdK546O9Gk3EmXgArA==
X-Received: by 2002:a19:f711:: with SMTP id z17mr55960460lfe.4.1564526051873;
        Tue, 30 Jul 2019 15:34:11 -0700 (PDT)
Received: from pc636 ([37.212.215.48])
        by smtp.gmail.com with ESMTPSA id v4sm13656948lji.103.2019.07.30.15.34.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Jul 2019 15:34:10 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Wed, 31 Jul 2019 00:34:00 +0200
To: sathyanarayanan kuppuswamy <sathyanarayanan.kuppuswamy@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Uladzislau Rezki <urezki@gmail.com>, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v1 1/1] mm/vmalloc.c: Fix percpu free VM area search
 criteria
Message-ID: <20190730223400.hzsyjrxng2s5gk4u@pc636>
References: <20190729232139.91131-1-sathyanarayanan.kuppuswamy@linux.intel.com>
 <20190730204643.tsxgc3n4adb63rlc@pc636>
 <d121eb22-01fd-c549-a6e8-9459c54d7ead@intel.com>
 <9fdd44c2-a10e-23f0-a71c-bf8f3e6fc384@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9fdd44c2-a10e-23f0-a71c-bf8f3e6fc384@linux.intel.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Sathyanarayanan.

> 
> I agree with Dave. I don't think this issue is related to NUMA. The problem
> here is about the logic we use to find appropriate vm_area that satisfies
> the offset and size requirements of pcpu memory allocator.
> 
> In my test case, I can reproduce this issue if we make request with offset
> (ffff000000) and size (600000).
> 
Just to clarify, does it mean that on your setup you have only one area with the
600000 size and 0xffff000000 offset?

Thank you.

--
Vlad Rezki

