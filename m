Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CB19C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:28:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 713C420663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:28:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 713C420663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E7CA8E0006; Wed, 26 Jun 2019 04:28:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 097738E0002; Wed, 26 Jun 2019 04:28:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA2318E0006; Wed, 26 Jun 2019 04:28:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B57CF8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 04:28:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so2067098eds.14
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:28:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ms7X/OxlHND0uIvqrZtVGSlK1qeTOLcqBYaQP0TCTJk=;
        b=Uq7b4A0YBUyM7jhE98mfUPLCfq89Sie76UycqInRFi53soiNBWXUrg7PVGcvopZV22
         nF6o8wYjOf6SVylsrsQUmtfD50kjUmdO1cEAakA8rlhG2QqfUVC2LNjq/hSYrY27Uz9L
         6Sv93V2tGpvwk0G0SAVZWcmQ0kzdtb/xZdiRuWVwP6sAh10xSpzL8fsZYoBTgKpTOA9l
         Ptz3OCto7il0VR0yoM40S5bCB0ANm0GiMr3Jt/s5d1GRczO116biy5kU4EG6RgigltRo
         74rIYGee51W6pz3bbrvS8JyezRYCXod4Yns4qaFfN2Vjv1m8foTdbQ+nL2bj3jslAOSp
         lW1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVLwwH5fxpevmrSepyZl/+e56myVjFYpaRGneHGq4afgabfohMZ
	XUEw34z9o97QH24VbcYPrQlSVIj/3ypL/8ywIHi21ZNyBHKSEUs2D+ACDZKXs7kYSgZRJk1cq29
	DVoI0bl/Muo3NGWlQJvNY4Q8sFJ/bTU+1rdxROCmksx5zmZZ9KLznqFiuvK+w44ycKA==
X-Received: by 2002:aa7:d4cf:: with SMTP id t15mr3638586edr.215.1561537725330;
        Wed, 26 Jun 2019 01:28:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzEuYv70b5VJapSkwTA/iYF2oIlBC/fxwjlqocyG6K9wXJNFL3hc3oOVQdRBTGIVozrqE7
X-Received: by 2002:aa7:d4cf:: with SMTP id t15mr3638538edr.215.1561537724640;
        Wed, 26 Jun 2019 01:28:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561537724; cv=none;
        d=google.com; s=arc-20160816;
        b=ECEBEB0d4IuS2r57ENqbnxnjnaUI4Hke6TG3pp4awafFMWpJZsWWP3g9/H5fJReQxr
         EMM4l8xVyMzJ4JKbKbDfxp77exIfoIJndDcKKWyIXLZBZEBt4sR0g+EN5qXojLL51Eom
         ZPLRm/5lx4uRxqIGkINhrI3qP9bokpaeppXJwvvl2WQEwY7poX03TcMbnSVYtXyys+NI
         W0CU1zxHBebOrn/ZTEF3XKhe83nw7jqnKnc7KRsSqXVOPsZwsKRFi7m56DAf4F3udbCW
         zHaJs+8uEYRhvZEPW+ouBvjp1SXRwH0CKNfmd1RkPB04+/EmQsuwxscebDhxXM7ueN6Y
         f04g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ms7X/OxlHND0uIvqrZtVGSlK1qeTOLcqBYaQP0TCTJk=;
        b=RpLYN2410ybU3pScr2vOrw7esVtiBb9qMTN/8+GozSYNCgB2J6LBCKH9P5WAoMw3kG
         9rGeFO9Fr7IbwUhA52Zmp077ntzk8hFbPKrCFPcW/1xt8zmKI1uUR6LyV6a8zGskz5UT
         srgpDWW1QoFThdJ0v37q0Vmhd9aR7jFwT6G0qA8BNUh0PV0LFBYNAG6fSmWrZfuq9+db
         DtZJ2NNmOQa5gO9/hilVq7uHldz4Xp5GMZniMKu3IcTRBb2aj8WfeCrXwXUn6uepl3yl
         epO00kUGvsg350ly5pd/Y1T0agZW5J3rO+AV892hj9RvPbYp2A9RUI277BaZYN2ae12A
         cHUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o47si2731999edc.347.2019.06.26.01.28.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 01:28:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0D80AAD7E;
	Wed, 26 Jun 2019 08:28:44 +0000 (UTC)
Date: Wed, 26 Jun 2019 10:28:41 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
	david@redhat.com, vbabka@suse.cz, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 4/5] mm,memory_hotplug: allocate memmap from the added
 memory range for sparse-vmemmap
Message-ID: <20190626082841.GE30863@linux>
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-5-osalvador@suse.de>
 <3056b153-20a3-ac86-4a49-c26f8be4b2a6@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3056b153-20a3-ac86-4a49-c26f8be4b2a6@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 01:47:32PM +0530, Anshuman Khandual wrote:
> Hello Oscar,
> 
> On 06/25/2019 01:22 PM, Oscar Salvador wrote:
> > diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> > index 93ed0df4df79..d4b5661fa6b6 100644
> > --- a/arch/arm64/mm/mmu.c
> > +++ b/arch/arm64/mm/mmu.c
> > @@ -765,7 +765,10 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
> >  		if (pmd_none(READ_ONCE(*pmdp))) {
> >  			void *p = NULL;
> >  
> > -			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
> > +			if (altmap)
> > +				p = altmap_alloc_block_buf(PMD_SIZE, altmap);
> > +			else
> > +				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
> >  			if (!p)
> >  				return -ENOMEM;
> 
> Is this really required to be part of this series ? I have an ongoing work
> (reworked https://patchwork.kernel.org/patch/10882781/) enabling altmap
> support on arm64 during memory hot add and remove path which is waiting on
> arm64 memory-hot remove to be merged first.

Hi Anshuman,

I can drop this chunk in the next version.
No problem.

-- 
Oscar Salvador
SUSE L3

