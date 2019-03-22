Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35517C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 18:05:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C68C7213F2
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 18:05:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C68C7213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DD526B0005; Fri, 22 Mar 2019 14:05:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38BB46B0006; Fri, 22 Mar 2019 14:05:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27C626B0007; Fri, 22 Mar 2019 14:05:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CED076B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 14:05:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c40so24616eda.10
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:05:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lu1IzUvdhspX21BWZpSuXBGZNxCoFHg73rHXc7qb11o=;
        b=Ps1aabRalTPAbO5zuRk+NA4x6mRnipj+HevEnI7MW50mOidfgp990LLNszySkqS6eN
         l2ziHuBv9Mv/op7fRL7F5SXGYtjPriBiDRRlOZLHxepDUCjm6VvXyeUgjJK5moVnVc9Z
         EBIU/kjBM7okhp6NpvrGJAIAl1oQigTN2zZ9RgGeovUX3iS6ShgwqXvrEa8bLW22RdYI
         gbFP0kny+JgUrqdv1W4sTBawmrLKmyk04ONJAp81bY93voHkvieeLIdRek6vZJ6/En4j
         mqoO3Crk6b6ZxJBS75kPEFrYSm9MIfMPjfKHa+XFfU8tg7019cCUNYb3BKBztD5yHXdH
         Pclw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUOjIdvWDkK1cVcLH03D/2id3efgamun0CcHMQCUy90Id/jq5zC
	4YnAtvSS63TzLijWHSTC+cNoQvdtCvYQGuHYwfuv/oYRdYaY/LLjrXgPF/E/seJkGF57Fo5qB2T
	cEVGbxHOTMp+8xwv4SjWkNm6VtQ90TI9IPf+/vouPdotaW/TXTPTmEChqX9PDXEo=
X-Received: by 2002:aa7:cb57:: with SMTP id w23mr7237911edt.264.1553277940375;
        Fri, 22 Mar 2019 11:05:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzZiTDLq+aXFZ09ULetNwvSkExPbjkzPP2TSPM1K5i1jPCxjdi6nRjRXA+1ToSKy+ZfY1a
X-Received: by 2002:aa7:cb57:: with SMTP id w23mr7237858edt.264.1553277939184;
        Fri, 22 Mar 2019 11:05:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553277939; cv=none;
        d=google.com; s=arc-20160816;
        b=c0mxGukgueZNFJZo7zHZpIFS5s5Om/J3Mktzbgkxv91zMCYA+4/+VZqW8tvJFxNbpH
         hvHR8T3b5RFbujPWxHdm2dGoMG4jsP/0+1oqbnSlWkUuOak8+Q4zbFKE9s4/cVJOy85q
         CxLBYILWCN2CczHejP/bjgEOjE6+HMCDa7W+DztfJnotcsOdOXK7iRk2BrruLlC77lof
         mJm/gVmxA22r4ZeWUBahQrgplz4blTa+iKuJEDSO6y5sUEw+HDreBjG0DNbV800kFmOZ
         YzZa7UkICwVfkEdhNGKsqjV1KKUmHLE1LCMTHQZyymDLhYdEdkNdj8j7GaBB/LxvI9dp
         257w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lu1IzUvdhspX21BWZpSuXBGZNxCoFHg73rHXc7qb11o=;
        b=d1pXXFpzJtUJbX4KzqyrfEeHv1vKKhN9QcShzl/Nxuh/fgjPspl9Xwc+6XKLkqbcSj
         KY3bWHnZfAGRJi/kR7WjBAtdGgIBEowI3jcmVc4A0iRuDcMEJR3twfPFJ35vXQI3OGQG
         H1JHU84QIPiNqvaRYhHY/BcJhvpefiaXPv+E0Mysjy9Q2NKIllL4cSiiPR8kZPYQ2vsp
         yrxCV34RCL53BLQe7sxV0y1unjLg+oaYg8ACLtW0YMIdnAOd5VDF+Xy2PjJDRBS3HChK
         3Y12XfKPbwGNGP8UcWfWB5zBDm1WSjZ429O79RIInaXkm/DDTpYzVh5dlA7RKutqIyX0
         EdsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c3si3014830ejm.98.2019.03.22.11.05.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 11:05:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2F17FAEE3;
	Fri, 22 Mar 2019 18:05:38 +0000 (UTC)
