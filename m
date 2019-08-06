Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21507C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:00:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCFBC20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:00:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="BTdL1q7u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCFBC20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6784B6B000A; Tue,  6 Aug 2019 14:00:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 600C86B000C; Tue,  6 Aug 2019 14:00:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47A9A6B000D; Tue,  6 Aug 2019 14:00:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24F3D6B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 14:00:29 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x11so75115944qto.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 11:00:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bxAi2AWxQLWDF2luvIMl7f/UII4L9fAd8kmJBO8r+QM=;
        b=C1zn1HsT8vVqQ0t6KqZ1/Ejss9dftHK6ImvGHjo4pVfR/KXHVSaZZkI3qz7JRGyINZ
         LF89Z/4L6TmlUPoPs0q4tiDMneRfDAHxnuI1qnMxqr0n37i85RK//9oZpx4Z84KH1ayv
         G/pgd4wd8UE7fOnN9nuYo1QTQCraInRHmSYi097eLSR0F5Sc9uz7mN5mF7QqslyqTzFp
         WEoN+Grh0KLyNbMBUHxpviYPjJTeWsDg4VHWMTy3x/0oGoUBngKYk8WLN38QBcpFaVsx
         Yo6ShOqDDDgtom6Hx3zValXOL2dL8VZyeMu6eMCvD020+bC8A+OzCO8aiFLfJV1WhNMj
         gpFg==
X-Gm-Message-State: APjAAAUe1XWVfL0lelYdMHTEp5wFuYGw2HUSDSMpkODi7+I8W8qZ9lZw
	Ws5Y3AQrO8JUpsyIuk7Ke8ozUfJtO1m8wPApGi2n49vbRMqJckhZXN+STVV146cPRrMGLNXGgyL
	20+85EUdexzYRqJbk64zxP1Fdhs1gfZBbwQV9o7Wi9ewXAso86670VICYGrlDHk3vFg==
X-Received: by 2002:aed:3944:: with SMTP id l62mr4350948qte.34.1565114428940;
        Tue, 06 Aug 2019 11:00:28 -0700 (PDT)
X-Received: by 2002:aed:3944:: with SMTP id l62mr4350906qte.34.1565114428520;
        Tue, 06 Aug 2019 11:00:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565114428; cv=none;
        d=google.com; s=arc-20160816;
        b=bH7sUn8qzdA9Ac/8VseDTBk2H6MqghoY2LRWlumqeDWd+QJ7y8b+kYQIQsie+DW2en
         GYhK1kRnoFhmFmIBpcvAIlKPFi89+8UphxqaIFPqZbCH62SKtWxZ6Tbe9bXbOPde3SUp
         kk0bgS06yBHBDsk1tt4WmAAGR7Tc2EoV3kNmABWKmqoCs7GgnV5cHYsWjNYo+h7g3tot
         Z3kWs19CVBSTkxrOoNoqwc5zI+3vytkwS9f0j36B0HiHXVyRhlM23sLzrAsTdpgROCSW
         mskEDfNQzwbeyHelGa+KU3sN7PvcB4w1n+RTClIxfEtQJuV+gJCLPz7usm+bNduI6w7H
         ylhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bxAi2AWxQLWDF2luvIMl7f/UII4L9fAd8kmJBO8r+QM=;
        b=MHh563orWe2isbRwq98FvtxecyKIjO5ekpsiC2zAipItwOI9l2NywwiqaDoM3+JDde
         UibelrLkgeZqq2YITRtDXWaPQw/j/+VY1ouWCrpu2Sm2bpXSS+YLSPtBPnv+l8RyO1fP
         159E4i59POgx2PiohiJENp0GoM16rSFSSSIge6nEYm9iJLFV1tmbS2NJrh2BssqEGp1O
         SRoJ7Neg44iRX7kF/UbELwNemBip1X1dhVazLqntJmhDNfTq9p8DgP2xJaKQdnLEc6cW
         BQ5vod72kP843LbQA3BKODkkbR2fgzI1APv90Zm3gitLIS+DIyR4CRDIPZ44zwDA8+49
         1ubg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=BTdL1q7u;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3sor74196017qvc.37.2019.08.06.11.00.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 11:00:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=BTdL1q7u;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bxAi2AWxQLWDF2luvIMl7f/UII4L9fAd8kmJBO8r+QM=;
        b=BTdL1q7uIftWEibqtpJ2qBvmgEl0z+WwHsvtywklotBDG0PpIzsdOkQu2MzqaTeVMo
         J8yB+abqQuKUfiuWe/VFhxZeK+LmVGsRDJrUW0pAsCMH6f998wxdNClpsRBWqGB3q9lb
         DIpOye+uQcyUXo3ondmYhnMZVp8o4EzhV4Jc5CR26nszzO7s8uyzHULN5JfFJg0w74zH
         z8baH6w71w2QWD+OqIA5XxvbMLZRSmwRHv4BH8MQpHSlnp9Rj+9dezQk76GZ8Y6Ui0Zs
         IOpf4eY2syFgOUh+A2Lc1gcx6oZthg+JUv4GWxh92CjWmzVf23Jl3OmhSvoxCjauSNqR
         3A3w==
X-Google-Smtp-Source: APXvYqwCmY0NZ93DbaUKqBGemthRcu66UNlk2zMQT2HujC+QqBl8bAE/pDy0q9npLsbnQ5I+0N19GQ==
X-Received: by 2002:a0c:c107:: with SMTP id f7mr4227804qvh.150.1565114428225;
        Tue, 06 Aug 2019 11:00:28 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id o12sm36309954qkg.99.2019.08.06.11.00.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 11:00:27 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv3l5-0000Eu-8Q; Tue, 06 Aug 2019 15:00:27 -0300
Date: Tue, 6 Aug 2019 15:00:27 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 11/15] mm: cleanup the hmm_vma_handle_pmd stub
Message-ID: <20190806180027.GM11627@ziepe.ca>
References: <20190806160554.14046-1-hch@lst.de>
 <20190806160554.14046-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806160554.14046-12-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 07:05:49PM +0300, Christoph Hellwig wrote:
> Stub out the whole function when CONFIG_TRANSPARENT_HUGEPAGE is not set
> to make the function easier to read.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  mm/hmm.c | 18 ++++++++----------
>  1 file changed, 8 insertions(+), 10 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

