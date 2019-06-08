Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47967C468BC
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:49:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01D2D2146E
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:49:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="H67pCnfy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01D2D2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83CEA6B0273; Fri,  7 Jun 2019 23:49:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7ED536B0275; Fri,  7 Jun 2019 23:49:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B6376B0276; Fri,  7 Jun 2019 23:49:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 336146B0273
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 23:49:08 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q6so2509119pll.22
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 20:49:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=5iFtOAxSpyEwrNGKsnJSAuPHnmB6sZsxY7o3VcURDbs=;
        b=G6oAEfpe4LGYMzgT/dg+AzOSKOyyKNRHLNdfiFqONZpyAwASUo6+k+H1CYoOwk6Cwm
         TQQjokyTEku0opXc4eVagUQwVdAFSsHLi8d+A/GgzWwzPyJzSjECRd1Rs87voXZuIYxQ
         Q6x+gtY+OB+v7nrR+uZ2T3C1g4trJvn9TO+AcjlbZeL2f27LXVM7jaJ7TbVnH4s+KZsx
         mOZX5kdqyN8mHyQvr7iiV146MjOtNuTsUA87BhFRMQgVuU562eaYL5Js9kBv8WvDxYrQ
         eA2nz8NZ/vXKnG7+OajbN1POfIc+LCarbxtoXwJ2niAmNGGs6XaeWNsk9NaXnSIBCOzS
         GVHw==
X-Gm-Message-State: APjAAAVwHkSuO4Hw/UYlBeFYwonoMR3KWy/bnDW9qM4Bviu6021ps4pR
	u5rKuDsjntAZzDz69pl+6E4not3bvZ7qq4Iy0Kwz21qiftVGJd4GlFCjTrUuXe/DCJI2QJe3/us
	B2nLs4mo3p+zYFfsXogIEl48Y+Q5UMPeexbZ62/1xOPkfJCt5F6HtNK8qgSNhd7WemA==
X-Received: by 2002:a17:90a:7343:: with SMTP id j3mr8816785pjs.84.1559965747905;
        Fri, 07 Jun 2019 20:49:07 -0700 (PDT)
X-Received: by 2002:a17:90a:7343:: with SMTP id j3mr8816759pjs.84.1559965747250;
        Fri, 07 Jun 2019 20:49:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559965747; cv=none;
        d=google.com; s=arc-20160816;
        b=PPbDxmp117eKTtNwHTFf+o73+tBOHnwF+OgXol46UAlXWdGEZc4+HIuxNeJHFWygcW
         vje9HbsXfX3/9Rhhy1xdte0wNXHT4h+VUm0qsQrRtdpqBoSIBvCksdQOha0Cm/+n5A+F
         QjEwBDvTiny9NXzGdKu57gEzMjvPDHVyMPQIJ+L+KjFuJotEQ19GwM34RrvAWfQ0Fqyo
         watMGwns+y9WDpR9jPP02omyUZePbZmSJZ43Wn3PFoVGX1q5QQbn54XB7ntVF5VXC8IX
         O4Ub3CFa8s07p8/xAAHhsrhwylxxfMlYdJBK49wZZOrAdJ2JMIaR5vctMf72WUCGRlF7
         Ijrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=5iFtOAxSpyEwrNGKsnJSAuPHnmB6sZsxY7o3VcURDbs=;
        b=wx8Fqchq/TUeEaLkOIEOIuF6MsU15R4Btc6H10IN1UcID3o52Hxsk87A48qLsePyua
         iMBYAC+DFBD+as/DUTykpzDYzS0i3es9uUphidxpiPsW/uggCucOWBXULKRpk199zPCM
         j5wK/bLXy3xLMTvynzr/JpzR7W12nSlZ1U+Aa8xxnhiJJ+gUyZH2kuHBVsLVIoBc0oYl
         TfiZdUGuVAtGIZGsmKQCu791ICV4+NeLe3aXNHIKtBUfO+9Bcm1/H6bdXSi5UtDNW297
         8ZssVqhGNCIdWVEYMhuXCeXQwob5WMf8HKatb87m9LiCHzS61WGquL6tbSvGOAsAKhZh
         /UFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=H67pCnfy;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7sor3567421pgh.74.2019.06.07.20.49.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 20:49:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=H67pCnfy;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=5iFtOAxSpyEwrNGKsnJSAuPHnmB6sZsxY7o3VcURDbs=;
        b=H67pCnfy+inYwtx7CHiN5h4f1U/pgcnleLkOrUnW4+QdjbqfAr9cQdSkm3W08ImQFl
         MKpSL+Xxt/SE/t0ZUnbh42ewav3Rgd/mWolnnSDbYBR+Ld/cLmR9BtGJ7sEbWVa+oHPR
         1hTMHtgCUOMHLDYeeHgvIO8Lm0UyCIchcEask=
X-Google-Smtp-Source: APXvYqyjpXWbpUp/M/TNwB1KLrsvdqCimHBytjvPEw0jUB6ar1HA2nI5YlI2gocy+KHTqRtIofNEIA==
X-Received: by 2002:a63:5247:: with SMTP id s7mr5637363pgl.29.1559965746908;
        Fri, 07 Jun 2019 20:49:06 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id y12sm3218417pgi.10.2019.06.07.20.49.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 20:49:06 -0700 (PDT)
Date: Fri, 7 Jun 2019 20:49:05 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 04/16] mm: untag user pointers in do_pages_move
Message-ID: <201906072049.C71D545@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <e410843d00a4ecd7e525a7a949e605ffc6c394c4.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e410843d00a4ecd7e525a7a949e605ffc6c394c4.1559580831.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:06PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> do_pages_move() is used in the implementation of the move_pages syscall.
> 
> Untag user pointers in this function.
> 
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  mm/migrate.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f2ecc2855a12..3930bb6fa656 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1617,6 +1617,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
>  		if (get_user(node, nodes + i))
>  			goto out_flush;
>  		addr = (unsigned long)p;
> +		addr = untagged_addr(addr);
>  
>  		err = -ENODEV;
>  		if (node < 0 || node >= MAX_NUMNODES)
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

