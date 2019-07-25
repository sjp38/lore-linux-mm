Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A928AC41517
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:18:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64D862238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:18:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RiPttf3V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64D862238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15BCB8E0066; Thu, 25 Jul 2019 07:18:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10E2A8E0059; Thu, 25 Jul 2019 07:18:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F16218E0066; Thu, 25 Jul 2019 07:18:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA6868E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:18:44 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e25so30687084pfn.5
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:18:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1FbnKtI3LwQwgUsr/g3MUa9Py+KRgg38b6IrILFDUhU=;
        b=OfEWSAdEVAS7I6UQu37f9CI9nIQ+CA4EZCHTMLRaCLua+Y8QobxI+/2F4K57y90tJc
         FghiuEndl+J8NKZPpnG7lMP/Pat0Ne83SMo4h86qOoYlFvQ8G42SFvYOGmXMySzSK3Oz
         KwRs0b1bB6FNKxZQfpAupfTWUxvUvLVNU9qvrpfKzaKeENcgmNprLdMHu5N0enB+1gP+
         /U3m+6nzSWYpHjJS34IIp+8Wzj7kk5mN53MsPYCiWV8nr4igOSBJm5HK0BAzF7rsEhO2
         kWfdQixhaVqWPPJZqfLHwzoXfR7OPH5y+dK/yuI0KtLfszteePMmtPrGDnJKJAYRoEfb
         XRsA==
X-Gm-Message-State: APjAAAUqhTvGy9WCUP76V2Pqa6debwGXvVatrSR4Rvvy/NT3OoXIOl5z
	m5fJTq9JFq5XqRjjg44fsZ+yahNsmFsADoKHQoVUemnNA2ri3c9wnOmuejB84vrRLeLxD186HIH
	ADMjrq9jl50uPaoY9XK0Soo2crp7twYzIdyG4PuRMzI284Lih6T1wKxTiI8zEiFm1nA==
X-Received: by 2002:a17:902:59c3:: with SMTP id d3mr87893703plj.22.1564053524385;
        Thu, 25 Jul 2019 04:18:44 -0700 (PDT)
X-Received: by 2002:a17:902:59c3:: with SMTP id d3mr87893654plj.22.1564053523656;
        Thu, 25 Jul 2019 04:18:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564053523; cv=none;
        d=google.com; s=arc-20160816;
        b=woQZkB8jE4zyQzxG8r74J78FxOwglACYrZszcf1vPi5t3xi1wYXOZCh4nhN6TdofTQ
         RfvdIAcqahzgCAkAR2olmQkRHvG9csj+mO+x1vOcqZPatgfaeClGAojKIBrgn2+DXDQ0
         4saZy5iq9qmS1iU+7p2ephfmCnZWTT2kro6G+acBfTRkgyoEZU/uyH7xbIHqf4gLBBho
         YbzYU/s0deJ1f60oqI1ymqZMdhPye4tFXyz61NyVPOWzlDXZ5usbmmkAKL1FX0GW4oCo
         b7UbixoOsshkoWvhMxF1vPBmghQh4puZ+xvlAq4TtHDvVVHOxI9o1DsBK4HrmdKxcY8u
         NOTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=1FbnKtI3LwQwgUsr/g3MUa9Py+KRgg38b6IrILFDUhU=;
        b=vUgcX1rQtTDIpbLnX3AhO6l3q4EjMGCDXpdFq5CGKaYMuSK0MvQRS+Gkiz7k80NRKv
         VaTdVfIuZa+/N0oCsIlw7zyeysNv1fPMazakN7LR+ysVZCBWwXDqRhN7KVEGbX2YVErF
         6s6e4gPfqi/3AgIdd572KCej2zBFlM8uKbcGORPWwDy3P+KN+T4AL0NAfRJE1FqO5xRR
         TT8cLfnuostS0RwWMVTTIzqGjatfhqgId5Vpmt7AqV8tVKn9C7jB+XMEGERnN6gatUrk
         yx7cdZxp2cdpDt4BP44GTbTwXDEN74WoZ92RJLxLAkU7wMn+gkxowjKyuryOV+dEPUPu
         yuEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RiPttf3V;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g15sor29272300pgg.19.2019.07.25.04.18.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 04:18:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RiPttf3V;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=1FbnKtI3LwQwgUsr/g3MUa9Py+KRgg38b6IrILFDUhU=;
        b=RiPttf3VULytvTV1gQCGGIofaH3cmMvvcLlShfvYsVeKFzWjG/kfl/UguNaNy7/Dfo
         FVmH2PIQAE2iC69ldXu5sNi9yS2z2PuKCOKbuswCunkNuJwrNoEzBk2cOmbgVNaQZsql
         vWiZsd67ciYl95JIzgVUAExNBHZtC8mivPnxWK78M7nMNjVgpYOHWMOxtXNNo0v9cqC2
         r/T/+iTbpnJX5k7uurmQUrJ54neQWBfYxzH6kvGeSJ+H2ILyhbfMSTjrInxG6dRzsZPQ
         t9CzL6qva/lkcI8XGhVlO+HAbtcciB4SanHFtxVMYgiTsIzVps4/IUCTGBW581LK8m7v
         GkAg==
