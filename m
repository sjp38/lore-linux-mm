Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F46FC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:17:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E9A2216C8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:17:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E9A2216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B718F8E0003; Thu,  1 Aug 2019 03:17:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B22688E0001; Thu,  1 Aug 2019 03:17:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EA158E0003; Thu,  1 Aug 2019 03:17:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E20C8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:17:14 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so44083541edd.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:17:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cbYKC7RCywrWFP6URPgOSCcalyLP1lhYux9xKSlup5I=;
        b=B4AjmHHUjV1/WlHRJjXyHnSKvWtOB3hEWUzsB4U8qI4U4/3fRKKZnsMAyTQTpla3Vt
         fOQER5vod/+Mr7F6LY8I6+/Hib8LvuLmjw24K8hJgOiiOPzfls6INcAm+6b4JmxnpEBn
         8Tz2T5un+kMGVYZOn8smtJ2L4pXzpqRDjOPf5GfnnBFXnACj3e3KFnOgC74NnRmLQGMm
         Q/2vIVCZhUHuejEYKtOqw5eUCK7ZUlt0FasHh4TjFb//O6ykjoPrSeOkCx+L7Wa/x+tK
         /g77j66zrrso2qpZWveX5Z4X7kIO+mtp+8aGPo7Sl/Hob6cqWlXxpRigXebhO8R0aIHy
         PNkg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXye85bOc+U5bWjBJw47y0Ejrcu6TxZl/7W2Gi3NHXFqWoypY62
	/4gDRbD4RP9iKXrgkLg0t+KLMfc9KpRrmv2fnHS3z1Z3mycvqNRxp0c/bmwjbU8KqvguoUp/9yU
	x7E2L/8NXBf/Cnn+P928odfxEkcvHMk1ASW6Ml5Je5NAucBZMzQJXPcspUdeQP+E=
X-Received: by 2002:aa7:c149:: with SMTP id r9mr109132229edp.92.1564643833893;
        Thu, 01 Aug 2019 00:17:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIgxQ8thg+UU+T64PW8aqRG9fGv5z2LVERMDRkl8O5SMOslLdolqx0PHoKOLKgGyqWL/Fy
X-Received: by 2002:aa7:c149:: with SMTP id r9mr109132167edp.92.1564643833136;
        Thu, 01 Aug 2019 00:17:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564643833; cv=none;
        d=google.com; s=arc-20160816;
        b=RZ3MLPLgkL/CBTsb1rcreu4Fz/jFKlXzO5/jsbkB+C7FlShJozhpgGhCPEOUx6LPfH
         ZKnnneoKuQYJUX0X9WTWUSSJ3dcM9rtbn8j8taYe2erOXhD01I1XrEDeSsyE29S9xixK
         jMqrRDxRAMTag3ehlH1hXAJAv/FYYMWyD4JJWeMMbvEXDveeVvOXLpBUIzCuEGZAYL3m
         NtRzgk8Dg+iAr3sOWQShdfeioDpOgXH1ueFVkNeJ/vwCR/+jdaFX0byPVIS08p+A8phS
         uZbPS79RBUKlBlTBElU1VpehLn81nem6JJNd5l70xpHJxpu3KBEh+EgyAJWyNWBrr1iK
         K4TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cbYKC7RCywrWFP6URPgOSCcalyLP1lhYux9xKSlup5I=;
        b=ttSqgQjv8bJUNzz5BjN10TO+1BPIzxnFkD6aPJMjk1mt4eg+B2shEH2M6J0vsky6H9
         0uPr+a8c/SogHaBw57+ba3Fja82m72Ulew3r+Kv4IZMA0SBek6HOT76itzwuq0Frhhxn
         DM/Ec91q8woGGTI5vUJxw6afMUEDnxGKPQKtENXxLrpas7h9pzCa/sVozTLA4shv5zwH
         d1koVq9UNHCJPrlLV0sx96AKjLaS+WTrzGpf78eJCM1Cdsa2k0MkwQXfJ80cGFpLte0p
         So1b36pAlPFTiPSm1xc2VNNZrSm52MKhCRLC9UVxgaN3PS0BACiHDC0xHMnDbgk1VeRs
         jigQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2si22768182edd.314.2019.08.01.00.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:17:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3DE8EADC4;
	Thu,  1 Aug 2019 07:17:12 +0000 (UTC)
Date: Thu, 1 Aug 2019 09:17:09 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Rashmica Gupta <rashmica.g@gmail.com>
Cc: Oscar Salvador <osalvador@suse.de>,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
Message-ID: <20190801071709.GE11627@dhcp22.suse.cz>
References: <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux>
 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux>
 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
 <20190702074806.GA26836@linux>
 <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
 <20190731120859.GJ9330@dhcp22.suse.cz>
 <4ddee0dd719abd50350f997b8089fa26f6004c0c.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ddee0dd719abd50350f997b8089fa26f6004c0c.camel@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 01-08-19 09:06:40, Rashmica Gupta wrote:
> On Wed, 2019-07-31 at 14:08 +0200, Michal Hocko wrote:
> > On Tue 02-07-19 18:52:01, Rashmica Gupta wrote:
> > [...]
> > > > 2) Why it was designed, what is the goal of the interface?
> > > > 3) When it is supposed to be used?
> > > > 
> > > > 
> > > There is a hardware debugging facility (htm) on some power chips.
> > > To use
> > > this you need a contiguous portion of memory for the output to be
> > > dumped
> > > to - and we obviously don't want this memory to be simultaneously
> > > used by
> > > the kernel.
> > 
> > How much memory are we talking about here? Just curious.
> 
> From what I've seen a couple of GB per node, so maybe 2-10GB total.

OK, that is really a lot to keep around unused just in case the
debugging is going to be used.

I am still not sure the current approach of (ab)using memory hotplug is
ideal. Sure there is some overlap but you shouldn't really need to
offline the required memory range at all. All you need is to isolate the
memory from any existing user and the page allocator. Have you checked
alloc_contig_range?

-- 
Michal Hocko
SUSE Labs

