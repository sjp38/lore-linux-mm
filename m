Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DF0BC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:44:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CE3420717
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:44:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="a+FlUpPM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CE3420717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C77356B0007; Tue,  6 Aug 2019 13:44:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C28396B0008; Tue,  6 Aug 2019 13:44:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEFDF6B000A; Tue,  6 Aug 2019 13:44:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC116B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 13:44:39 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d11so76458271qkb.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 10:44:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2I3grgZ/J9vjahvSqFuu/xLlITG6j2k/vYLpAp6Amls=;
        b=VkSY5CPgAK6lzINTxkOyxFwk1DsIRIVKMX717lUfioxvu2ToaPnxAuaT3l2oDq4Xs+
         n8dpZWQ+YXBYPN6iw5LagG3qH1sqDGRGlfsUxFQcYI3IkM6tMi2+H8MTSx1C8u+H1bbo
         k2QfP6AhEmaEnDmLdqujDzxViOsTTma++BpG0FPI6alIeqiovgw0Mp7s2i2/Lnjl5qD3
         RsbrhoYxOGes9NvPSI9HG9MrSE30LTV5Ehbuo6hH3YQOqYt2E4R//8X3ED27XGd+/320
         pRbHPB4m90z8T5tXrTXcPSDSnVocxVdXA2nhwZ+7Hb2Npw+lF8+sLI+9W0yrVMT/pQuH
         Q3xA==
X-Gm-Message-State: APjAAAXQ/1qTniU3MijcU9etL26D/8vcea1o1p03U2var5jEYoH3aoiw
	oIfDbJ+rVfK44SB1b8zPC+/E0BCx/dI0lytcrFKlrKHOQ7eV94/d98JO/B1rWkUaCvZcTJ/xxzz
	6gyVYU5Y1lOG6nbIq1lCfkvIPB3kC5KhPxRGjLJQ9PvfQVWMxU2XGkLSYnkVDxeTJmA==
X-Received: by 2002:aed:3ea1:: with SMTP id n30mr4205487qtf.342.1565113479296;
        Tue, 06 Aug 2019 10:44:39 -0700 (PDT)
X-Received: by 2002:aed:3ea1:: with SMTP id n30mr4205447qtf.342.1565113478748;
        Tue, 06 Aug 2019 10:44:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565113478; cv=none;
        d=google.com; s=arc-20160816;
        b=roo1Z6s5YFFYLFKDOVX/BA2qDNpktIr22Z1hL52BFbm+j4bR5QL7BZTIK86OXmk2cN
         m1E0wM1PooISlqbClsvhH9b6K1PSaobL5IHFXZAMFu7RH9DUHyy5hYAR0hdt5OVFCXeY
         Z7264R0/xfTmzHMkzUDZL1mmXOor2g6w5hHhxB3UdFVqJo35M1Lqhe6SUh4fmjmqx5lz
         xBG26hG5+2eFuqiqOh2fw+G1EocVfeYCJGSgLRCC7nfTrumzRs3Nj4flmOQtQNT6J+YP
         JIemLH2rV25aR0djvTJKovpSZOnNmCjFPEvNO/FXZFBEHA4KVfxram/fCn3kg/oeai+8
         VHag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2I3grgZ/J9vjahvSqFuu/xLlITG6j2k/vYLpAp6Amls=;
        b=pzq7eBbrmbi9CsELn+cYIqKBCLP+PfTheLteyr7DdidtBTMQCDjFuQyZ6IcHuM54cr
         iCh+z4xXjNx4/p9xmO9w5P8qRENj8W4b5WVvvOuiszHc6YfZBSSERqV84SAk78fHbrok
         fFtgboOXz0Gt2mQ7YZNXAShb+zAWooLu+Obul0e1cm/HLe1Epf7rPbhLr8W7lB8uqYdW
         mfDvkcqYnykW3EPcUq3RdCZer9SjmWLQShU+dJGsfxuCIvcgUhUaUHgr6vLzC/PYXfhY
         e0L924mLX4vJMda0EIMiEkduie/3jLAoJHcdgeilspmwtsARj7AwysOuIFzO3siYXMrx
         FReg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=a+FlUpPM;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z68sor50537604qkb.143.2019.08.06.10.44.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 10:44:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=a+FlUpPM;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2I3grgZ/J9vjahvSqFuu/xLlITG6j2k/vYLpAp6Amls=;
        b=a+FlUpPMj54ngc2/wzpnUtdmboVj9jOXSHKH/KtrlsaDDTF+4/b1FPDz2QFwEeg1rz
         toYHqJ4grC/Zrmy66au/tF6Xp/GKKcRCxOW4nEVINsOTZE+UABenhA41pYRrtsHlIMvp
         Nn3XoKBGu7pNa90wuuXeU6vI4KIN35sIQDY2+B49rW0uXGXipKd2iMbP0zvgC1X9Q5AA
         ElTW3gUtiOMCLtIVvCF4ky6LpJZ0pbBAQDWXAaM8GADHJRXL3Q/ScIQSuBrcNYhW/MZ4
         lFfb7gJrmnotB3O3ZucXNGj9Aoegb9k7du/Rw1dzmNZgaivujgybGTKauFX4u4s2pKkF
         9f0w==
X-Google-Smtp-Source: APXvYqymlpp4BycD0qGnpnv+d7FFVmLpdZkWfIi+lh2JiL6V9IwlA24sYISFadK7zx21lftJy/jhgQ==
X-Received: by 2002:a37:4a8a:: with SMTP id x132mr4450025qka.42.1565113478452;
        Tue, 06 Aug 2019 10:44:38 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 2sm45957746qtz.73.2019.08.06.10.44.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 10:44:37 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv3Vl-0008VN-Do; Tue, 06 Aug 2019 14:44:37 -0300
Date: Tue, 6 Aug 2019 14:44:37 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 15/15] amdgpu: remove CONFIG_DRM_AMDGPU_USERPTR
Message-ID: <20190806174437.GK11627@ziepe.ca>
References: <20190806160554.14046-1-hch@lst.de>
 <20190806160554.14046-16-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806160554.14046-16-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 07:05:53PM +0300, Christoph Hellwig wrote:
> The option is just used to select HMM mirror support and has a very
> confusing help text.  Just pull in the HMM mirror code by default
> instead.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/gpu/drm/Kconfig                 |  2 ++
>  drivers/gpu/drm/amd/amdgpu/Kconfig      | 10 ----------
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c |  6 ------
>  drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.h | 12 ------------
>  4 files changed, 2 insertions(+), 28 deletions(-)

Felix, was this an effort to avoid the arch restriction on hmm or
something? Also can't see why this was like this.

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

