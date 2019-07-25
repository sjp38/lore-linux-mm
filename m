Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D38EC76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:40:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E67B62190F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:40:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E67B62190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E5DE8E005D; Thu, 25 Jul 2019 05:40:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 795C28E0059; Thu, 25 Jul 2019 05:40:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65EA88E005D; Thu, 25 Jul 2019 05:40:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18CEC8E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:40:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so31777078edm.21
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:40:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aT7g967mD+mdT8WNK6nZvwpK+UCNtFH70vs3AW7kMMc=;
        b=LiBR60NCbSSCaW88d/mOabBIRbtAzCGF1Ox/SdkBZYdnJy+9J7gN5kjzjLiEMOCkTa
         QTNbVYtOpjPwlmmbixhFJXHWegM08IbMsvWpCtyKkxDoiP67phCihK+096H48trsHT87
         Fr3hFQYGj+7A2YiuDdn89zR2cpQbNR1qg3cqtd7q/xMjaGYPoYYOLDzP+ZbgddOrdUed
         A+nwNcFIZns9CRBltXQmguTngDLpHG//8cQkXiesgzuViXYxRc2MZQ8p8dVFYFSX+KVg
         HZvWCNtQQUy3FsFpvjdFZoAeRl8fsLHOteJBMJMO3/rLw3vey2s3j9kVHNbcmqQBdL1c
         PALA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVi777bbmSRhcKk8A0bTMIhUSc/i+GuC8VVusc1hsF+uBtuhpdD
	HnEhQI72Za9i0ecSBaOo5nAHgRXRNX1mkGNuVZSVv5GXk3hreQrFdlO20yjRTCP/xp7X2L2VSE6
	MScE55bxU+CCvM3dnc+0VbQAbUYea3OQIFxaCHgMQoX0GoKwwYWymHaRt2IH1nM+lLA==
X-Received: by 2002:a50:e618:: with SMTP id y24mr75546626edm.142.1564047638639;
        Thu, 25 Jul 2019 02:40:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQZNiLPBsTFjYceefhxTU0GIxvoTEPy83MavpgIWdfVQ/cFJQZ99aDfS/XECLHucaPinE3
X-Received: by 2002:a50:e618:: with SMTP id y24mr75546585edm.142.1564047637923;
        Thu, 25 Jul 2019 02:40:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564047637; cv=none;
        d=google.com; s=arc-20160816;
        b=RDjclTzGGX4Vvm+QX8+mO2O8g1W8e6LhCPBVUlWU2ZkYkTojt0SWVsVqOJbEAp+AD8
         Vo5lPigSRQ540WKptor6NJeA3WC7VBkPl4bwzz/KeZQf6jPWbHeL3KZL+W42nSSTDJJT
         DAy0UgfGRCZEGVus+lih3FFQ81NjeVQD/eNG463ZNc/bm/66NfM7ROl5r4dawd0eCT3p
         dKil8XtccUk2VsYZPjIp/hHagh3M9E1clvvYDuhPlQEkI9XZ9KgIwFeyHgHa3mbuAPaH
         m0mm36yaxGsERKt643t0ZK6+iIeyX55YzovHwAoO1pOAuqnB2bHSY21+nIkEekAqXQoG
         VsBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aT7g967mD+mdT8WNK6nZvwpK+UCNtFH70vs3AW7kMMc=;
        b=AWdhg91Q9Re+sDUvncCmxJDUxNU5OPi+MTSeC8NdPOfExKi+I/tNZ7QtYw+4bxX4EP
         loxByd6sGt4FxV7Tj9/mSTRknWfzOaRL7wDNu+nC0J+his/qodYby6dQdDFaTyIvFNmC
         oR33u5xM+72PQ8GoA4CTu+Dpfx4kz9nURtElftSTeuQkj6yTcbAvohwhvMcMzsh/VF9O
         XkWXZBhcs4rZa1ZCeFDvhY5aDnDmCtF6KA6F+35KRcSPkn+Wq+KjOzuawRthUE22pPCl
         th1kkmcifLYMaOnb4S4rDce3dY0bMjB9qhWLHa//USwTTNybexoLkRo7Lw/n9Puafoab
         ppIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v30si9743725ejk.208.2019.07.25.02.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 02:40:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5B419ABE9;
	Thu, 25 Jul 2019 09:40:37 +0000 (UTC)
