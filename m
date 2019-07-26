Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5D36C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:25:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B878422C97
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:25:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B878422C97
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5045B6B0008; Fri, 26 Jul 2019 02:25:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48DBC6B000A; Fri, 26 Jul 2019 02:25:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3558B8E0002; Fri, 26 Jul 2019 02:25:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id F12356B0008
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:25:07 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id f189so12054474wme.5
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 23:25:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zzAy5zR2ZbuMPo5RerjjaTbk/daLanNgHQk6wxMz1Fw=;
        b=HDc1leUvm8qJjQZvYKvbyiWFy6cJkLBYwmPUgljfozUBL/JW2wEI8G3wldyrSrLqEn
         H79Tzp04xHLzXQ7SOVi5fOIBrHo9n55rde8sYrhNMSmITtctJ2gOhuWNRyamOx50FlnW
         sEQetRLTvx89qQ6Be2Xc1O80ojt23EdcyzICQyiTrkVgeQduxT76pUNHKqxwagc5ByC+
         mTJU3TouTOUMPiTrk892xeoAbN7lDatsDA7KfHVeeAy1ijjsUxo7GBa9lcimgJ42qG3H
         ZCfg8iZHXkWXVrwmmAsQF4+8zK+USDO+UTXkU3e6mE5f84H/sD/J0+EqHnkdOLN4U7hg
         nNww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXHmQUA0Ty6lJJeZI7aylznejEQpq1hFmFFO/o04RWKOd5sjFsu
	T+uiJcQUyjJibQdDfNM/7XW5Knp63HtVhCqvZ1NKXLAaToWHsBbAoWIwZ3/xbbw8KiGipKFLBi2
	qiTi0EHDY0jCO88zDG5kZPVVq0vNQn8br0ixvn1pkEOXk1Kw5Uej/pK6JNbUgv0xRVQ==
X-Received: by 2002:a1c:1a4c:: with SMTP id a73mr21909330wma.109.1564122307566;
        Thu, 25 Jul 2019 23:25:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQr41GWjsWIV2L4cyN4Nk/+1JE76j8s71EI1ZvqFu3fwP/jnmRxYa/wjz7Q2PRyL1R61H/
X-Received: by 2002:a1c:1a4c:: with SMTP id a73mr21909272wma.109.1564122306682;
        Thu, 25 Jul 2019 23:25:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564122306; cv=none;
        d=google.com; s=arc-20160816;
        b=Ug+H4lFY6McS76TBB+80spguK1JuIjXUzG2tiqi9opENaqlfLaoHVos9OCskLJujRo
         p8r4tHJjP3XFo2XgTME8A4/PqmYLoPuvCFqCaRKbnP4d/VH7U4wzas9ItW5Hs07EEtlJ
         09VgLNT/fnwUAEpDeliRpgzZWnzRCBCOiPZg6RQ6yqWIr5kVaRGR2+xEi405AM99Axo2
         W1ItAfFBaGxp+H3XB9ZnRR5rCY/cmv/6HPHJQbttJcyXz6IbrdEDX+JUm1yfVVrBtS8V
         npeIMa4AeexK+Ahll46lVZWxCXNUl0i35MlpTSSNXda7t7vfe8xq6mwjAM8arnviVvjX
         oq5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zzAy5zR2ZbuMPo5RerjjaTbk/daLanNgHQk6wxMz1Fw=;
        b=a8WrepqqZEb6kkSvdQrZG3nUotm5M51oTOCs+9TsaFFD9fG3kWxvXXMiDzTkgHjyJD
         2G7kao699DuD8sSFqXlPK4oqvNgmY4yZOt76oHUfvoOVkP2zR/o5M8rx5/jKJwwPzEDr
         mEY2ZQWvuCIdihqHm3CYpxVv/ln8wVCqT/3IL5FCZHqHAYqh4tGaCZ28VFb6FddX2XZZ
         /k/rkzCgpC3npkJIkoQNgmoqDwEavbbjMdOIFqu4NB8Os6YfFZAm7BusgKT4nWwET0TI
         zm0giC3QudsCxzKpnOUNwa6+tLJ0glEjkAPKDvXRMslv7bg86+3lheRETalsQYNj+kuQ
         GG4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q7si48967433wru.62.2019.07.25.23.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 23:25:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id A2F9468B02; Fri, 26 Jul 2019 08:25:04 +0200 (CEST)
Date: Fri, 26 Jul 2019 08:25:04 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org, Jason Gunthorpe <jgg@mellanox.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 7/7] mm/hmm: remove hmm_range vma
Message-ID: <20190726062504.GD22881@lst.de>
References: <20190726005650.2566-1-rcampbell@nvidia.com> <20190726005650.2566-8-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726005650.2566-8-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 05:56:50PM -0700, Ralph Campbell wrote:
> Since hmm_range_fault() doesn't use the struct hmm_range vma field,
> remove it.
> 
> Suggested-by: Jason Gunthorpe <jgg@mellanox.com>
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