X-Google-Smtp-Source: APXvYqwWrdl5FJRCm09CQlypUGpElLXPTtXQhNRGvN4DIQ3ybEer3KGwJh1GSg+qHIHbIRJ+x3Bfug==
X-Received: by 2002:a63:121b:: with SMTP id h27mr70608971pgl.335.1564053523202;
        Thu, 25 Jul 2019 04:18:43 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id s15sm48874992pfd.183.2019.07.25.04.18.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 04:18:42 -0700 (PDT)
Date: Thu, 25 Jul 2019 16:48:35 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: ira.weiny@intel.com, jglisse@redhat.com, Matt.Sickler@daktronics.com,
	jhubbard@nvidia.com, devel@driverdev.osuosl.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] staging: kpc2000: Convert put_page to put_user_page*()
Message-ID: <20190725111834.GA12517@bharath12345-Inspiron-5559>
References: <20190720173214.GA4250@bharath12345-Inspiron-5559>
 <20190725074634.GB15090@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190725074634.GB15090@kroah.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 09:46:34AM +0200, Greg KH wrote:
> On Sat, Jul 20, 2019 at 11:02:14PM +0530, Bharath Vedartham wrote:
> > For pages that were retained via get_user_pages*(), release those pages
> > via the new put_user_page*() routines, instead of via put_page().
> > 
> > This is part a tree-wide conversion, as described in commit fc1d8e7cca2d ("mm: introduce put_user_page*(), placeholder versions").
> 
> Please line-wrap this line.
> 
> > 
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Cc: Matt Sickler <Matt.Sickler@daktronics.com>
> > Cc: devel@driverdev.osuosl.org
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> > Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> > ---
> > Changes since v1
> >        - Improved changelog by John's suggestion.
> >        - Moved logic to dirty pages below sg_dma_unmap
> >        and removed PageReserved check.
> > Changes since v2
> >        - Added back PageResevered check as suggested by John Hubbard.
> > Changes since v3
> >        - Changed the commit log as suggested by John.
> >        - Added John's Reviewed-By tag
> > 
> > ---
> >  drivers/staging/kpc2000/kpc_dma/fileops.c | 17 ++++++-----------
> >  1 file changed, 6 insertions(+), 11 deletions(-)
> > 
> > diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
> > index 6166587..75ad263 100644
> > --- a/drivers/staging/kpc2000/kpc_dma/fileops.c
> > +++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
> > @@ -198,9 +198,7 @@ int  kpc_dma_transfer(struct dev_private_data *priv, struct kiocb *kcb, unsigned
> >  	sg_free_table(&acd->sgt);
> >   err_dma_map_sg:
> >   err_alloc_sg_table:
> > -	for (i = 0 ; i < acd->page_count ; i++){
> > -		put_page(acd->user_pages[i]);
> > -	}
> > +	put_user_pages(acd->user_pages, acd->page_count);
> >   err_get_user_pages:
> >  	kfree(acd->user_pages);
> >   err_alloc_userpages:
> > @@ -221,16 +219,13 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
> >  	
> >  	dev_dbg(&acd->ldev->pldev->dev, "transfer_complete_cb(acd = [%p])\n", acd);
> >  	
> > -	for (i = 0 ; i < acd->page_count ; i++){
> > -		if (!PageReserved(acd->user_pages[i])){
> > -			set_page_dirty(acd->user_pages[i]);
> > -		}
> > -	}
> > -	
> >  	dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
> >  	
> > -	for (i = 0 ; i < acd->page_count ; i++){
> > -		put_page(acd->user_pages[i]);
> > +	for (i = 0; i < acd->page_count; i++) {
> > +		if (!PageReserved(acd->user_pages[i]))
> > +			put_user_pages_dirty(&acd->user_pages[i], 1);
> > +		else
> > +			put_user_page(acd->user_pages[i]);
> >  	}
> >  	
> >  	sg_free_table(&acd->sgt);
> > -- 
> > 2.7.4
> 
> This patch can not be applied at all :(
> 
> Can you redo it against the latest staging-next branch and resend?
> 
> thanks,
Yup. Will do that!
> greg k-h

