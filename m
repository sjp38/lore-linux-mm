Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28371C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:30:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2BC222C7E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:30:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2BC222C7E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FFA16B0006; Fri, 26 Jul 2019 05:30:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B0C98E0003; Fri, 26 Jul 2019 05:30:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 477F08E0002; Fri, 26 Jul 2019 05:30:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECB796B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:30:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so33746297edr.13
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:30:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EvZCbsszsIRxIg04h/B3I532+/1OWJHuSOk9U2uq9O8=;
        b=gSFMpQR4t5u7yTxJXBdf8EQkXlHVM1FlcychaE61ot++jE+rsgIPTmns2RaNo6mzsE
         59+8e+dmnQu0RoqafG5gp8PFopHmQGwD2tGe/o6PTfa86QXdgyeesPVVOC8oUJbo7MrI
         t5evfjylx7yVCDjGle10BdxTTjOhhDerO0GD4DuPE7J7M41FfF/rVXHUmPL4mXgoWSka
         oP+eGwPSIMg4BEWcQAbyVcplzW3E2p3a2eqWxgSgNDLVu1TzsyIua/Rb8aOgHZ0DZ1cG
         ev9y/kPU3X9O5E+ybT7+LI6HAZ2ii6Nwmm7iLSrS85AZsOtmIDvJPfav+aNgM1sQq13z
         MVlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXLO83MzVr1WCcnP1lvzK0cP1/c62xB9lRevd2pGHXWlDpqosR6
	TfPsxL1mAUuI9mROR0nLRHKDpcopr8abwvjQtAIZQLQkeLbQwdbwcKTVLPXQciVNpGZ0ogvUMKU
	MeAOnovoXuUekKP1PqB4wgfJv+tNhhcRu2TJ+eCJm1Z6oCB42YJpLEo4Kb4AJwgjAZw==
X-Received: by 2002:a50:ae8f:: with SMTP id e15mr80914770edd.74.1564133403513;
        Fri, 26 Jul 2019 02:30:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxM12FQXSBJ7OjTc4OK1OFZopZptbA3CAGMKYMFO+U7FCm78YCMPTrp3Rc2ZdGEtSUXZL9z
X-Received: by 2002:a50:ae8f:: with SMTP id e15mr80914715edd.74.1564133402840;
        Fri, 26 Jul 2019 02:30:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564133402; cv=none;
        d=google.com; s=arc-20160816;
        b=fLC7mCBC1ec2ADuEIo3oybC30JItQXC8665oGJxq68YXLjoPkCjjoBbVzwADvM3ySb
         2TBQZ2DcJ/Aurfqf0F9o4o9Xt976ZxqmNLcB7aTEOfgMAEyt0Uf8qR9VR6ta2TaOw+Q+
         dX+7F2PSo1wYgT1K6xEnWGOoyqq5gOq834xJCaCetg2Ej2L/9Ltfz2pCVOXXYWiWTB4v
         0MRSxN4yJ7knqwI2Ivw3klAe2HuF4cTsy1S0e1cm76GPcpCLw1glTkYjz37sU0Kf7mr0
         Wod3Zzt2euVkh8sNWX0+dDJeIyb4patMC0Q2Tv6ptPUiF1N7YZIhyiI+FK1iPkqKxhQS
         DMYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EvZCbsszsIRxIg04h/B3I532+/1OWJHuSOk9U2uq9O8=;
        b=ZxqkeSmkH2aIYglmddGVJ8TE2KibGs/7sK302Ooy5WVpgoSbwtAHfiQCE+oONBLsZS
         nuiJIT2z2jxdeLVrqSwhAlMVtFGJ2i72+/aFSe8R9LPZq9t0DfNYpQFgBYsStsGFu2tV
         8PQVoguB72hntyLcGsoiPikwc288TuVyCy/ayIRRdY4M8FY6+x+eElv3GbbugjHa1qaN
         cE6CDoXvIZfQo3c+z5yuv0rFRxoS74gh0IEYNrZmSabmS7LcCBydiSzZsgY1ng/49ili
         OlTSdxG48IT/XsNsZsBlF48FRkFNqGG4Z03a8vh0DSNY+xk5N5ebA0zsphZgmKZa8J77
         +CqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u13si12039836ejx.356.2019.07.26.02.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 02:30:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 474DFB609;
	Fri, 26 Jul 2019 09:30:02 +0000 (UTC)
