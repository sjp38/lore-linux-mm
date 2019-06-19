Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40666C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:01:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 098672080C
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:01:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 098672080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 811666B0003; Wed, 19 Jun 2019 05:01:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C0D38E0002; Wed, 19 Jun 2019 05:01:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 689518E0001; Wed, 19 Jun 2019 05:01:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF3F6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:01:30 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so25217079edc.17
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:01:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=x38cJ/fp/gnL0bx4KfW+iwp0XOEvsPxBL0F/6NWA7+M=;
        b=s/OgzyGbJbUgso9TV5Nall7kGf7nAqp6xtN7aG4eo1DlFC2hu/DjYU09dE2dL2nXoj
         nnHcGC8RpXeDVnQ6mgQff3vy2Eiz/smyyy5g0czfeLLjGSEcPRXL7VlyHeSMV17YhxIH
         P/GlJbg0I7gUYNw7bjP4aKtnzS2/cnyc4nHGiPRSGtJk3UxfVX4ATz4cv0/NOdfaW7X8
         MxEhAjDWuQ1X2KZoOV+mJF6y0ZFP+X9fCCu4j0Abvl+HDOrI20IUlO/ImAB1dJVutwNv
         WJ/nRRWX3Z53Y+FptXScdv+i70WLMcqmIUugr+vGqfxRvMG7w6Z4CrkUhIilNPKoUfvW
         f4Xw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAVNizAAhEkWBe3+xSNEK9ooIJHGosEdDP0GzUg/RmLyD3lrFVvz
	Q3aF/NX7RUALCqUr1BNdR115k67RoxYf7N3di2NZ4rJbM1ZBsvrC+RHiN6ufPHoPJ8lDkHX0gQf
	4gqlEP0xM4IblAmce+iJ34Zg767PZ+6FyDR3H9y30n+dETC2JwCWN2gIHbZDUa3lUtw==
X-Received: by 2002:a50:b1bd:: with SMTP id m58mr27115245edd.185.1560934889669;
        Wed, 19 Jun 2019 02:01:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiDiS8qzpd6KgkSnyKWh19m/FGhwIESM6wM3e2q6lY2+hp0QFmIGR3luBcS0SEMjfsloFP
X-Received: by 2002:a50:b1bd:: with SMTP id m58mr27115073edd.185.1560934887976;
        Wed, 19 Jun 2019 02:01:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560934887; cv=none;
        d=google.com; s=arc-20160816;
        b=yZZfX43R1jX6YuziCbGxvX9oNrmpYG7pSEXfACi73qb/vyaNyO4bUEgjGzwJ627b8o
         AmDZJnBXeQdcXNDVyWsR0GmQigl1IH3/BBnbZKyzz8e0IxakbJG5tbwGOWJGbeptCXQZ
         hZFlDsD3jbKK64K8WoPRBMjnSicxuBTteieSyLre26k7LjkevNFK8UGLvb2VYqmlUVS0
         ogfZr/Pfb7HWAbPwYqYx/AM759CobkL7d3cVILuCBlBNfDO7FuwR71d3FmMPJ28lGRRz
         NKh1Zzjg764LhHrsLNnUIcvY4FFgY6vYiMvgF9ZZtiNtfMo3tWBuyVmt/I+Ru5ZWFtg4
         T7zQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=x38cJ/fp/gnL0bx4KfW+iwp0XOEvsPxBL0F/6NWA7+M=;
        b=T+xdGM2FspAWaNZVZs0/1Q5/1RDNe5/l44sFxB3VyyffYgUOhxkvUV88C0lPDgwk9x
         A/EtEvnGuZfTwXer+5341GbaiHH663rfgINXfjNZd1zpAyA3KmKuJt0/88qacyVoZNsp
         zm45z9vTyPPlHo0ge+ndG7t0L/Rz4IzMNokpJmvuy0x1S4Nc4yZzEgfN0R0nSd9gRgyi
         A7RbGRfv3s+tUeMs/MsPhfPG6ottuTpAUqF333xibldW6Qm7d6pNjF9nmwArmqotI4Wd
         a84LKInoCx5M2+nhB1OTVIW6AFCqebGExqQB0R8pYjeaqjunVrCOps5tXMnETG/XF5P0
         nw9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z50si12634424edb.13.2019.06.19.02.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 02:01:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 61317AFF1;
	Wed, 19 Jun 2019 09:01:27 +0000 (UTC)
