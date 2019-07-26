Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 963D6C41517
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 04:57:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B1292238C
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 04:57:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B1292238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B877A6B0003; Fri, 26 Jul 2019 00:57:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B12486B0005; Fri, 26 Jul 2019 00:57:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D8BD8E0002; Fri, 26 Jul 2019 00:57:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 65B7C6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 00:57:05 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id e8so24925883wrw.15
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 21:57:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=f4crsVR0QXfPCV0KhrJ+q7jN/cwBO9Oso0Pxb7RozjU=;
        b=IRQRea48e/Gp/dVZOistn8Y0Fht3KOtp7WE//+5B9yionmipGe5sHiewH1jeQ9T2ue
         aI8frgCltrcp5rmeyoBOPLa2iGwBrLGud/rU2jl4KrZzDIdSSoMMPyIuZRlsY0mLr2Az
         s8TNQ2ynuEA2t9c8KI++00MLCB7LRmICaXUMUOyaL49Wl2ZDx7Dwxk3GtF5shsrR9qFl
         bpym3BMFv8GQMfGj21kwDTG9rk9dgpqteMEAicBi12TMipmyu2uEHHIkMinjpH4+qLoJ
         Bd+HoseSWUmFfY36Pmf5hhs9pjTwXMkzUuSzPddZao83O8hDKOJRHyMHm2P/2AGLasyQ
         apAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXWMWRicRKyXVo2Y8hk+D2OmWB4zfJjxWbY/ziuQYtKFx/cfyE4
	NwNzFpTra6mZuov2DPqVDwFR3t+xN0QjCtWtsoVLPSbf5hBN/quZMakaadFMINIUeENLJOkX6fX
	/G+a2mrENpaCfP02KcctUg+Ws7+TFgIChkidMA3m76FYzuADZfhK/ui+s5W5qN4XgEg==
X-Received: by 2002:a7b:c933:: with SMTP id h19mr85424892wml.52.1564117024836;
        Thu, 25 Jul 2019 21:57:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymF/ZeKm5vCxGPadW5Jim7OTGYlRr92BaxV87/pjW4Hn1U0mU6m3cjxYMZlVY8xshE21xL
X-Received: by 2002:a7b:c933:: with SMTP id h19mr85424824wml.52.1564117024099;
        Thu, 25 Jul 2019 21:57:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564117024; cv=none;
        d=google.com; s=arc-20160816;
        b=W5Scoop1Dl4w7jCcZIe/v0cTjSGuvH7XcSvHV+QEg5Io4Codey+F5PvSp7D3fMzAkz
         LqeRDDcTa6mlGMsvwT6RNGIcWBdfGXvfEZRaH2k2HXONtiZCbiqZY1XV0g7BbrU36hkb
         P53JN4R8pbjcvCsijyF5QSLmQWcrYXCalaXEzoIxcVLxVLTNbY5bOSJyiCLDvDcuVy7z
         j5KkIASp2te3PURyb5F5T3Dk8EllHOdbDfLerWMY0wgG7DW+PT+OiF0l41hbQrtxzlw3
         Wk2HdQaYe02JUPAq7qPe/x0G/lFQDOABjZ7Jl+lr4ybPj3RD28lPyog13B+zhN9Tf6DN
         T3hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=f4crsVR0QXfPCV0KhrJ+q7jN/cwBO9Oso0Pxb7RozjU=;
        b=ZlxRTzr1mJEWMetRD3/JwvcHO50yfKCDq9+NvrhHNsgCnUXoe0wSPFIjVjBBoXP+hK
         NhBxw6v4BUc+Lc1jZa/AOpe+E3Wwdn1eRqSGBUBmzkuK8BL6I2fFTRFIWAE+rg0/8zt+
         1I36SEiUF41bFpzNQq3W6arYCVMPzAyOoZ3ZsJ2SwHNZKxEqPdJq+qZfy8aT1aIvoDPW
         etwJOpSQWY4kx9whbPKcCoC7G4tta1RDEDk0HagZZF3Ekkrdeqb42aVNKzhs5BNGQsYJ
         NPEqs57xzx7dBGd8gHDR0jP2jBHuzNW/P6FWu+vlcVkRK2xsBA1NB5P1FMVBIYKkF7zP
         RMWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p5si48105593wrq.214.2019.07.25.21.57.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 21:57:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id C418C227A81; Fri, 26 Jul 2019 06:57:01 +0200 (CEST)
Date: Fri, 26 Jul 2019 06:57:01 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: hmm_range_fault related fixes and legacy API removal v3
Message-ID: <20190726045701.GB21532@lst.de>
References: <20190724065258.16603-1-hch@lst.de> <20190726001622.GL7450@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726001622.GL7450@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 12:16:30AM +0000, Jason Gunthorpe wrote:
> I don't see Ralph's tested by, do you think it changed enough to
> require testing again? If so, Ralph would you be so kind?

The changes were fairly small, but I didn't feel to carry it over given
that there were changes after all.

