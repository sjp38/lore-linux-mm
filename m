Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF550C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 03:04:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB1CB206A2
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 03:04:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB1CB206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 499ED6B027E; Thu,  1 Aug 2019 23:04:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44BED6B027F; Thu,  1 Aug 2019 23:04:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2ED2D6B0281; Thu,  1 Aug 2019 23:04:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id ECE886B027E
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 23:04:26 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 145so47210309pfv.18
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 20:04:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=fMGiC+gHRydmpo5zkwmfgrAx10Xxrzh90eBI7yxp1tE=;
        b=MysHNMkiekdKQFjSgT7D3LsNvftI+xl9lw32Km4herANTssBj3I0Uf8Q4A+4klSeeS
         YKXfgqLl9DWC/Cj7XabU7SwidR5VRWkhdCnhn+2R8V2GtpW7C1KugLdjl9zy7c+tPzT4
         uLu03OKPBRLkGQOajFIC9iBOwzKDMaDuZLVVchl06VqRvMelnCt2HRFvHAG7WIMz/rtu
         3ut2x1+4wJq6v1/Sc0BRE3LcjlgzgWyY/QBiaTA1GIJEd9XBkSe6gvEZLKg8JWG9oxmK
         9aHgcc50+vhGwZe6SKrEcQt1LieQxacvpjOpwPUeZkTcHLwffslXCmnOqInr3+DMACAP
         7Dtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-Gm-Message-State: APjAAAXCLdiHzPsfrsc4SW73LkhuskHMJovul5zJP1OBJSRbdXU1unrr
	SkiCg7TsKkYcMLlsv6SKpBVCT1+vl0McctGv/EFs+8Tx2Pk7eUf3tjzk81rsfiDIUxfWcwyNCRa
	EMQJTNaSoBHfIP19lrZLPQUKYV6tp8Nrf1an6vIs/ozndzAOn7FfNQ23A84l3Nzm68w==
X-Received: by 2002:a65:47c1:: with SMTP id f1mr120389161pgs.169.1564715066478;
        Thu, 01 Aug 2019 20:04:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYRMWOFqQkDkwOcdu9WMyTioWNrV8qhvgK5PJoLGKI6MhcQC6tR2y1PTWOerQ5f/6ze77J
X-Received: by 2002:a65:47c1:: with SMTP id f1mr120389085pgs.169.1564715065309;
        Thu, 01 Aug 2019 20:04:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564715065; cv=none;
        d=google.com; s=arc-20160816;
        b=bHeESmv+oz/9QcuIreVGF9KHgf3TdEu9VBYZaZhdogrZldBKVMbd1uuvLxiHSXPF7X
         9dchcb8cm8o8k1cgVgxMLvnErOXaNsMYauNJiAVRIsYEQt/WRP3/gIv0NXtuu1dgAFyB
         MCAKRxPIiFovGlocUtkmDTuju+T8SAXwHl/bHTzRdk7Ie+ufDUhKPrt2KYfM7IgVk1qZ
         V9nqcIQbJ2eSZIAlYSFC7L3uGDEfKQscU8uo7S3e6pE/MyHEbLOZphdqsN7efY8Lmt6W
         Keh6+QE8B9HeP/lnD/Ml5+hz047kns9OjdJLO6h3awgIHKXjX2KNKCZvbvA5UylGjs5w
         SkVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=fMGiC+gHRydmpo5zkwmfgrAx10Xxrzh90eBI7yxp1tE=;
        b=mNvqHFcyq1A0c/Oq8qcc0Xmid/d2Zi4hIQYkieW0ZEpvYN91qjBpE83eRcfZSBhybx
         Gaq092j0Jn/WX3F82pWDfCS1m5FC5HMHhW4Bpup8woGuC1WD3n0rEBUJ3abITkRKe5b9
         lCqdeN7I83mgVk7SV1t2Upxm1MyVPU5Tq+p9AZJY2Unkzpbb1zORTEEcxUFgq+CrR7kM
         nOZhosZs1ifQPdF7SO70LXVI7atGJ8w9j7nhdBYTUmUQoi4BYlNQyeDLG10uXGConZDB
         IXMzJCS1qJ2QXHRLUc+lFZnxYEoTLbJgDNkCsTRxiy2gnaJsf8ROaXyEzdhzd+kNqYk5
         b7Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTP id a21si35720405pgv.185.2019.08.01.20.04.24
        for <linux-mm@kvack.org>;
        Thu, 01 Aug 2019 20:04:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-UUID: c92cdbe318cf414695363abda4ef831d-20190802
X-UUID: c92cdbe318cf414695363abda4ef831d-20190802
Received: from mtkcas08.mediatek.inc [(172.21.101.126)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0707 with TLS)
	with ESMTP id 160514836; Fri, 02 Aug 2019 11:04:20 +0800
