Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA02DC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:13:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E734208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:13:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E734208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B6B66B0003; Wed, 26 Jun 2019 04:13:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 140788E0003; Wed, 26 Jun 2019 04:13:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07D068E0002; Wed, 26 Jun 2019 04:13:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B068E6B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 04:13:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d13so2047172edo.5
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:13:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=j8LvXrmoX6D+p8/59johR0wkonUaJDkSnJVhFa1qqW0=;
        b=s9LtpeCLimPEXVfIEDAJJhZTgwWJn9XDuZvVPJPtLvZFy7z9XtfYu/e+7TNhz8HeKV
         VV99ZV0X1xnIlHSubCwP/kSwE5capQZsg6eA6WkLM65Mgky0GHtm1lzx8CRGJn7TgR2a
         NU7YY2+Wi9IyHg810nIzvN91mmqLkXY365GyBPqgT34TG7ripchbMUPsTwviNhhUWYCo
         nDcoW40qpY4/K87HHxWP65RZkUz6aBTAx8QSiZL1NU2CXWNeV882Ws21jsuhMlfzseq9
         OSY0boALCOSCxKAQMv2qGRmTJPJFnaYbeZJoZPK/kyFt93L/X+omHJDx0ZE6JUlqSqJr
         GWfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXuEioYm07axi/EuQ1E4Hs1j9SCtzbvSWBTUHDB82cFiPzpwsjl
	PXDiHKcuFX8mMyi8qcNkUn2SufiXkg2iwd576/nJBiWKUYEo73kUUxJO9tuM/HSuIpLAm/EcyRr
	jOgjh1ZgmgGNRigRcP8nTf7fQRoL/9+L87nWbUiLEplgfvdSiJKGLoFQWhktAzRUtIw==
X-Received: by 2002:a50:ac6e:: with SMTP id w43mr3547277edc.181.1561536810270;
        Wed, 26 Jun 2019 01:13:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxJTMjbBjklYH45015CprlkLzQ8AJwkSbgK3F32JmgV5Q6+/AKxYLBa9LEDoGL8Vb98ShY
X-Received: by 2002:a50:ac6e:: with SMTP id w43mr3547214edc.181.1561536809532;
        Wed, 26 Jun 2019 01:13:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561536809; cv=none;
        d=google.com; s=arc-20160816;
        b=vj/SLbJj7hDY72tlxGheIJt0b68VRvtqdNBbCkIYQZJrdMLZY/SMGV1Sz1/Im2EBYY
         xDxULVTFRAIitM+h0AKqQQu3S7zSxnNstAXrG+LI/IoCGTu7ORyipyUBVs5VF0kzES52
         pjdyW7LQsHZ728kdmMCr3qOWO+V68EDc10NnETQdn/KE/Csyuox27ECpIjJLRqKVyhkc
         maIEknighCJ7+r5lmRczJRZKNgNy5Eav7Aa7IsN1MiOSiPX3CfuH0Sez7acM12aEatA6
         gX5Cnprl7dI34x6w/xhNJxcWV44itgXEWwSFkOS0WKEdIeZD3QFYJu+q96YOQnLF65o4
         LrDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=j8LvXrmoX6D+p8/59johR0wkonUaJDkSnJVhFa1qqW0=;
        b=rtBAZ62znC9zux3kLyGuAHipyh6WPh+JwE0WOvx2XtNTXhcLLUaxTY00H/ZvK6kVk6
         dNEXKVlMGVj+p3INbIvbsu2oQhNh8SFX+nnEsDJvSKPFFqOkVzev3yiCoa1sh1eucgpJ
         Rj+WlmFau/RYwRp6gG1sWRZGnpFGZ6ItP7UdEVGR0CI4evoGB0bIk3myYfzFMiQ4R/Xy
         gfD4VJB4bNFBJ463NTAknUuPUUTD5RExseElnHlbQROm649qeP8VdZcggBBvVtoXvadV
         022KgzfN/HUCzRqnJXAqg2vkG8DRQiXd4WJ4YU7WYYc48KZgPfEDgkjYrUOJq7CxagnZ
         HtxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w24si2856204eda.92.2019.06.26.01.13.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 01:13:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B2E32AAD0;
	Wed, 26 Jun 2019 08:13:28 +0000 (UTC)
