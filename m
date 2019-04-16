Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 890C0C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 07:47:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 516A62086A
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 07:47:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 516A62086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C30436B0003; Tue, 16 Apr 2019 03:47:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDE4D6B0006; Tue, 16 Apr 2019 03:47:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACCA36B0007; Tue, 16 Apr 2019 03:47:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59B166B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 03:47:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o8so9730337edh.12
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 00:47:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=6DI/tZqtW3uimUoOXNYYEoSTaNBApBDa658DR1lUb6E=;
        b=I3pIUDS1G8yN3T0yRjH55KLfkECIODl4SfYs7b/r2tGRml9QuH5w1Ahqy//RNIdA8Z
         JCqTFiE6ch8Hv46hNWKueDXAvX5JYuvWogywrnrBPUEFEOnCLLyovHILNHZ4csdrRIX+
         qLyOF7ReWK9B2/CUlkK8zKdpxDaq81txbze+250OcEbOwg2DoyfAHCEDNRhipesUgNE6
         7yrbRSwpVxPTgnjs2JYP8V19+fV2DG17ydg0KrNn8RRon3lM/aptvfCw/Rsx557mqq0v
         6JivK6IjIGPQMDaeayHbquAGYW3L9RYlU0EYFju4Eb2UbY5FmGPqOi5CPX58YX2EE8Zv
         n+Jg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXvElbPSGn8J+EqVKaOFP+G9qpXXL9F8gzNCEAaHdtyGczWTjaW
	pdOpUa/2Nvg70PjBCCOmEJOmx/q+apVIrxOFCu57JEemviMRh3PP60TsRCsmObEzPu2s+wsSCF/
	OLNulX7nNJL2rGgkXYktWu2WSAabgiose9sdIBdw9WMRtEY0TI/eUsS5ivD0Diw4=
X-Received: by 2002:a17:906:1343:: with SMTP id x3mr39053770ejb.218.1555400839848;
        Tue, 16 Apr 2019 00:47:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwks18krnDpHC03qLzl1sCdVX4P84VBGcnlq8WVbJbM4ODvwJvIdaZn7gT2M8ux9PG1nE41
X-Received: by 2002:a17:906:1343:: with SMTP id x3mr39053724ejb.218.1555400838800;
        Tue, 16 Apr 2019 00:47:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555400838; cv=none;
        d=google.com; s=arc-20160816;
        b=hHlpr4JQfq5qo7orZFkSNZ8OZHJ1/4h+YJEdAf3O7ORblvHM5K6nhfeUAOrToCr5MO
         +fIBaxJy0RFjPDATjAZSOqX4jH3FWF/9Ouj8QuhuX7elLgELkTNxUJp7coLcFzfjnvQl
         ywM2wp/dg1OCltS3Hdtvxjm9kww0n+XuADhjm2mazfpDThvBQ2uodVs7uruNkBdhUF/K
         e02PkFeepmZckZyZeNvQyS6/ML++G6LyGDtieAMqykNci14ywcOxp0hoJ/eTTnooaCSx
         3fvsFz1GPqZ5nUaFLuX6CzIZR8vWfvFRhMZqw//PArkCjnsjCkOkHQbD/zvzIVDpVLQO
         aj5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=6DI/tZqtW3uimUoOXNYYEoSTaNBApBDa658DR1lUb6E=;
        b=yueKpnEnO083UJE9wth/RQbpf6yb+j7t0rn9tV0+9JRvIYEj9/QzTwlk3l9kx7Qqhl
         2m1sr81FtK/FRpxSHEmdx1Ro1Y1E0BSkQYKoGWEz4PWixz4nBcaepPuBlf4mnhJMUXyL
         VZsPV8it+l6rAs/qj52gC4JjOvD7OjBdSoG0cr2lC2wwojacdwVjpwbJPmtSEzzXUIyk
         AK6mnWD5ltx1eOOGayVrF1HFezm8sJL/0tpqznlmN0/1UJsmlWVGsQ40UAJscoD3g8jC
         O1Um8qTFQAqhdde+UuN4r+USB0AVeNwhNu1mx/u+BmSAQRslZdJoFxVh9W6+HozaPHn8
         ruGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w47si1310395edw.19.2019.04.16.00.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 00:47:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6F696AEEA;
	Tue, 16 Apr 2019 07:47:17 +0000 (UTC)
Date: Tue, 16 Apr 2019 09:47:14 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
	akpm@linux-foundation.org, dave.hansen@intel.com,
	keith.busch@intel.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190416074714.GD11561@dhcp22.suse.cz>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 15-04-19 17:09:07, Yang Shi wrote:
