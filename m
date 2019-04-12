Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6BF9C282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 08:47:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92FE4218FD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 08:47:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92FE4218FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 735A56B000C; Fri, 12 Apr 2019 04:47:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BE3A6B0010; Fri, 12 Apr 2019 04:47:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 585F96B0266; Fri, 12 Apr 2019 04:47:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 19EF96B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 04:47:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s6so4536183edr.21
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 01:47:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QeacHHO6pSVIiOKGtWInU8tLD8Z+aqfJEnWSEGwai1c=;
        b=cJQnFisAhchnrfQVJbVenYhkb0u3+U7a06pq0C7hqttVR/f+oFUE7isB+Dng3OsPrH
         ykaOUAwNotgWmX1C3tMkXwZmAuw4eshI6c5p7ZJFY7XWen66u+WkRsqpH4qjqImtfh1C
         wB5auVbdoZjInm+CwuqZg7eJ//oNSMksgo7lwLMUZyeDRP8v223unKnhQ/Jt+WtW+XFh
         uZnFd0jD4PYzWWE9MzxDy4gtwsJowyhaIkyVns99ig1p0sdeuWCbwb3LtvwK79QhGTsC
         7alI/P9dc/ldUUKJ2ldzhHpvllpLSbi/AC/bDZLgAdIyOl2sAvfpRKyG+ns/GyesNBLN
         Kn1A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUvIoFgfpW882pXMJvDvrznDTGoKkNOn8gSovalRyMNaZXSMUj3
	5+yKPjualsLztTPpTHbz58TJ6bhIJ6ASLpw9k/XveRMtVyRYQff5w7F4LWAoxGtAfwkuUlYLo12
	q8wWtns8Lx5yl95MkxgIbS9H2GNmgWkQcgrPlcCNGH2AbwSZCRFzU8KJ5W/jRXyE=
X-Received: by 2002:aa7:da51:: with SMTP id w17mr34460916eds.71.1555058825546;
        Fri, 12 Apr 2019 01:47:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfaVurFnakiHO04kswSR0oIRtf0D4Q8r9XHP+NOzOX04EgWnWN3JFcG/tF5+H6cpDe1pmR
X-Received: by 2002:aa7:da51:: with SMTP id w17mr34460853eds.71.1555058824379;
        Fri, 12 Apr 2019 01:47:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555058824; cv=none;
        d=google.com; s=arc-20160816;
        b=wq1jgelRlLo/ItbX+nizg/Z7bW1WpaYa3ZLgmTlhGdv/Ymdu0VJikPdw1l01ZhOMRB
         FWwh8mYn3wCeLp8lhX9laIgqTblkBLNWd9NpEgaPZS2a8PkDHNe4oX/mNaU45ZQkijPs
         5H0doJw9CDLZ8Lpgt4u1IEf6WuG9ommSDy6EIR2INLBWJYJOMNKURzrRcOD7lPacVws3
         Yqo/8rhMkeryb5WJXEQWJ7xDQtdqr0zTYIlSIVe7VuIyciz+1rB+cS4nwycfvfa8czhf
         1LsRQcuNgjUTpu++WSEVgBzWsQcXoaaIolGKeL9NgKzz/OIGFe8CM2pthdTg1F5+CL3A
         cklw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QeacHHO6pSVIiOKGtWInU8tLD8Z+aqfJEnWSEGwai1c=;
        b=XP2g/6rk3BU+99qwBs4+F+Q8JodrNFRqV/eq2wDF4UUxEMDYqedCtoKWgas2r3ApIl
         fGDwLsGf6VL+VKAdUoKTbo8S6P5tBluXHryV2B2AcgFwsYQs9R3XcxsXbX+cBfkciLzM
         9bu1BvdWfaOoXhVsFysrxnYe15juTsj2GhHLDm/0KYV3IC1Vl2ngRqTf0Ys7D6bT/Zmq
         MsryFeVXfvku8jRBrYZzoqL5Y6e2UD7rHj3EgcIg9K7INVQSQp0EDSnvEa+ODLQIYewl
         XgjQp3I5xq44do+DLskMUp3m6woffWM/HCgxj6mCOCMbWA2Wavj0fYaz2bIcEC4W009X
         r/zQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si4276320eja.89.2019.04.12.01.47.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 01:47:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9CBE5ACBA;
	Fri, 12 Apr 2019 08:47:03 +0000 (UTC)
