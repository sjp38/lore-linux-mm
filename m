Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3EE8C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:10:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53FD62087C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:10:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53FD62087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C26966B000D; Wed, 27 Mar 2019 16:09:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BADCC6B000E; Wed, 27 Mar 2019 16:09:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4F696B0010; Wed, 27 Mar 2019 16:09:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 506526B000D
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 16:09:59 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id e6so6232683wrs.1
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:09:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BxdlZA20V+nvmp9SYsJwRytC0uJFbrzmx7O1ApfI0ek=;
        b=DuzJjsdjhUKdXW9qXYzC4kNFrjKwr7mtfAoOD8VgqdpdHv9gObve0QH8h1OEjZzNq9
         cRMPKTojjU4BLkBPJg2PF6Hmjg4VWQLiyNVRYCmHanEwFe6suJNNzj2GiyIpteP03MZS
         bOHdXm8nfdo2cxHKklSSJcLB9fA9gxtuPu5IhJt6/kSmXp1IgEZ29zKX1c51JX7g0/d+
         cIBuLlDWS/bjtd/ave3NWdue8YpWckFv2/pC6y/3N45ClHhJlszPBnfF59WNrYiYGFx9
         tBdgIx7WM/+Mk4rxNcn0ORk7/DMitWTDNKArHxrC68RrDAhYo91Rk6bBa4zCI/LWTcMj
         mCxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXSgmP7Gq6Giqb9/lEOFg0j2tyP1cmAhBjAgrp+DaTFGKyjP3vH
	/FhwZ6gANOdJlNEO8PFkNNsujlWO2/uWN2kRSceY5Fz7E0qeyDNYV1xGCxY0IscmHmAtPK4oOqp
	uGqKNChqBzX0vWII5gqKAWtVyPqicIsB3+zuEMPEJn3CCbHi843u8OcPDuZ0TwbA=
X-Received: by 2002:a05:600c:2294:: with SMTP id 20mr12856124wmf.56.1553717398747;
        Wed, 27 Mar 2019 13:09:58 -0700 (PDT)
X-Received: by 2002:a05:600c:2294:: with SMTP id 20mr12856090wmf.56.1553717397565;
        Wed, 27 Mar 2019 13:09:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553717397; cv=none;
        d=google.com; s=arc-20160816;
        b=BNyHNUfTK0Qf1f7ykqaoJzF4oRJPsBooHn878cKUhx2BMbxCwlAV4I6zCOcIGjCN6j
         qJDs+QpHlPZxYy9Eu44RVzVtbfhKgkQF5Zrvb5QestTJkn3HDy8zY/RAlDfYbuPOPaNq
         cF5cTwegXSkLah5oSUUMk1Bx6A4lnrfXMrxyjENLHvXyzg6btejr7xa70ZxzLN40pGOl
         8KJWo95W2vv03yfyyTV+vbPgcS2saZNFZJMZVVjwpdxxocQxkwplO2q0L6JCYgQPUdlA
         LVVmznBQdTrs4zjetN0hso996/o6VaWQHEvR5VNL5JD5HPn+xUu0SX4Pkg+UKaJ5pfcv
         tmLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BxdlZA20V+nvmp9SYsJwRytC0uJFbrzmx7O1ApfI0ek=;
        b=wM2VWTjoTr+24d21JAJN0rOJzJsCniubobSi/t4ovf6f2TbCWVuK3kerBt6m66hnUq
         oFdqETlnoEWEh9eYu13nPvQU2Ofy/2rWNuyZ04a03cW8WIvpPRwEFESGz2YnjjgaqlLP
         ZLrQrUjeF+71VHJSslBGdmJBArd4w7DEFuZckYvWLFn8kVewJL72rYlip5kb8C866fZD
         oVeN2MzAkKIKQQ4Dh+PkIH5UKzAgXFDXzcZZ1fCDXmyn3wI9uN3wHpRpgzwVM7tlpu3Z
         yGY5+wLkZJCpmXiBgsoyPhFAiVLjj+7/rxA6IA4cbmv6vZ+tES+QuNQPoTJjR8yTz/jC
         gDaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o8sor734287wmf.23.2019.03.27.13.09.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 13:09:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqyPIA2q4k2Xqf3l9eGLTWp7uk5RUzI1vR0hg5JFg9hwl3QocHsf9kX1F7RBMXysFcWsuTwneA==
X-Received: by 2002:a1c:4187:: with SMTP id o129mr9646587wma.57.1553717397215;
        Wed, 27 Mar 2019 13:09:57 -0700 (PDT)
Received: from localhost (ip-37-188-250-59.eurotel.cz. [37.188.250.59])
        by smtp.gmail.com with ESMTPSA id b8sm7577541wrr.64.2019.03.27.13.09.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Mar 2019 13:09:56 -0700 (PDT)
Date: Wed, 27 Mar 2019 21:09:54 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Rik van Riel <riel@surriel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
	"Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190327193918.GP11927@dhcp22.suse.cz>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz>
 <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz>
 <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
 <20190327090100.GD11927@dhcp22.suse.cz>
 <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
 <c3690a19-e2a6-7db7-b146-b08aa9b22854@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c3690a19-e2a6-7db7-b146-b08aa9b22854@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 27-03-19 11:59:28, Yang Shi wrote:
> 
> 
> On 3/27/19 10:34 AM, Dan Williams wrote:
> > On Wed, Mar 27, 2019 at 2:01 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > On Tue 26-03-19 19:58:56, Yang Shi wrote:
[...]
> > > > It is still NUMA, users still can see all the NUMA nodes.
> > > No, Linux NUMA implementation makes all numa nodes available by default
> > > and provides an API to opt-in for more fine tuning. What you are
> > > suggesting goes against that semantic and I am asking why. How is pmem
> > > NUMA node any different from any any other distant node in principle?
> > Agree. It's just another NUMA node and shouldn't be special cased.
> > Userspace policy can choose to avoid it, but typical node distance
> > preference should otherwise let the kernel fall back to it as
> > additional memory pressure relief for "near" memory.
> 
> In ideal case, yes, I agree. However, in real life world the performance is
> a concern. It is well-known that PMEM (not considering NVDIMM-F or HBM) has
> higher latency and lower bandwidth. We observed much higher latency on PMEM
> than DRAM with multi threads.

One rule of thumb is: Do not design user visible interfaces based on the
contemporary technology and its up/down sides. This will almost always
fire back.

Btw. if you keep arguing about performance without any numbers. Can you
present something specific?

> In real production environment we don't know what kind of applications would
> end up on PMEM (DRAM may be full, allocation fall back to PMEM) then have
> unexpected performance degradation. I understand to have mempolicy to choose
> to avoid it. But, there might be hundreds or thousands of applications
> running on the machine, it sounds not that feasible to me to have each
> single application set mempolicy to avoid it.

we have cpuset cgroup controller to help here.

> So, I think we still need a default allocation node mask. The default value
> may include all nodes or just DRAM nodes. But, they should be able to be
> override by user globally, not only per process basis.
> 
> Due to the performance disparity, currently our usecases treat PMEM as
> second tier memory for demoting cold page or binding to not memory access
> sensitive applications (this is the reason for inventing a new mempolicy)
> although it is a NUMA node.

If the performance sucks that badly then do not use the pmem as NUMA,
really. There are certainly other ways to export the pmem storage. Use
it as a fast swap storage. Or try to work on a swap caching mechanism
that still allows much faster access than a slow swap storage. But do
not try to pretend to abuse the NUMA interface while you are breaking
some of its long term established semantics.
-- 
Michal Hocko
SUSE Labs