Date: Wed, 19 Jun 2019 11:01:26 +0200
From: Michal Hocko <mhocko@suse.com>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>,
	Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
	akpm@linux-foundation.org, anshuman.khandual@arm.com
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
Message-ID: <20190619090126.GI2968@dhcp22.suse.cz>
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190618074900.GA10030@linux>
 <20190618083212.GA24738@richard>
 <93d7ea6c-135e-7f12-9d75-b3657862dea0@redhat.com>
 <20190619061025.GA5717@dhcp22.suse.cz>
 <aaa9d3af-0472-ffde-a565-fe6a067a4c49@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aaa9d3af-0472-ffde-a565-fe6a067a4c49@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 19-06-19 10:54:08, David Hildenbrand wrote:
> On 19.06.19 08:10, Michal Hocko wrote:
> > On Tue 18-06-19 10:40:06, David Hildenbrand wrote:
> >> On 18.06.19 10:32, Wei Yang wrote:
> >>> On Tue, Jun 18, 2019 at 09:49:48AM +0200, Oscar Salvador wrote:
> >>>> On Tue, Jun 18, 2019 at 08:55:37AM +0800, Wei Yang wrote:
> >>>>> In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
> >>>>> section_to_node_table[]. While for hot-add memory, this is missed.
> >>>>> Without this information, page_to_nid() may not give the right node id.
> >>>>>
> >>>>> BTW, current online_pages works because it leverages nid in memory_block.
> >>>>> But the granularity of node id should be mem_section wide.
> >>>>
> >>>> I forgot to ask this before, but why do you mention online_pages here?
> >>>> IMHO, it does not add any value to the changelog, and it does not have much
> >>>> to do with the matter.
> >>>>
> >>>
> >>> Since to me it is a little confused why we don't set the node info but still
> >>> could online memory to the correct node. It turns out we leverage the
> >>> information in memblock.
> >>
> >> I'd also drop the comment here.
> >>
> >>>
> >>>> online_pages() works with memblock granularity and not section granularity.
> >>>> That memblock is just a hot-added range of memory, worth of either 1 section or multiple
> >>>> sections, depending on the arch or on the size of the current memory.
> >>>> And we assume that each hot-added memory all belongs to the same node.
> >>>>
> >>>
> >>> So I am not clear about the granularity of node id. section based or memblock
> >>> based. Or we have two cases:
> >>>
> >>> * for initial memory, section wide
> >>> * for hot-add memory, mem_block wide
> >>
> >> It's all a big mess. Right now, you can offline initial memory with
> >> mixed nodes. Also on my list of many ugly things to clean up.
> >>
> >> (I even remember that we can have mixed nodes within a section, but I
> >> haven't figured out yet how that is supposed to work in some scenarios)
> > 
> > Yes, that is indeed the case. See 4aa9fc2a435abe95a1e8d7f8c7b3d6356514b37a.
> > How to fix this? Well, I do not think we can. Section based granularity
> > simply doesn't agree with the reality and so we have to live with that.
> > There is a long way to remove all those section size assumptions from
> > the code though.
> > 
> 
> Trying to remove NODE_NOT_IN_PAGE_FLAGS could work, but we would have to
> identify how exactly needs that. For memory blocks, we need a different
> approach (I have in my head to make ->nid indicate if we are dealing
> with mixed nodes. If mixed, disallow onlining/offlining).

Well, I am not sure we really have to care about mutli-nodes memblocks
much. The API is clumsy but does anybody actually care? The vast
majority of hotplug usecases simply do not do that in the first place
right? And if they do need a smaller granularity to describe their
memory topology then we need a different user API rather the fiddle with
implementation details I would argue.
-- 
Michal Hocko
SUSE Labs