Date: Wed, 26 Jun 2019 10:13:25 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 4/5] mm,memory_hotplug: allocate memmap from the added
 memory range for sparse-vmemmap
Message-ID: <20190626081325.GB30863@linux>
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-5-osalvador@suse.de>
 <80f8afcf-0934-33e5-5dc4-a0d19ec2b910@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80f8afcf-0934-33e5-5dc4-a0d19ec2b910@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 10:49:10AM +0200, David Hildenbrand wrote:
> On 25.06.19 09:52, Oscar Salvador wrote:
> > Physical memory hotadd has to allocate a memmap (struct page array) for
> > the newly added memory section. Currently, alloc_pages_node() is used
> > for those allocations.
> > 
> > This has some disadvantages:
> >  a) an existing memory is consumed for that purpose
> >     (~2MB per 128MB memory section on x86_64)
> >  b) if the whole node is movable then we have off-node struct pages
> >     which has performance drawbacks.
> > 
> > a) has turned out to be a problem for memory hotplug based ballooning
> >    because the userspace might not react in time to online memory while
> >    the memory consumed during physical hotadd consumes enough memory to
> >    push system to OOM. 31bc3858ea3e ("memory-hotplug: add automatic onlining
> >    policy for the newly added memory") has been added to workaround that
> >    problem.
> > 
> > I have also seen hot-add operations failing on powerpc due to the fact
> > that we try to use order-8 pages. If the base page size is 64KB, this
> > gives us 16MB, and if we run out of those, we simply fail.
> > One could arge that we can fall back to basepages as we do in x86_64, but
> > we can do better when CONFIG_SPARSEMEM_VMEMMAP is enabled.
> > 
> > Vmemap page tables can map arbitrary memory.
> > That means that we can simply use the beginning of each memory section and
> > map struct pages there.
> > struct pages which back the allocated space then just need to be treated
> > carefully.
> > 
> > Implementation wise we reuse vmem_altmap infrastructure to override
> > the default allocator used by __vmemap_populate. Once the memmap is
> > allocated we need a way to mark altmap pfns used for the allocation.
> > If MHP_MEMMAP_{DEVICE,MEMBLOCK} flag was passed, we set up the layout of the
> > altmap structure at the beginning of __add_pages(), and then we call
> > mark_vmemmap_pages().
> > 
> > Depending on which flag is passed (MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK),
> > mark_vmemmap_pages() gets called at a different stage.
> > With MHP_MEMMAP_MEMBLOCK, we call it once we have populated the sections
> > fitting in a single memblock, while with MHP_MEMMAP_DEVICE we wait until all
> > sections have been populated.
> 
> So, only MHP_MEMMAP_DEVICE will be used. Would it make sense to only
> implement one for now (after we decide which one to use), to make things
> simpler?
> 
> Or do you have a real user in mind for the other?

Currently, only MHP_MEMMAP_DEVICE will be used, as we only pass flags from
acpi memory-hotplug path.

All the others: hyper-v, Xen,... will have to be evaluated to see which one
do they want to use.

Although MHP_MEMMAP_DEVICE is the only one used right now, I introduced
MHP_MEMMAP_MEMBLOCK to give the callers the choice of using MHP_MEMMAP_MEMBLOCK
if they think that a strategy where hot-removing works in a different granularity
makes sense.

Moreover, since they both use the same API, there is no extra code needed to
handle it. (Just two lines in __add_pages())

This arose here [1].

[1] https://patchwork.kernel.org/project/linux-mm/list/?submitter=137061

-- 
Oscar Salvador
SUSE L3

