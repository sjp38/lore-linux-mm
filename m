Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FE04C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 17:47:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B600121901
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 17:47:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C5w+mGxc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B600121901
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 209816B0003; Mon, 22 Jul 2019 13:47:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BA326B0005; Mon, 22 Jul 2019 13:47:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A9948E0001; Mon, 22 Jul 2019 13:47:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C38816B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 13:47:33 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i33so20256558pld.15
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 10:47:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ssliLyV8U+mhRbl4ipf9bRa3EL22Ezd5Zc9rGXszSvs=;
        b=mk0kGLEqNGlNYiICVXEqnG65+YNq+53KiJNauFZaN4EB9fp2yW/aZkFR9VuMGhDlBL
         3Nr6H+cUbPhga55p+hQOC5D6qzLBNtNQAYWX0KKAqmN2oRZrOcCEIZvdOALeoz9Hmqe2
         oAO1WPdwDsIDUK+kRbG1oFAttx/LzCUJs9b7gD4ETFDUFBwpDxst/iADjH6dQT5itAEG
         XoLFzexN8H7D4hiK8ArbzoRQg/DNTSf91fd/2MXq1nWVG7biKOSvpYwWxrXw6bgam1eQ
         SpEEGdIaUDSpsDuO+/TUn4xf0+M36BUmdcn8hrczXo3qiu/OZy9a2L0tbP13blfMfvY6
         1vEg==
X-Gm-Message-State: APjAAAW/vIHCJop7KG5oYgq1tlQL8rwN3Vbf9w+8MJvONpGHQcHJOxjJ
	oisvOQiFYd28kkhs6xEHt8/xWie4FSENaC5EqtXyapEUf0rSgOgz8xK6yBsxU4h2SL5GdcELYg0
	TO/0b3K0vXYTKX0crF/KuuPNIOBe0nubgUNBvkXmW03sGdg9TuQbyo4X2vQ2EpuA75w==
X-Received: by 2002:a62:e515:: with SMTP id n21mr1420731pff.186.1563817653381;
        Mon, 22 Jul 2019 10:47:33 -0700 (PDT)
X-Received: by 2002:a62:e515:: with SMTP id n21mr1420679pff.186.1563817652628;
        Mon, 22 Jul 2019 10:47:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563817652; cv=none;
        d=google.com; s=arc-20160816;
        b=doM7b+WhWVXa8NLwoV7gSphFYXNGwF4ki9gg3WLg0eRtDLny4aCdUGsLy5899LF8rg
         3feRn7Q1jEjb5Mrv5S+aoK7QF5MzjNLL5q8J031V805HeW7s19cNHep1Lu4AnxDVG/nh
         5oZTyOfu7vi/TvlN6VFes7NvQqWgHpcT4KGeCW66QgaOhq64xD3odhVE18MDN6sqJMOu
         /pv+mF/WD1MVPiumF/bp/kQUdj60yaoTLaEG3nTcsVcJAzO5uHV/5e1e+ZwJ6rT5RmpB
         N1KdRfG+IlF3mL1oyj5zQqhLIfVoC3elZpugD4ZN6YPxMCKHJXeOgkO3Yqhhf5YCFsch
         eWIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=ssliLyV8U+mhRbl4ipf9bRa3EL22Ezd5Zc9rGXszSvs=;
        b=tHC/9XbNPSxgsVcuIZ1BkeOeae1VPSn+OaEGAfS5+4flgIuUQHs7zipLyMQ507PMb4
         0yYFYdo7CkHSVAyEGqoPGJd82h22Fd4EPsmZMB37MyVs0UOY5JWYYoUIpBOzJCU0VKGW
         Vas6ig56L2Fx2Z/Z8AAZCqHLFIDrIATstiTgTOlTmnq9NDl1e+vWby31h3f7NLMR5Tbc
         l+yrlCaZ7BnwyA6blywwRD3J+EGrmVMQdEDuHrSx8202tOuSsT8QzdOefuIQB8ZuUAcO
         mpcA2gtBaZ6sgs0aDDNj/OU0ZhYzr90a8H4lv/e8m2I0BcBdAEJAvUNdLuQvGT+hSCwH
         WiDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=C5w+mGxc;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a4sor1007819pfn.24.2019.07.22.10.47.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 10:47:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=C5w+mGxc;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=ssliLyV8U+mhRbl4ipf9bRa3EL22Ezd5Zc9rGXszSvs=;
        b=C5w+mGxcCfYenODdQNw1QcoLPL+bTkqpAf1/84e6VjiF/EoUBRTpVAR+fNjCytOAWp
         odi5USyMM1CmgRscWbz7evmXa7roPGotsByCf0dCTZYoBvFSPOM8gPIGhpelZJSVH4kB
         hmL7ht19DHj9QHK7nirEINAtPWdthi1fyy909XKPUyZ0sF2ocOcpxFB7WTDRSZe0K810
         cFeY4feogogD3qQW80cDHyCXQa084E3fdKJZBNveSLtwkmItkyXKczLr82vjNBMn8GOC
         D8FspNPt0fikrMjAzRzXpw3qh+0sRFbGrB73QY18Lv1wx61yQFRX5ooBCKklMPAlbkQs
         BRdg==
X-Google-Smtp-Source: APXvYqytaXVkl+pZJk2sr2G9EcYG8eurkZ6Bh7OAgDsV2SsE5u3Auq7jbF2z3AZSzMtO7hgrslDQ9w==
X-Received: by 2002:a62:fc0a:: with SMTP id e10mr1400314pfh.114.1563817652196;
        Mon, 22 Jul 2019 10:47:32 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id w3sm35130886pgl.31.2019.07.22.10.47.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 10:47:31 -0700 (PDT)
Date: Mon, 22 Jul 2019 23:17:25 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: arnd@arndb.de, sivanich@sgi.com, gregkh@linuxfoundation.org,
	ira.weiny@intel.com, jglisse@redhat.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] sgi-gru: Convert put_page() to get_user_page*()
Message-ID: <20190722174725.GA12278@bharath12345-Inspiron-5559>
References: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
 <1563724685-6540-2-git-send-email-linux.bhar@gmail.com>
 <dae42533-7e71-0e41-54a2-58c459761b3e@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <dae42533-7e71-0e41-54a2-58c459761b3e@nvidia.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 07:25:31PM -0700, John Hubbard wrote:
> On 7/21/19 8:58 AM, Bharath Vedartham wrote:
> > For pages that were retained via get_user_pages*(), release those pages
> > via the new put_user_page*() routines, instead of via put_page().
> > 
> > This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> > ("mm: introduce put_user_page*(), placeholder versions").
> > 
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Cc: Dimitri Sivanich <sivanich@sgi.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> > ---
> >  drivers/misc/sgi-gru/grufault.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> 
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Thanks! 
> thanks,
> -- 
> John Hubbard
> NVIDIA
> 
> > diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
> > index 4b713a8..61b3447 100644
> > --- a/drivers/misc/sgi-gru/grufault.c
> > +++ b/drivers/misc/sgi-gru/grufault.c
> > @@ -188,7 +188,7 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
> >  	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
> >  		return -EFAULT;
> >  	*paddr = page_to_phys(page);
> > -	put_page(page);
> > +	put_user_page(page);
> >  	return 0;
> >  }
> >  
> > 