Date: Thu, 25 Jul 2019 11:40:34 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 2/5] mm,memory_hotplug: Introduce MHP_VMEMMAP_FLAGS
Message-ID: <20190725094030.GA16069@linux>
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-3-osalvador@suse.de>
 <CAPcyv4hvu+wp4tJJNW70jp2G_rNabyvzGMvDTS3PzkDCAFztYg@mail.gmail.com>
 <20190725092751.GA15964@linux>
 <71a30086-b093-48a4-389f-7e407898718f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <71a30086-b093-48a4-389f-7e407898718f@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 11:30:23AM +0200, David Hildenbrand wrote:
> On 25.07.19 11:27, Oscar Salvador wrote:
> > On Wed, Jul 24, 2019 at 01:11:52PM -0700, Dan Williams wrote:
> >> On Tue, Jun 25, 2019 at 12:53 AM Oscar Salvador <osalvador@suse.de> wrote:
> >>>
> >>> This patch introduces MHP_MEMMAP_DEVICE and MHP_MEMMAP_MEMBLOCK flags,
> >>> and prepares the callers that add memory to take a "flags" parameter.
> >>> This "flags" parameter will be evaluated later on in Patch#3
> >>> to init mhp_restrictions struct.
> >>>
> >>> The callers are:
> >>>
> >>> add_memory
> >>> __add_memory
> >>> add_memory_resource
> >>>
> >>> Unfortunately, we do not have a single entry point to add memory, as depending
> >>> on the requisites of the caller, they want to hook up in different places,
> >>> (e.g: Xen reserve_additional_memory()), so we have to spread the parameter
> >>> in the three callers.
> >>>
> >>> The flags are either MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK, and only differ
> >>> in the way they allocate vmemmap pages within the memory blocks.
> >>>
> >>> MHP_MEMMAP_MEMBLOCK:
> >>>         - With this flag, we will allocate vmemmap pages in each memory block.
> >>>           This means that if we hot-add a range that spans multiple memory blocks,
> >>>           we will use the beginning of each memory block for the vmemmap pages.
> >>>           This strategy is good for cases where the caller wants the flexiblity
> >>>           to hot-remove memory in a different granularity than when it was added.
> >>>
> >>>           E.g:
> >>>                 We allocate a range (x,y], that spans 3 memory blocks, and given
> >>>                 memory block size = 128MB.
> >>>                 [memblock#0  ]
> >>>                 [0 - 511 pfns      ] - vmemmaps for section#0
> >>>                 [512 - 32767 pfns  ] - normal memory
> >>>
> >>>                 [memblock#1 ]
> >>>                 [32768 - 33279 pfns] - vmemmaps for section#1
> >>>                 [33280 - 65535 pfns] - normal memory
> >>>
> >>>                 [memblock#2 ]
> >>>                 [65536 - 66047 pfns] - vmemmap for section#2
> >>>                 [66048 - 98304 pfns] - normal memory
> >>>
> >>> MHP_MEMMAP_DEVICE:
> >>>         - With this flag, we will store all vmemmap pages at the beginning of
> >>>           hot-added memory.
> >>>
> >>>           E.g:
> >>>                 We allocate a range (x,y], that spans 3 memory blocks, and given
> >>>                 memory block size = 128MB.
> >>>                 [memblock #0 ]
> >>>                 [0 - 1533 pfns    ] - vmemmap for section#{0-2}
> >>>                 [1534 - 98304 pfns] - normal memory
> >>>
> >>> When using larger memory blocks (1GB or 2GB), the principle is the same.
> >>>
> >>> Of course, MHP_MEMMAP_DEVICE is nicer when it comes to have a large contigous
> >>> area, while MHP_MEMMAP_MEMBLOCK allows us to have flexibility when removing the
> >>> memory.
> >>
> >> Concept and patch looks good to me, but I don't quite like the
> >> proliferation of the _DEVICE naming, in theory it need not necessarily
> >> be ZONE_DEVICE that is the only user of that flag. I also think it
> >> might be useful to assign a flag for the default 'allocate from RAM'
> >> case, just so the code is explicit. So, how about:
> > 
> > Well, MHP_MEMMAP_DEVICE is not tied to ZONE_DEVICE.
> > MHP_MEMMAP_DEVICE was chosen to make a difference between:
> > 
> >  * allocate memmap pages for the whole memory-device
> >  * allocate memmap pages on each memoryblock that this memory-device spans
> 
> I agree that DEVICE is misleading here, you are assuming a one-to-one
> mapping between a device and add_memory(). You are actually taliing
> about "allocate a single chunk of mmap pages for the whole memory range
> that is added - which could consist of multiple memory blocks".

Well, I could not come up with a better name.

MHP_MEMMAP_ALL?
MHP_MEMMAP_WHOLE?

I will send v3 shortly and then we can think of a better name.

> 
> -- 
> 
> Thanks,
> 
> David / dhildenb
> 

-- 
Oscar Salvador
SUSE L3

