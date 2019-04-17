Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01790C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:33:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFEBC20835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:33:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GBB0oY7n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFEBC20835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F8CF6B000D; Wed, 17 Apr 2019 15:33:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AA176B000E; Wed, 17 Apr 2019 15:33:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BFA36B0010; Wed, 17 Apr 2019 15:33:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02DF76B000D
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:33:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d15so15227654pgt.14
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:33:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=HdZ2rAJcnY1L+PlHybMWMLk6Tu+139i4qxa9kcwwLRY=;
        b=EuJ3UQz0iKstvSRCZYd/q27h05AWZq8aqro4hGGww+E43lhaV3gcaKo+kMKrNKZRTJ
         MBvAa53vVExGTCSLIFNTYFS8XmlaTyNxTOaWj9Zp65qYghNqx7jtsrKZeI5OI2UCQk7p
         TRrPtLq27M7f1II5IvrifAnQWTd8IqeNJ2t3G5qiYBThqluchtK+fVSeLxt2yPnVAMhT
         oA/0ALd1DfkeIIZvkWNNUbTSBEmP+9TSRLyXQul7ECNxlZbGRako3hzKV9sRu5pyIRbB
         lZddMYG5RgZ0V+0Co6hCZheNOGJZ2sDPM/AEyYXvHOxrK4qSkvQbHZdChonu4fr+v9fJ
         OM3w==
X-Gm-Message-State: APjAAAU5SRcthvVLlQrNYYYDVP2KIAF/YkjNzwwHPMIaCpgrGS9BJdTY
	hEp227rADj/ViE84/PG5dal0yj9KyXB2EhMCCg5yFpGevSvlH7klfwCCfh1eaXmUoeLfPUeF6Hn
	DZuCLmpP/AQfTQB8qC2PzEkI0wsD7wP7itCZHoCIEuf3RARN8DgOiqLcEgvESh0Y=
X-Received: by 2002:a63:4101:: with SMTP id o1mr80746611pga.17.1555529619651;
        Wed, 17 Apr 2019 12:33:39 -0700 (PDT)
X-Received: by 2002:a63:4101:: with SMTP id o1mr80746535pga.17.1555529618657;
        Wed, 17 Apr 2019 12:33:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555529618; cv=none;
        d=google.com; s=arc-20160816;
        b=LafeAgyX8o7k2brS9dL8s7Y3i6dO2mcxHTPRkDL+o2rHdS+yyqpIGQG8D/tYxoWJ2w
         MZRSZKBsPx8uew9aqu0zIYQEUaVcgBd5BfkIiLvk6P0j4vzHKvMBDVSbfbkpVJYTod3t
         TQ9oEkgkRKCMDwczLp4wuiZ3KLPV7p/iu/mJ6ps4TVY6tqTvFrzR1/5mucjz3CvrXpgq
         8AWFOLFe1G1u8nlyvZvt1lRdsblsgDQqGM/TffomSY5c9qE8eKyCF49ZQ1J5++OM63Ul
         /YGCRLUt3SDg/wlFH6FwIOffw2xE0MFDohng9eqfJdo+DkyJfDFZX5BsbmXUDwrzmimr
         M0hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=HdZ2rAJcnY1L+PlHybMWMLk6Tu+139i4qxa9kcwwLRY=;
        b=jPA16lC+OKlrg9Bmj4zmO4fOZUanlWfb9+vFzGg0jwHTuY2GXg7rFu28p4Tem58g+m
         N6tqmUQn2n8/mjEx1QnRLG4zN3X5xqIO83AxZUH+VmoGJw0wupfSxssiIUol3n/oZf79
         ZFR/tpcBx2PptXvAzuEDT2aREw5r9TzaJTkjw1I7Tri3truYtXPqUwXUayAkJptTZAPt
         oZlWNJ4m13sy9qD/kAp82CJa5MxmbFoCjF5C1y6Y1iDaGtV4YWzfZjcEj5Hz85TcJCdK
         oSNaR774liE2v5tlrsesLVxqjgPTbFjFL3y5dJDMHjLIEeHW5lqdp1b7okuA7IDP7hEC
         R4sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GBB0oY7n;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v24sor40235499pfa.57.2019.04.17.12.33.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 12:33:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GBB0oY7n;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=HdZ2rAJcnY1L+PlHybMWMLk6Tu+139i4qxa9kcwwLRY=;
        b=GBB0oY7nLKBYICxo+e0cpdrV4hT8uP8TCpOLeNXdQ4SvQ3yraeyc6WhyWjJ1izWZuX
         CTBbOs9qYyPkxWR3pbXjWsE8oMNQLC/uJLilAmJCgWrALbr7hMF7ptMu1RNQ2WSbHbmu
         bwx+KbLgzVSCsc+KHE13mkCJDTCx1Asok/lfIQz1gh4yUVSv1yF1rODoAcSfVRnk9BXt
         5Vg8isxL+9wo2dbf4Nmhoc7GvkBbym2hl28B9Pcp2kDo6+vrpV/OLuWHw/jcydbm51Nf
         e7yJFT+zeazbAMQxnAmcL1WmRStMPA8atTaUo/QtfJc49Dx6PLSMjzIbX7biu0rQNHgi
         d4wg==