Date: Fri, 12 Apr 2019 10:47:02 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
	akpm@linux-foundation.org, dave.hansen@intel.com,
	keith.busch@intel.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190412084702.GD13373@dhcp22.suse.cz>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 11:56:50, Yang Shi wrote:
[...]
> Design
> ======
> Basically, the approach is aimed to spread data from DRAM (closest to local
> CPU) down further to PMEM and disk (typically assume the lower tier storage
> is slower, larger and cheaper than the upper tier) by their hotness.  The
> patchset tries to achieve this goal by doing memory promotion/demotion via
> NUMA balancing and memory reclaim as what the below diagram shows:
> 
>     DRAM <--> PMEM <--> Disk
>       ^                   ^
>       |-------------------|
>                swap
> 
> When DRAM has memory pressure, demote pages to PMEM via page reclaim path.
> Then NUMA balancing will promote pages to DRAM as long as the page is referenced
> again.  The memory pressure on PMEM node would push the inactive pages of PMEM 
> to disk via swap.
> 
> The promotion/demotion happens only between "primary" nodes (the nodes have
> both CPU and memory) and PMEM nodes.  No promotion/demotion between PMEM nodes
> and promotion from DRAM to PMEM and demotion from PMEM to DRAM.
> 
> The HMAT is effectively going to enforce "cpu-less" nodes for any memory range
> that has differentiated performance from the conventional memory pool, or
> differentiated performance for a specific initiator, per Dan Williams.  So,
> assuming PMEM nodes are cpuless nodes sounds reasonable.
> 
> However, cpuless nodes might be not PMEM nodes.  But, actually, memory
> promotion/demotion doesn't care what kind of memory will be the target nodes,
> it could be DRAM, PMEM or something else, as long as they are the second tier
> memory (slower, larger and cheaper than regular DRAM), otherwise it sounds
> pointless to do such demotion.
> 
> Defined "N_CPU_MEM" nodemask for the nodes which have both CPU and memory in
> order to distinguish with cpuless nodes (memory only, i.e. PMEM nodes) and
> memoryless nodes (some architectures, i.e. Power, may have memoryless nodes).
> Typically, memory allocation would happen on such nodes by default unless
> cpuless nodes are specified explicitly, cpuless nodes would be just fallback
> nodes, so they are also as known as "primary" nodes in this patchset.  With
> two tier memory system (i.e. DRAM + PMEM), this sounds good enough to
> demonstrate the promotion/demotion approach for now, and this looks more
> architecture-independent.  But it may be better to construct such node mask
> by reading hardware information (i.e. HMAT), particularly for more complex
> memory hierarchy.

I still believe you are overcomplicating this without a strong reason.
Why cannot we start simple and build from there? In other words I do not
think we really need anything like N_CPU_MEM at all.

I would expect that the very first attempt wouldn't do much more than
migrate to-be-reclaimed pages (without an explicit binding) with a
very optimistic allocation strategy (effectivelly GFP_NOWAIT) and if
that fails then simply give up. All that hooked essentially to the
node_reclaim path with a new node_reclaim mode so that the behavior
would be opt-in. This should be the most simplistic way to start AFAICS
and something people can play with without risking regressions.

Once we see how that behaves in the real world and what kind of corner
case user are able to trigger then we can build on top. E.g. do we want
to migrate from cpuless nodes as well? I am not really sure TBH. On one
hand why not if other nodes are free to hold that memory? Swap out is
more expensive. Anyway this is kind of decision which would rather be
shaped on an existing experience rather than ad-hoc decistion right now.

I would also not touch the numa balancing logic at this stage and rather
see how the current implementation behaves.
-- 
Michal Hocko
SUSE Labs

