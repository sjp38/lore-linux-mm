Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F4A7C41514
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 18:42:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12328206BF
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 18:42:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Tg3wAqzK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12328206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B70616B000C; Tue, 27 Aug 2019 14:41:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B20E96B000D; Tue, 27 Aug 2019 14:41:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0F566B000E; Tue, 27 Aug 2019 14:41:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0194.hostedemail.com [216.40.44.194])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB806B000C
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 14:41:59 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 23C6F83E3
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 18:41:59 +0000 (UTC)
X-FDA: 75869077158.22.floor21_2e621cbae5515
X-HE-Tag: floor21_2e621cbae5515
X-Filterd-Recvd-Size: 4015
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 18:41:58 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id z4so71780qtc.3
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 11:41:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9ceAN/Yoez35TeAjbDhFK5DksMbw1eL2zoww/c7DDSE=;
        b=Tg3wAqzKDb2Nvtp5xnTJu8Zd7Xoskps6KbP7KGSG2mXkHL1YpVlpacJxibryLDlNJw
         179cDfjV75KnOnbO786z8kq561zwavu/nufenfX6VMltb+S29UuroexvGBTlW43jXQmu
         BnfnPJVVYk2s3RHioNaSV2iGEh7jX3UBGoPb1YLczXEMrlSdBRwoauSdVh1dnk3odz81
         5DTC0TRiSs3uSv6gH+zLxmF3Fs8g9ISCjSxPwwihfMHKeWeF5bYqA+q9TtOOx2nNKZ8P
         Zp8VHkM7RZiKWOrFRQbrnX0L3PbEWZuZHj7c02SuCN1iqneJHz/alYfeQVVF1tfTWxVj
         JRYw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=9ceAN/Yoez35TeAjbDhFK5DksMbw1eL2zoww/c7DDSE=;
        b=HEFnKNatAZ9Imn8KxqVdZU6Wva03LSqOWE+6E8KagIvoK0WOaNhTia2JLkmfxECYa1
         0dx6OM+xb/7M+rJJejt3rh0ZPhOel9oQ6hVr0oEJyXDsOMYaBsoBFGLD2H/u1WmGKuaj
         GUTn/xPxyYbzAcRDL1FkVpDRC0fvfVBEkSzRY5e1xqVsj25+ewN+sjkQW1nqkbt9Z7d2
         Tdbln8b8YllHNWvfXfhBpcIiTb0fRYSz9PO0aooxV1y7s1Y/osdUsa5h8zufcmF7fE/x
         qAANumVxFrUHIg7kpwUk8IRLSeOqY9yEw4cdNgSvYDPmSniCyFEmb56jX3nZgFGW6EzX
         q7Tw==
X-Gm-Message-State: APjAAAUBYCbqI71Ct6r3qAPO+VwRzM1GS5195MO1xlLtvJ+uOC3fnq59
	t5wBlM89jXS0wXoicWZ46T8CfA==
X-Google-Smtp-Source: APXvYqxGsIEH37K7EHHZpDcbxKJ2Zt/WeLY+aot3NzZQz1/QF/DaeFShLNUpqkv0bACqFBQq4QCy2g==
X-Received: by 2002:ac8:23cf:: with SMTP id r15mr242835qtr.97.1566931317969;
        Tue, 27 Aug 2019 11:41:57 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-142-167-216-168.dhcp-dynamic.fibreop.ns.bellaliant.net. [142.167.216.168])
        by smtp.gmail.com with ESMTPSA id x28sm9926373qtk.8.2019.08.27.11.41.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Aug 2019 11:41:57 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i2gPl-0006d2-1c; Tue, 27 Aug 2019 15:41:57 -0300
Date: Tue, 27 Aug 2019 15:41:57 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] mm/hmm: hmm_range_fault() infinite loop
Message-ID: <20190827184157.GA24929@ziepe.ca>
References: <20190823221753.2514-1-rcampbell@nvidia.com>
 <20190823221753.2514-3-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190823221753.2514-3-rcampbell@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 03:17:53PM -0700, Ralph Campbell wrote:

> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>  mm/hmm.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 29371485fe94..4882b83aeccb 100644
> +++ b/mm/hmm.c
> @@ -292,6 +292,9 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
>  	hmm_vma_walk->last = addr;
>  	i = (addr - range->start) >> PAGE_SHIFT;
>  
> +	if (write_fault && walk->vma && !(walk->vma->vm_flags & VM_WRITE))
> +		return -EPERM;

Can walk->vma be NULL here? hmm_vma_do_fault() touches it
unconditionally.

Jason