> 
> 
> On 4/12/19 1:47 AM, Michal Hocko wrote:
> > On Thu 11-04-19 11:56:50, Yang Shi wrote:
> > [...]
> > > Design
> > > ======
> > > Basically, the approach is aimed to spread data from DRAM (closest to local
> > > CPU) down further to PMEM and disk (typically assume the lower tier storage
> > > is slower, larger and cheaper than the upper tier) by their hotness.  The
> > > patchset tries to achieve this goal by doing memory promotion/demotion via
> > > NUMA balancing and memory reclaim as what the below diagram shows:
> > > 
> > >      DRAM <--> PMEM <--> Disk
> > >        ^                   ^
> > >        |-------------------|
> > >                 swap
> > > 
> > > When DRAM has memory pressure, demote pages to PMEM via page reclaim path.
> > > Then NUMA balancing will promote pages to DRAM as long as the page is referenced
> > > again.  The memory pressure on PMEM node would push the inactive pages of PMEM
> > > to disk via swap.
> > > 
> > > The promotion/demotion happens only between "primary" nodes (the nodes have
> > > both CPU and memory) and PMEM nodes.  No promotion/demotion between PMEM nodes
> > > and promotion from DRAM to PMEM and demotion from PMEM to DRAM.
> > > 
> > > The HMAT is effectively going to enforce "cpu-less" nodes for any memory range
> > > that has differentiated performance from the conventional memory pool, or
> > > differentiated performance for a specific initiator, per Dan Williams.  So,
> > > assuming PMEM nodes are cpuless nodes sounds reasonable.
> > > 
> > > However, cpuless nodes might be not PMEM nodes.  But, actually, memory
> > > promotion/demotion doesn't care what kind of memory will be the target nodes,
> > > it could be DRAM, PMEM or something else, as long as they are the second tier
> > > memory (slower, larger and cheaper than regular DRAM), otherwise it sounds
> > > pointless to do such demotion.
> > > 
> > > Defined "N_CPU_MEM" nodemask for the nodes which have both CPU and memory in
> > > order to distinguish with cpuless nodes (memory only, i.e. PMEM nodes) and
> > > memoryless nodes (some architectures, i.e. Power, may have memoryless nodes).
> > > Typically, memory allocation would happen on such nodes by default unless
> > > cpuless nodes are specified explicitly, cpuless nodes would be just fallback
> > > nodes, so they are also as known as "primary" nodes in this patchset.  With
> > > two tier memory system (i.e. DRAM + PMEM), this sounds good enough to
> > > demonstrate the promotion/demotion approach for now, and this looks more
> > > architecture-independent.  But it may be better to construct such node mask
> > > by reading hardware information (i.e. HMAT), particularly for more complex
> > > memory hierarchy.
> > I still believe you are overcomplicating this without a strong reason.
> > Why cannot we start simple and build from there? In other words I do not
> > think we really need anything like N_CPU_MEM at all.
> 
> In this patchset N_CPU_MEM is used to tell us what nodes are cpuless nodes.
> They would be the preferred demotion target.  Of course, we could rely on
> firmware to just demote to the next best node, but it may be a "preferred"
> node, if so I don't see too much benefit achieved by demotion. Am I missing
> anything?

Why cannot we simply demote in the proximity order? Why do you make
cpuless nodes so special? If other close nodes are vacant then just use
them.
 
> > I would expect that the very first attempt wouldn't do much more than
> > migrate to-be-reclaimed pages (without an explicit binding) with a
> 
> Do you mean respect mempolicy or cpuset when doing demotion? I was wondering
> this, but I didn't do so in the current implementation since it may need
> walk the rmap to retrieve the mempolicy in the reclaim path. Is there any
> easier way to do so?

You definitely have to follow policy. You cannot demote to a node which
is outside of the cpuset/mempolicy because you are breaking contract
expected by the userspace. That implies doing a rmap walk.

> > I would also not touch the numa balancing logic at this stage and rather
> > see how the current implementation behaves.
> 
> I agree we would prefer start from something simpler and see how it works.
> 
> The "twice access" optimization is aimed to reduce the PMEM bandwidth burden
> since the bandwidth of PMEM is scarce resource. I did compare "twice access"
> to "no twice access", it does save a lot bandwidth for some once-off access
> pattern. For example, when running stress test with mmtest's
> usemem-stress-numa-compact. The kernel would promote ~600,000 pages with
> "twice access" in 4 hours, but it would promote ~80,000,000 pages without
> "twice access".

I pressume this is a result of a synthetic workload, right? Or do you
have any numbers for a real life usecase?
-- 
Michal Hocko
SUSE Labs

