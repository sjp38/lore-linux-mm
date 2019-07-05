Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64E68C4649B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 12:33:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0761421850
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 12:33:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="ckYufb+J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0761421850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9ACB36B0006; Fri,  5 Jul 2019 08:33:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95DAA8E0003; Fri,  5 Jul 2019 08:33:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84D618E0001; Fri,  5 Jul 2019 08:33:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3BA6B0006
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 08:33:39 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n190so9355104qkd.5
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 05:33:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=SM8/4exhoEHGZvFQb+ptk62AOWI2rKv8kDwMIolo8dI=;
        b=BuL+EwmEDQZgWsYfUrmRUYiHsFg4TcHMvAnDf7h1tT7TdPl9GGD03kgrmNsKkXrZUk
         TXVZIaDlJMm584lwyjS7MioBDUxptStc/yUyaSmzl4bnwdmdTStEBEvf0K77nVo+G98P
         hBxR9HJy3eamakYIBy6KPx4R/gDs/eU/176fjUiFU9JVqNy9vwbIqXlrPdb/v3kMrpHt
         WL1vfYp2/Icve2zm1Nxvlt/hyBFhTbUgcFMKjrxoLCiS8w19JQexCIv5GGg8o7mmerQ/
         X6NmACD8xKL5YxF9BVrIlOdrNs79pK0W3r9aEH/rCkSqffaRYOR42gIByUVU7adb6Prm
         nwLg==
X-Gm-Message-State: APjAAAXEr58TSFjUROgdWzcXxENmGlt9HjyMF29WsGnQ8+goIgMxmxjr
	xmbQxo6ClAZb1++wvy07Vd+YmVPl+8pcUhRlsHzhn1hewEriQTRxFk6/tl+gGwoVkutS4d0XNjm
	ha3jUT4RoohvQb1jQtjSjq5ywkAj+Ymd3i6uDkY2Jlx+uqZI0EDAiHMmLkEjfHIxLBw==
X-Received: by 2002:a0c:bd18:: with SMTP id m24mr3089795qvg.118.1562330019062;
        Fri, 05 Jul 2019 05:33:39 -0700 (PDT)
X-Received: by 2002:a0c:bd18:: with SMTP id m24mr3089754qvg.118.1562330018580;
        Fri, 05 Jul 2019 05:33:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562330018; cv=none;
        d=google.com; s=arc-20160816;
        b=vNwfM9gKYRqqxQYcpPQpI5bTvsknwoBk3YdaDY2wAytEs9w0l/HPHxeH0o2qCxEwhm
         7BFNn0MprNQOPM3vbd1W/6u7Kme1S+gd1wGDlGmP8c4cyTQ9pctClmay0iuAKaQj7Shs
         ev5KUpH+fRXT/tdjRekgf5jPw2/u7sgGZNNP2wW05Jrp05PKx6ampHFcx2hXiTC9IP65
         m6AdxrHYvI63ODAcLz8SuML/JW8rEbySNBVgSJmMIJ3IuWX6Lv4YdumPdWBu4lCbyXMo
         dW9dGkTxaCtOkMIBl5RNhxmaXjBbC2KhX+Orc/+KPzyXIGhqTyqYP6rwB6g5YiYDxIvh
         Wq+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=SM8/4exhoEHGZvFQb+ptk62AOWI2rKv8kDwMIolo8dI=;
        b=O2mWhJVtLlR/omf6OjULc/ums1/Z78zAEomJepzMB3jabK8E02EcPihP5FoFyTSMuH
         OhOWE/SgjlRq/elreOd8RzzeZSF/dldVR8joG8pkG/xM0ewrtzFdd2I4YWkSC1eg8vud
         dylDuWHRKbTBpdFP4ASxNANKIboSJQNoHQvIB5WseuC0B4jGO3A66/uZzMcXGNXXZaIJ
         UKHln/q7GSVVUvaBOT2lUaUR7V/sw77idCNRshzv6MDHaoJK0L+su7Zd5I11nNxkQkb0
         B+0E/XUbgXccxrmrZ0VdBQPpyExpuMwQo39bBwMumR52oeuVj9EQUCeonvISzOG4N7ox
         DWnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ckYufb+J;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m143sor741177qke.174.2019.07.05.05.33.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 05:33:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=ckYufb+J;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=SM8/4exhoEHGZvFQb+ptk62AOWI2rKv8kDwMIolo8dI=;
        b=ckYufb+JTejpyz8pDQLhV2fiq+FAfmAMJXOQOHzRQuW89WYkHU4Lnaf8DM+LDzsQly
         7DR9KgHXKyZJ5SQnARXpB7b0GDPR+IzumhAhjFElKZoaWbVQqBzOGuOt2mXTD7nzuXt5
         rht4Mpc03KaerdCaAGd9Zz+VR1Rrl9rREPc+1J7nPBLLCwdHhPvxkD51oec3BWxH/q5A
         8y8smn0+FXxH8Gikf6Oak6WiJwqqFwAOKVh2vW+4toDJIiGZgqAhD4f+Uc2n5IztDsqL
         u3oZpE+TduYcqojeNfFd5skXHK2hBtPlP72gQxG0RENMyEEMZ5xl0dJFmnFf9EpIr4ix
         WIHQ==
X-Google-Smtp-Source: APXvYqyX4DTV+YYFhT5OJ/l0wgbSemi0wOkZLMZP/Jtfy+M9HG6Dx7KgQV0v8jgq8UDEfu8Mwq0uQg==
X-Received: by 2002:a37:a1d6:: with SMTP id k205mr2848006qke.171.1562330018204;
        Fri, 05 Jul 2019 05:33:38 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id z33sm2504614qtc.56.2019.07.05.05.33.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 05 Jul 2019 05:33:37 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hjNPE-0008UP-St; Fri, 05 Jul 2019 09:33:36 -0300
Date: Fri, 5 Jul 2019 09:33:36 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: hmm_range_fault related fixes and legacy API removal v2
Message-ID: <20190705123336.GA31543@ziepe.ca>
References: <20190703220214.28319-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190703220214.28319-1-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 03:02:08PM -0700, Christoph Hellwig wrote:
> Hi Jérôme, Ben and Jason,
> 
> below is a series against the hmm tree which fixes up the mmap_sem
> locking in nouveau and while at it also removes leftover legacy HMM APIs
> only used by nouveau.

As much as I like this series, it won't make it to this merge window,
sorry.

Let's revisit it in a few weeks at rc1.

Regards,
Jason