Date: Fri, 22 Mar 2019 19:05:32 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org,
	linux-mm@kvack.org, linux-nvdimm@lists.01.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
Message-ID: <20190322180532.GM32418@dhcp22.suse.cz>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 22-03-19 09:57:54, Dan Williams wrote:
> Changes since v4 [1]:
> - Given v4 was from March of 2017 the bulk of the changes result from
>   rebasing the patch set from a v4.11-rc2 baseline to v5.1-rc1.
> 
> - A unit test is added to ndctl to exercise the creation and dax
>   mounting of multiple independent namespaces in a single 128M section.
> 
> [1]: https://lwn.net/Articles/717383/
> 
> ---
> 
> Quote patch7:
> 
> "The libnvdimm sub-system has suffered a series of hacks and broken
>  workarounds for the memory-hotplug implementation's awkward
>  section-aligned (128MB) granularity. For example the following backtrace
>  is emitted when attempting arch_add_memory() with physical address
>  ranges that intersect 'System RAM' (RAM) with 'Persistent Memory' (PMEM)
>  within a given section:
>  
>   WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
>   devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
>   [..]
>   Call Trace:
>     dump_stack+0x86/0xc3
>     __warn+0xcb/0xf0
>     warn_slowpath_fmt+0x5f/0x80
>     devm_memremap_pages+0x3b5/0x4c0
>     __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
>     pmem_attach_disk+0x19a/0x440 [nd_pmem]
>  
>  Recently it was discovered that the problem goes beyond RAM vs PMEM
>  collisions as some platform produce PMEM vs PMEM collisions within a
>  given section. The libnvdimm workaround for that case revealed that the
>  libnvdimm section-alignment-padding implementation has been broken for a
>  long while. A fix for that long-standing breakage introduces as many
>  problems as it solves as it would require a backward-incompatible change
>  to the namespace metadata interpretation. Instead of that dubious route
>  [2], address the root problem in the memory-hotplug implementation."
> 
> The approach is taken is to observe that each section already maintains
> an array of 'unsigned long' values to hold the pageblock_flags. A single
> additional 'unsigned long' is added to house a 'sub-section active'
> bitmask. Each bit tracks the mapped state of one sub-section's worth of
> capacity which is SECTION_SIZE / BITS_PER_LONG, or 2MB on x86-64.

So the hotplugable unit is pageblock now, right? Why is this
sufficient? What prevents new and creative HW to come up with
alignements that do not fit there? Do not get me wrong but the section
as a unit is deeply carved into the memory hotplug and removing all those
assumptions is a major undertaking and I would like to know that you are
not just shifting the problem to a smaller unit and a new/creative HW
will force us to go even more complicated.

What is the fundamental reason that pmem sections cannot be assigned
to a section aligned memory range? The physical address space is
quite large to impose 128MB sections IMHO. I thought this is merely a
configuration issue. How often this really happens and how often it is
unavoidable.

> The implication of allowing sections to be piecemeal mapped/unmapped is
> that the valid_section() helper is no longer authoritative to determine
> if a section is fully mapped. Instead pfn_valid() is updated to consult
> the section-active bitmask. Given that typical memory hotplug still has
> deep "section" dependencies the sub-section capability is limited to
> 'want_memblock=false' invocations of arch_add_memory(), effectively only
> devm_memremap_pages() users for now.

Does this mean that pfn_valid is more expensive now? How much? For any
pfn? Also what about the section life time? Who is removing section now?

I will probably have much more question, but it's friday and I am mostly
offline already. I would just like to hear much more about the new
design and resulting assumptions.
-- 
Michal Hocko
SUSE Labs

