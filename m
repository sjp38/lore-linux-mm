Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D035C46460
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:24:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F44420866
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:24:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n9Gy2M+O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F44420866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A52486B0005; Wed,  1 May 2019 15:24:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A054D6B0006; Wed,  1 May 2019 15:24:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A5206B0007; Wed,  1 May 2019 15:24:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 50DC66B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 15:24:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h14so11395858pgn.23
        for <linux-mm@kvack.org>; Wed, 01 May 2019 12:24:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=hF6fNKlhWYgrPc17wR/AXCapWmsiWzeqUovI/sNlDvo=;
        b=snaScEgw7ZCuEJn5KYCPxl34E1mUUSHnmxTpPaUigpI6vGtOlcCu0zEz4JfL7wAHR9
         GEQTHgVYpSSXbDUU8s27ezJNiBBbhOll41HwwU3wPYFUb/MaM4yhjQevbMslwv7TKCV5
         Qz1/L8QtIPYauXfwgx9yUue3/OwQm2sf6YQPomcMAREDG5ccYWXwy5oB6TDm13G3XiJu
         4bkPKabWyTMMVlyC+f406qQrdB67uiBSuFCf/2muy69FlI9SiDvBiQVw9Z9SWxwqOCvI
         a3BaKxzmKF4nKBHGVVkKkDT5n3HcpM1mykipYgScGoTgkrhA8J3D35OYtJtdS/suCOeq
         rhEQ==
X-Gm-Message-State: APjAAAUy9cUdMSRD4UrhBhQ80V2tRz/95YUqDHylAGAg129uiZQQUY2j
	cn7uO6okJ0uVSF2B2jQgr7/RM/cU0mvw3U/6FCll2M1u6hte2x+xJJHC0h5L+XmBBRofb7XlBWR
	GNPTktcRCEmiGEJWYZkQG+BbGyvOdLYAu25dD/uAaOSnaP/YCAgKuz4JMCwOnNjY=
X-Received: by 2002:a63:cc0b:: with SMTP id x11mr73615155pgf.35.1556738641924;
        Wed, 01 May 2019 12:24:01 -0700 (PDT)
X-Received: by 2002:a63:cc0b:: with SMTP id x11mr73615101pgf.35.1556738641114;
        Wed, 01 May 2019 12:24:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556738641; cv=none;
        d=google.com; s=arc-20160816;
        b=Se5rlFm3AkiJUIoq69etO7gAPwxJg76Ik+lQjUyHd0nUxg4yKQ43AQrNrcVL8hiGpq
         5gb0N8POL1DNGNsTJJy9ivWEZmB9NqdoJOURu4Oq+6vQ6ftTMhcqsAb6dckF/j8b5VwX
         oNx9e+ekirfLhPUt0Xj7jkcwCee7Oiecrgt1bhxom1n5oclr8uUbiVNGK1Igu4g5w/Yz
         hS2JV6H0uZMSq0emXCCzHGtf9cOwkmhMAeNVZjzxONz8ThGD6nGYodZsuG+cL7AdA1Qi
         gyBF0u0DSWmAC0C6Zg80foF8BqrMiczgzBw5nvGWS19tbcpcztdLHH5Us9w/BaQRWeBE
         B3zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=hF6fNKlhWYgrPc17wR/AXCapWmsiWzeqUovI/sNlDvo=;
        b=IFXr5ZgynR12Bgek0kAta8ygtEKZh/ue7iLLMg9RnYHVaEQNJt/4SPjPWdirpXQoYS
         4ZuG+colThNLTAZPFJr+e8a5ALFKLOCXbVwgmYNhFPwrGEE0WfJW/ZY6w+OEV5Gin4IM
         Ryz58MhfJcs+sjDLWXgT5z/2KWDS7FBVYkPLq2+m+TYgzgsD6qaTmuQ2NwLy3Yd5+1dS
         LwsIg6ur8sF6LFtnSH9uS2tjhYJ5mI5yF84kamIXgZlVfd8aOcgUIWDncaXKbuxXMRZ8
         GpmwQbm9ZNxD+cmTydNRH/Yd1M6Q0vOWpm9e9dHsvDvY7N8fNqXw0OCVvrlbrm0WUYU2
         GJ/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=n9Gy2M+O;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f23sor5370019plr.4.2019.05.01.12.24.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 12:24:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=n9Gy2M+O;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=hF6fNKlhWYgrPc17wR/AXCapWmsiWzeqUovI/sNlDvo=;
        b=n9Gy2M+OdEVC80XuMGmxjU81J0AVS7+2rco21taXmSACRKNhQOtBYnVj3rDyTp7kJo
         5GRfqvrawVTfvndMWCdx2aZZNd/oNI2eRj7kjmz5hVAG69lDsm0JU+qpoD0vE4uwi3eK
         zATG8dhRIkDgWpB7SnV0F/4msBzekFhGZw1e3TwDeZkwWfXZWZ/MT76z+2vFCgbCj4JR
         SotP1RtK7esW2k3SkOZyzIVjVoasV+BDepMHV9bZXyUoYjiwL94ZaeNgHJ4bOiD/885y
         bSbJXtEQwB2oUz/TL3IVh1D2PiTChIm4LFeHSKCD4ftXt9CXsp5ZXIsCfj9LVe8e1xXX
         kRgQ==