Date: Fri, 26 Jul 2019 11:29:59 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
	pasha.tatashin@soleen.com, mhocko@suse.com,
	anshuman.khandual@arm.com, Jonathan.Cameron@huawei.com,
	vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 1/5] mm,memory_hotplug: Introduce MHP_MEMMAP_ON_MEMORY
Message-ID: <20190726092959.GB26268@linux>
References: <20190725160207.19579-1-osalvador@suse.de>
 <20190725160207.19579-2-osalvador@suse.de>
 <8b60e40a-1e8a-1f7c-a31d-ad2e511decd5@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8b60e40a-1e8a-1f7c-a31d-ad2e511decd5@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 10:34:47AM +0200, David Hildenbrand wrote:
> > Want to add 384MB (3 sections, 3 memory-blocks)
> > e.g:
> > 
> > 	add_memory(0x1000, size_memory_block);
> > 	add_memory(0x2000, size_memory_block);
> > 	add_memory(0x3000, size_memory_block);
> > 
> > 	[memblock#0  ]
> > 	[0 - 511 pfns      ] - vmemmaps for section#0
> > 	[512 - 32767 pfns  ] - normal memory
> > 
> > 	[memblock#1 ]
> > 	[32768 - 33279 pfns] - vmemmaps for section#1
> > 	[33280 - 65535 pfns] - normal memory
> > 
> > 	[memblock#2 ]
> > 	[65536 - 66047 pfns] - vmemmap for section#2
> > 	[66048 - 98304 pfns] - normal memory
> 
> I wouldn't even care about documenting this right now. We have no user
> so far, so spending 50% of the description on this topic isn't really
> needed IMHO :)

Fair enough, I could drop it.
Was just trying to be extra clear.

> 
> > 
> > or
> > 	add_memory(0x1000, size_memory_block * 3);
> > 
> > 	[memblock #0 ]
> >         [0 - 1533 pfns    ] - vmemmap for section#{0-2}
> >         [1534 - 98304 pfns] - normal memory
> > 
> > When using larger memory blocks (1GB or 2GB), the principle is the same.
> > 
> > Of course, per whole-range granularity is nicer when it comes to have a large
> > contigous area, while per memory-block granularity allows us to have flexibility
> > when removing the memory.
> 
> E.g., in my virtio-mem I am currently adding all memory blocks
> separately either way (to guranatee that remove_memory() works cleanly -
> see __release_memory_resource()), and to control the amount of
> not-offlined memory blocks (e.g., to make user space is actually
> onlining them). As it's just a prototype, this might change of course in
> the future.

What is virtio-mem for? Did it that raised from a need?
Is it something you could try this patch on?

> >  /*
> > + * We want memmap (struct page array) to be allocated from the hotadded range.
> > + * To do so, there are two possible ways depending on what the caller wants.
> > + * 1) Allocate memmap pages whole hot-added range.
> > + *    Here the caller will only call any add_memory() variant with the whole
> > + *    memory address.
> > + * 2) Allocate memmap pages per memblock
> > + *    Here, the caller will call any add_memory() variant per memblock
> > + *    granularity.
> > + * The former implies that we will use the beginning of the hot-added range
> > + * to store the memmap pages of the whole range, while the latter implies
> > + * that we will use the beginning of each memblock to store its own memmap
> > + * pages.
> 
> Can you make this documentation only state how MHP_MEMMAP_ON_MEMORY
> works? (IOW, shrink it heavily to what we actually implement)

Sure.

> Apart from the requested description/documentation changes
> 
> Reviewed-by: David Hildenbrand <david@redhat.com>

Thanks for having a look David ;-)
> 
> -- 
> 
> Thanks,
> 
> David / dhildenb

-- 
Oscar Salvador
SUSE L3

