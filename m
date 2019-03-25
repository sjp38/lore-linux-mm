Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49625C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 08:04:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ECC120830
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 08:04:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ECC120830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A19D86B0003; Mon, 25 Mar 2019 04:04:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C8AF6B0005; Mon, 25 Mar 2019 04:04:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 892A26B0007; Mon, 25 Mar 2019 04:04:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3996E6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 04:04:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k8so329428edl.22
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 01:04:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HcuHH9ogBba5nL2wpRNLXpT3U4lA9RM7SAO8tgMfU24=;
        b=t80a/44Yhx4qL3oLDCj9v/KZ0lRbAbXtzODhuf8WugZQ0AcDsl8zKfeubO+E+TWUct
         NAfY9SILmh0Ob3XJYexbMN3vSBkgbwcVsLJpW1da/mfr8zsmkJw+Cd5vngiPd4YYV1LZ
         FtxfJIKf/118nIzr8CQhX6+oAGbz/WrVzwHlKrx0y1MIAMJ3Exv5hy+zV+uzwX6rykq4
         fK/koGO0+yd8iqwZnaz4fnWFDWk+gRD9eU5qXNaiAUaBu09y1GOS1PT4CmAFHXkIHFF0
         R6N0TCPLJDSgKZyiBbT1+/7cG5aS06sW5CRMkoWGsFvGLikIaGlCTlsG3VfU8KnNmCkH
         ti2A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUPeTO2V1JvpwvkeK+K78NKa7l/5o+QZqYcPRIwYQA4D1x6RFXJ
	f9Hc8dwpF+/S0hlwpq3XvFZrD552I97rssxT3mQKKbs8a0yITW5Cbwu+oZA+59Y7OTCY6xGTq+8
	WqEo+hTR6K8Ns9mJ+0CNuFD3/HQPLqHiHNaPLqR7e21FlQVWug8Jan8t9IrFkeYU=
X-Received: by 2002:a17:906:2501:: with SMTP id i1mr12642273ejb.76.1553501095772;
        Mon, 25 Mar 2019 01:04:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVsmkBejLwjJH8JsngwbERau7Vcd/+k9xu9EJixNtxtUzUeg01oAGu6Yf1CZgsa7de3FRm
X-Received: by 2002:a17:906:2501:: with SMTP id i1mr12642245ejb.76.1553501094999;
        Mon, 25 Mar 2019 01:04:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553501094; cv=none;
        d=google.com; s=arc-20160816;
        b=aTR2LP45xlFNc1o7/zVuM86yYWcxOiEkHkWax1WhB/0Dfybtm25hxJjZnSNf+KRP1l
         dzO6YcisjwY8UK5Np7l05eQZqTublInYf6L4lnmK46Rzo1zOrUnGDXahYLeTzCbaspYC
         VzJURR3nhd32tBYDaZjaxvquptccBH8Bxv+FjtJyVXnqDT1ZPhUQV0UKqhCwFZMDurZv
         zSrQwt471g15s5VGrDEcuoXgAIFa5zN8OQlDa7tn/IHUpqArtEb4SUmYJQActx1u8aaS
         kQpi0IB3ItetKzUBU2KAZI5MpAQ5yK6Kur/Tj96hABDDLq8GFoQK04Xy+vzfo9IpVbF6
         2OTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HcuHH9ogBba5nL2wpRNLXpT3U4lA9RM7SAO8tgMfU24=;
        b=YIWxd8Kb+tTgjYi2HAnPP+JOjDSDm0BVNZzenBawsZeG38l99GVyMXF3oBnuzM654y
         AwltaeSVYhAr/ork0YYqzVTlr2EdHW37IF7Lx/jMfiLnOKGWK3ftyq84CWo6FsLpPkk7
         iVxIaLPDjQdf0HNZ/1Z3M/6hcYM1MTf+lMualOOY6Xc+CkYDzw5B0iIcf7fBgGMYftvL
         dxXeL5qOQgHQxLKc5oO6XfyEvHPct1XURv+OMToKeEto+Yqxp40zUyfZvfLGa1ee+S9q
         KL8wf9BXWVWOh/EurZiqGUsnZBYc6Z8pKB2nby9z20auu4aZFjtGX+0g141U4OmOu7D1
         YI2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l40si294180edc.343.2019.03.25.01.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 01:04:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 61CF3AE7F;
	Mon, 25 Mar 2019 08:04:54 +0000 (UTC)
Date: Mon, 25 Mar 2019 09:04:53 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	akpm@linux-foundation.org, dan.j.williams@intel.com,
	pavel.tatashin@microsoft.com, jglisse@redhat.com,
	Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com,
	linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>
Subject: Re: [PATCH v2 4/5] mm, memory-hotplug: Rework
 unregister_mem_sect_under_nodes
Message-ID: <20190325080453.GB9924@dhcp22.suse.cz>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-5-osalvador@suse.de>
 <45d6b6ed-ae84-f2d5-0d57-dc2e28938ce0@arm.com>
 <20190325074027.vhybenecc6hk7kxs@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190325074027.vhybenecc6hk7kxs@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 25-03-19 08:40:32, Oscar Salvador wrote:
> On Sun, Mar 24, 2019 at 12:18:26PM +0530, Anshuman Khandual wrote:
> > Hello Oscar,
> 
> Hi Anshuman,
> 
> > Passing down node ID till unregister_mem_sect_under_nodes() solves the problem of
> > querying struct page for nid but the current code assumes that the pfn range for
> > any given memory section can have different node IDs. Hence it scans over the
> > section and try to remove all possible node <---> memory block sysfs links.
> > 
> > I am just wondering is that assumption even correct ? Can we really have a memory
> > section which belongs to different nodes ? Is that even possible.
> 
> Yes, current code assumes that, but looking at when we init sections at boot
> stage, it seems like a 1:1 map to me.
> 
> E.g, in memory_present(), we do encode the nid in section's section_mem_map
> field to use that later on in sparse_init(), and get the node we should allocate
> the data structures from.
> 
> And in memory_present() itself, in case we do not use page's flags field,
> we end up using the section_to_node_table[] table, which is clearly a 1:1 map.
> 
> So, I might be wrong here, but I think that we do not really have nodes mixed
> in a section.

No, unfortunately two nodes might share the same section indeed. Have a
look at 4aa9fc2a435abe95a1e8d7f8c7b3d6356514b37a

-- 
Michal Hocko
SUSE Labs

