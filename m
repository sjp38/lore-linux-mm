Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B07C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 172202173C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:51:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 172202173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C9F26B0005; Wed, 17 Apr 2019 13:51:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 878816B0006; Wed, 17 Apr 2019 13:51:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 768496B0007; Wed, 17 Apr 2019 13:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 252766B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:51:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z29so10332006edb.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:51:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PMkpejDmoPrVdxh9p9G7C5NFiLeig6LtXYzzCSTz5As=;
        b=c7SA2U06F5GXevKKmS4L8GVNo+PJVT3z1na0xeWGYV0MnY21q69tGSKk77EYtCc4Eg
         QPR6jCCwf3wXI6J6vsEtZHXdh2KQOIl0D3fk+gUc0nC574H312L3cJFJMXdMRB95Cohh
         EKKA4oCgW5BASniIQkNoUCAaZdC/Mv+HxWbMybWAO1mhQ0+ySsPq2sfJdfpuRc8M8DLv
         yt36upFjekLeVmSQ23lqkxteqCXq3pvB9ZLqdfYKcMIAh0ZFeu3I0Gso3AoNIXrxVLaT
         gYZFElq6R7BDtizQWW70f/9EnIc9CWGRYSxb4Iz8LvA7N8FAPuQ3puvOEVBjmepX58HC
         aZFw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWW6LQxFTguAIxwG5179cFJtVbQf0b11hkbPyVHY0TWIjIZuxxO
	oOCXJlBv5Z1xzSSCyq+pI0lcaooOmnsYC1kQNIl48XCrmwxYDVflBV64RHcIx5YuRuRGCyFjnfR
	mVNCPIC+3BPGg6eVjQl+6sCie0xiqprzzPmc/fMQ1XsGZ3XUTnV1/o+WUjt1x2gU=
X-Received: by 2002:a50:dece:: with SMTP id d14mr14628537edl.97.1555523514588;
        Wed, 17 Apr 2019 10:51:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFG9Zi7rF/KETqHkj5yZoEikZULQqYtldVDmtFCQgCRDIl7WQd3226/kgF0HR47GdQ3UUu
X-Received: by 2002:a50:dece:: with SMTP id d14mr14628493edl.97.1555523513521;
        Wed, 17 Apr 2019 10:51:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555523513; cv=none;
        d=google.com; s=arc-20160816;
        b=iw5ZpFX2By0d4AQDemVtNHmMCl4B5MHKFSqAr9zwd5ILD09ZgHIXf8NrgNYVJIwnJe
         REFtnUG4/FHvKAEDKf9KRhgQ9hLpXGu1aZVr4Ox2QOwViLegpuE2NqtJa2bLPnX4y8JV
         ADAwX1li5uCD+z96AGLl5wZ3SL3tALbqWzhw2Rb3Jobc8xTjvHifBZa0c7qYHvc6sZMW
         Qh5qH/CZuuqabQCHYQsgomKwmD5ZSdiLEO5FgpTb9M9lEmcPZsMZC2NxSE3MNNthSdcE
         eGkeGa094RCUWXePqXMxcFJFcEmMVJ4JXGggFZGa3BicjwIeRgjdU94Zr4bq/51Nj1hq
         xGJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PMkpejDmoPrVdxh9p9G7C5NFiLeig6LtXYzzCSTz5As=;
        b=gLTZpTF4zMVMr03Kyvz1vypsUazmYvfXFWTx0ilOYso9jl+mDCTw+oBr05DXu6umPm
         Xs/GaZ5kwbD2KX14+FZl8FT1d4BqNcjM9e0LEY8oIDwJILxK/WizNMP4GsMrghOYHQz8
         G0J1cBvmkZttUnO3sRsvKwdsfPb4j+156OTAzjdk7AAOvveOiKN9Mul5KGBunHg4NXI/
         axJZE4wPbUaFyAYXuOossilO9xxf9hlX+TXNfttPVjtx6dGWK06ii7G7Qu9styGS4mug
         upkVMrhJduokj6EbFBGAtBxb8L6kT1RVm61DmbZI+RLa8s7nMl0LM4IeYwc2UtBQz+JA
         82Aw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id os14si4011597ejb.155.2019.04.17.10.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 10:51:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BF352AD3B;
	Wed, 17 Apr 2019 17:51:52 +0000 (UTC)
Date: Wed, 17 Apr 2019 19:51:51 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Keith Busch <keith.busch@intel.com>,
	Dave Hansen <dave.hansen@intel.com>, mgorman@techsingularity.net,
	riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
	dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
	ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190417175151.GB9523@dhcp22.suse.cz>
References: <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <20190417092318.GG655@dhcp22.suse.cz>
 <20190417152345.GB4786@localhost.localdomain>
 <20190417153923.GO5878@dhcp22.suse.cz>
 <20190417153739.GD4786@localhost.localdomain>
 <20190417163911.GA9523@dhcp22.suse.cz>
 <fcb30853-8039-8154-7ae0-706930642576@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fcb30853-8039-8154-7ae0-706930642576@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 10:26:05, Yang Shi wrote:
> 
> 
> On 4/17/19 9:39 AM, Michal Hocko wrote:
> > On Wed 17-04-19 09:37:39, Keith Busch wrote:
> > > On Wed, Apr 17, 2019 at 05:39:23PM +0200, Michal Hocko wrote:
> > > > On Wed 17-04-19 09:23:46, Keith Busch wrote:
> > > > > On Wed, Apr 17, 2019 at 11:23:18AM +0200, Michal Hocko wrote:
> > > > > > On Tue 16-04-19 14:22:33, Dave Hansen wrote:
> > > > > > > Keith Busch had a set of patches to let you specify the demotion order
> > > > > > > via sysfs for fun.  The rules we came up with were:
> > > > > > I am not a fan of any sysfs "fun"
> > > > > I'm hung up on the user facing interface, but there should be some way a
> > > > > user decides if a memory node is or is not a migrate target, right?
> > > > Why? Or to put it differently, why do we have to start with a user
> > > > interface at this stage when we actually barely have any real usecases
> > > > out there?
> > > The use case is an alternative to swap, right? The user has to decide
> > > which storage is the swap target, so operating in the same spirit.
> > I do not follow. If you use rebalancing you can still deplete the memory
> > and end up in a swap storage. If you want to reclaim/swap rather than
> > rebalance then you do not enable rebalancing (by node_reclaim or similar
> > mechanism).
> 
> I'm a little bit confused. Do you mean just do *not* do reclaim/swap in
> rebalancing mode? If rebalancing is on, then node_reclaim just move the
> pages around nodes, then kswapd or direct reclaim would take care of swap?

Yes, that was the idea I wanted to get through. Sorry if that was not
really clear.

> If so the node reclaim on PMEM node may rebalance the pages to DRAM node?
> Should this be allowed?

Why it shouldn't? If there are other vacant Nodes to absorb that memory
then why not use it?

> I think both I and Keith was supposed to treat PMEM as a tier in the reclaim
> hierarchy. The reclaim should push inactive pages down to PMEM, then swap.
> So, PMEM is kind of a "terminal" node. So, he introduced sysfs defined
> target node, I introduced N_CPU_MEM.

I understand that. And I am trying to figure out whether we really have
to tream PMEM specially here. Why is it any better than a generic NUMA
rebalancing code that could be used for many other usecases which are
not PMEM specific. If you present PMEM as a regular memory then also use
it as a normal memory.
-- 
Michal Hocko
SUSE Labs