X-Google-Smtp-Source: APXvYqzndDzcZGVaxF0yxPMOkxfFZ4l16pNP7oSkOxU266QICB04Q5V78QIYK7O8LFL1bWgTSYyjvQ==
X-Received: by 2002:a62:2687:: with SMTP id m129mr90117426pfm.204.1555529618322;
        Wed, 17 Apr 2019 12:33:38 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id k9sm75859983pga.22.2019.04.17.12.33.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 12:33:37 -0700 (PDT)
Date: Wed, 17 Apr 2019 12:33:35 -0700
From: Guenter Roeck <linux@roeck-us.net>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Leon Romanovsky <leonro@mellanox.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH] mm/hmm: kconfig split HMM address space mirroring from
 device memory
Message-ID: <20190417193335.GA23825@roeck-us.net>
References: <20190411180326.18958-1-jglisse@redhat.com>
 <20190417182118.GA1477@roeck-us.net>
 <20190417182618.GA11499@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190417182618.GA11499@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 02:26:18PM -0400, Jerome Glisse wrote:
> On Wed, Apr 17, 2019 at 11:21:18AM -0700, Guenter Roeck wrote:
> > On Thu, Apr 11, 2019 at 02:03:26PM -0400, jglisse@redhat.com wrote:
> > > From: Jérôme Glisse <jglisse@redhat.com>
> > > 
> > > To allow building device driver that only care about address space
> > > mirroring (like RDMA ODP) on platform that do not have all the pre-
> > > requisite for HMM device memory (like ZONE_DEVICE on ARM) split the
> > > HMM_MIRROR option dependency from the HMM_DEVICE dependency.
> > > 
> > > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > > Cc: Leon Romanovsky <leonro@mellanox.com>
> > > Cc: Jason Gunthorpe <jgg@mellanox.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > Tested-by: Leon Romanovsky <leonro@mellanox.com>
> > 
> > In case it hasn't been reported already:
> > 
> > mm/hmm.c: In function 'hmm_vma_handle_pmd':
> > mm/hmm.c:537:8: error: implicit declaration of function 'pmd_pfn'; did you mean 'pte_pfn'?
> 
> No it is pmd_pfn
> 
FWIW, this is a compiler message.

> > 
> > and similar errors when building alpha:allmodconfig (and maybe others).
> 
> Does HMM_MIRROR get enabled in your config ? It should not
> does adding depends on (X86_64 || PPC64) to ARCH_HAS_HMM
> fix it ? I should just add that there for arch i do build.
> 

The eror is seen with is alpha:allmodconfig. "make ARCH=alpha allmodconfig".
It does set CONFIG_ARCH_HAS_HMM=y.

This patch has additional problems. For arm64:allmodconfig
and many others, when running "make ARCH=arm64 allmodconfig":

WARNING: unmet direct dependencies detected for DEVICE_PRIVATE
  Depends on [n]: ARCH_HAS_HMM_DEVICE [=n] && ZONE_DEVICE [=n]
  Selected by [m]:
  - DRM_NOUVEAU_SVM [=y] && HAS_IOMEM [=y] && ARCH_HAS_HMM [=y] && DRM_NOUVEAU [=m] && STAGING [=y]

WARNING: unmet direct dependencies detected for DEVICE_PRIVATE
  Depends on [n]: ARCH_HAS_HMM_DEVICE [=n] && ZONE_DEVICE [=n]
  Selected by [m]:
  - DRM_NOUVEAU_SVM [=y] && HAS_IOMEM [=y] && ARCH_HAS_HMM [=y] && DRM_NOUVEAU [=m] && STAGING [=y]

WARNING: unmet direct dependencies detected for DEVICE_PRIVATE
  Depends on [n]: ARCH_HAS_HMM_DEVICE [=n] && ZONE_DEVICE [=n]
  Selected by [m]:
  - DRM_NOUVEAU_SVM [=y] && HAS_IOMEM [=y] && ARCH_HAS_HMM [=y] && DRM_NOUVEAU [=m] && STAGING [=y]

This in turn results in:

arch64-linux-ld: mm/memory.o: in function `do_swap_page':
memory.c:(.text+0x798c): undefined reference to `device_private_entry_fault'

not only on arm64, but on other architectures as well.

All those problems are gone after reverting this patch.

Guenter