X-Google-Smtp-Source: APXvYqy1jVE0MyKKlrK0SoUTj5YOCa0gPHBNRhCLy07Q9zFHM+JQiWrmKSvfoL1ZHuzvAAJmqHo4VA==
X-Received: by 2002:a17:902:1c7:: with SMTP id b65mr9398715plb.2.1556738640687;
        Wed, 01 May 2019 12:24:00 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id q80sm75239448pfa.66.2019.05.01.12.23.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 12:23:59 -0700 (PDT)
Date: Wed, 1 May 2019 12:23:58 -0700
From: Guenter Roeck <linux@roeck-us.net>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
	Leon Romanovsky <leonro@mellanox.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH] mm/hmm: add ARCH_HAS_HMM_MIRROR ARCH_HAS_HMM_DEVICE
 Kconfig
Message-ID: <20190501192358.GA21829@roeck-us.net>
References: <20190417211141.17580-1-jglisse@redhat.com>
 <20190501183850.GA4018@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190501183850.GA4018@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 02:38:51PM -0400, Jerome Glisse wrote:
> Andrew just the patch that would be nice to get in 5.2 so i can fix
> device driver Kconfig before doing the real update to mm HMM Kconfig
> 
> On Wed, Apr 17, 2019 at 05:11:41PM -0400, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > This patch just add 2 new Kconfig that are _not use_ by anyone. I check
> > that various make ARCH=somearch allmodconfig do work and do not complain.
> > This new Kconfig need to be added first so that device driver that do
> > depend on HMM can be updated.
> > 
> > Once drivers are updated then i can update the HMM Kconfig to depends
> > on this new Kconfig in a followup patch.
> > 

I am probably missing something, but why not submit the entire series together ?
That might explain why XARRAY_MULTI is enabled below, and what the series is
about. Additional comments below.

> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Guenter Roeck <linux@roeck-us.net>
> > Cc: Leon Romanovsky <leonro@mellanox.com>
> > Cc: Jason Gunthorpe <jgg@mellanox.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > ---
> >  mm/Kconfig | 16 ++++++++++++++++
> >  1 file changed, 16 insertions(+)
> > 
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 25c71eb8a7db..daadc9131087 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -676,6 +676,22 @@ config ZONE_DEVICE
> >  
> >  	  If FS_DAX is enabled, then say Y.
> >  
> > +config ARCH_HAS_HMM_MIRROR
> > +	bool
> > +	default y
> > +	depends on (X86_64 || PPC64)
> > +	depends on MMU && 64BIT
> > +
> > +config ARCH_HAS_HMM_DEVICE
> > +	bool
> > +	default y
> > +	depends on (X86_64 || PPC64)
> > +	depends on MEMORY_HOTPLUG
> > +	depends on MEMORY_HOTREMOVE
> > +	depends on SPARSEMEM_VMEMMAP
> > +	depends on ARCH_HAS_ZONE_DEVICE

This is almost identical to ARCH_HAS_HMM except ARCH_HAS_HMM
depends on ZONE_DEVICE and MMU && 64BIT. ARCH_HAS_HMM_MIRROR
and ARCH_HAS_HMM_DEVICE together almost match ARCH_HAS_HMM,
except for the ARCH_HAS_ZONE_DEVICE vs. ZONE_DEVICE dependency.
And ZONE_DEVICE selects XARRAY_MULTI, meaning there is really
substantial overlap.

Not really my concern, but personally I'd like to see some
reasoning why the additional options are needed .. thus the
question above, why not submit the series together ?

Thanks,
Guenter

> > +	select XARRAY_MULTI
> > +
> >  config ARCH_HAS_HMM
> >  	bool
> >  	default y
> > -- 
> > 2.20.1
> > 