Received: from MTKCAS06.mediatek.inc (172.21.101.30) by
 mtkmbs06n2.mediatek.inc (172.21.101.130) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Fri, 2 Aug 2019 11:04:19 +0800
Received: from [172.21.84.99] (172.21.84.99) by MTKCAS06.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Fri, 2 Aug 2019 11:04:19 +0800
Message-ID: <1564715059.4231.6.camel@mtksdccf07>
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
CC: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko
	<glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
	<penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
	<iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Vasily
 Gorbik" <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>, "Jason
 A . Donenfeld" <Jason@zx2c4.com>, Miles Chen <miles.chen@mediatek.com>,
	kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, Linux ARM
	<linux-arm-kernel@lists.infradead.org>, <linux-mediatek@lists.infradead.org>,
	wsd_upstream <wsd_upstream@mediatek.com>
Date: Fri, 2 Aug 2019 11:04:19 +0800
In-Reply-To: <f29ee964-cf12-1b5d-e570-1d5baa49a580@virtuozzo.com>
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
	 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
	 <1560447999.15814.15.camel@mtksdccf07>
	 <1560479520.15814.34.camel@mtksdccf07>
	 <1560744017.15814.49.camel@mtksdccf07>
	 <CACT4Y+Y3uS59rXf92ByQuFK_G4v0H8NNnCY1tCbr4V+PaZF3ag@mail.gmail.com>
	 <1560774735.15814.54.camel@mtksdccf07>
	 <1561974995.18866.1.camel@mtksdccf07>
	 <CACT4Y+aMXTBE0uVkeZz+MuPx3X1nESSBncgkScWvAkciAxP1RA@mail.gmail.com>
	 <ebc99ee1-716b-0b18-66ab-4e93de02ce50@virtuozzo.com>
	 <1562640832.9077.32.camel@mtksdccf07>
	 <d9fd1d5b-9516-b9b9-0670-a1885e79f278@virtuozzo.com>
	 <1562839579.5846.12.camel@mtksdccf07>
	 <37897fb7-88c1-859a-dfcc-0a5e89a642e0@virtuozzo.com>
	 <1563160001.4793.4.camel@mtksdccf07>
	 <9ab1871a-2605-ab34-3fd3-4b44a0e17ab7@virtuozzo.com>
	 <1563789162.31223.3.camel@mtksdccf07>
	 <e62da62a-2a63-3a1c-faeb-9c5561a5170c@virtuozzo.com>
	 <1564144097.515.3.camel@mtksdccf07>
	 <71df2bd5-7bc8-2c82-ee31-3f68c3b6296d@virtuozzo.com>
	 <1564147164.515.10.camel@mtksdccf07>
	 <f29ee964-cf12-1b5d-e570-1d5baa49a580@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-TM-SNTS-SMTP:
	EFC55C8D8568410C5734BD4FCFD4848B3C4EE4673A27E15E32FD2B157FABFEE12000:8
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-31 at 20:04 +0300, Andrey Ryabinin wrote:
> 
> On 7/26/19 4:19 PM, Walter Wu wrote:
> > On Fri, 2019-07-26 at 15:52 +0300, Andrey Ryabinin wrote:
> >>
> >> On 7/26/19 3:28 PM, Walter Wu wrote:
> >>> On Fri, 2019-07-26 at 15:00 +0300, Andrey Ryabinin wrote:
> >>>>
> >>>
> >>>>>
> >>>>>
> >>>>> I remember that there are already the lists which you concern. Maybe we
> >>>>> can try to solve those problems one by one.
> >>>>>
> >>>>> 1. deadlock issue? cause by kmalloc() after kfree()?
> >>>>
> >>>> smp_call_on_cpu()
> >>>
> >>>>> 2. decrease allocation fail, to modify GFP_NOWAIT flag to GFP_KERNEL?
> >>>>
> >>>> No, this is not gonna work. Ideally we shouldn't have any allocations there.
> >>>> It's not reliable and it hurts performance.
> >>>>
> >>> I dont know this meaning, we need create a qobject and put into
> >>> quarantine, so may need to call kmem_cache_alloc(), would you agree this
> >>> action?
> >>>
> >>
> >> How is this any different from what you have now?
> > 
> > I originally thought you already agreed the free-list(tag-based
> > quarantine) after fix those issue. If no allocation there,
> 
> If no allocation there, than it must be somewhere else.
> We known exactly the amount of memory we need, so it's possible to preallocate it in advance.
> 
I see. We will implement an extend slub to record five free backtrack
and free pointer tag, and determine whether it is oob or uaf by the free
pointer tag. If you have other ideas, please tell me. Thanks.

 

