Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E64A2C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:22:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3DC92064A
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:22:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3DC92064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 402D16B0008; Thu, 18 Apr 2019 14:22:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B0D86B000C; Thu, 18 Apr 2019 14:22:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27C026B000D; Thu, 18 Apr 2019 14:22:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF9A96B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:22:58 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f67so1882096pfh.9
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:22:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xIusIxkcx3B+oA9NDkJkzuuAi7XFBLAModjhhRwRZvE=;
        b=N0Mkpa8MBxKcziog8F406IHIEM/56tYfEO7GS2g1DdD0GwH9iFOsCwtXHkQ8mFrOxA
         mhjPCN5vRy0c/toq22A0rlnc/Wjn6oTe0sBmtokmvL3l/EzcCxrQ6fiqjeN3qW+Opmwx
         mpx3eUxYGN4ORXR9KcdXbqhSIBgVKJRB2CBIudfw8It08O0TZxg602UJnjHOoRa2Wjjt
         aokqVSDHgFvX9UYtdnImXLpBnSVcbtgg1eLMti2fIBDKAy0aXE5qTDPw4rUftmZaIAzW
         90htCSa46X/Rq3bkNtg4ulu9o/ULI1EuTpZs2FN7UKvkcc4aa1BEWJCLt6Wb8QgSB8LO
         JQmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWMgGhoUpzyf0WCMz6lwl/SZx4V4cL99nh+FC3+YJjVBXHeoTjO
	xZQLti9KEIgx8IAbKdU+G/5VnS/S/84hsLldrmyOkopKOLk77c1jqgOUQQR4MloCSMugpj4U/sb
	Wu/JH2sGczNPkgRSq+eRkVb6+wtk6IyeOdi8z/Y41y4YBZt2fiKYUvZv3orY1g78+2g==
X-Received: by 2002:a63:2c09:: with SMTP id s9mr86287668pgs.411.1555611778546;
        Thu, 18 Apr 2019 11:22:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfuE95H/twDmpEvPAIGnLu97uiECben+RdK+Qp1sDFuap00d/ARD4O2c+m8jSORYWGGL3L
X-Received: by 2002:a63:2c09:: with SMTP id s9mr86287607pgs.411.1555611777798;
        Thu, 18 Apr 2019 11:22:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555611777; cv=none;
        d=google.com; s=arc-20160816;
        b=oMIzELrDRHYIGmd7099Zz0cvYUVGHnmxUg2WSwvWDSKTF5rR8Hyav84BF82QH+UXzJ
         gCQDYjfDTlVl/9Pa7mkleWmPSvb5LV8ygsngmd0tQelA+w5T/KCHNwZLzobhCw8IBZip
         lkGUaHs+NxGrEROUtaXa4Rf6aTBNhxZjXZJF1qFIlP6LqsOs4TjofW2TRDMM2qugX5iQ
         62oEjjllgRQCtlF0yi3PGJTORZPfPpG9bF88I1RV9tWoCxuh3Wh2XH6UG2qdDb5m5Oq+
         7KiOXw3BksN09o4CRAGc1SD2KekBebC+ccO8Hgb0MxTsJkrcRGWqWLbInJ30PIzViJJ3
         prAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xIusIxkcx3B+oA9NDkJkzuuAi7XFBLAModjhhRwRZvE=;
        b=F2yC5cx/cPzCUoOSZZOJxXNuxJCV2O6uWd5hLvrkQIklbna40SOwLHBviEBhPiATcH
         Ja8GIUPztE528SQ5CbQVmbs1Oj2tmeb/EsN381e0f6EqLb1DPQUt7BKRb8kZmJRQyxJL
         7GRGZtfJMmC7jtYfIMmSV2SmYYh1ztamMubW7NNyKG9bc7lOF7WZLNzu/mtT2ggHH8EC
         rUmwtvo9suntjQ8DQRvCL130bm5+60J9HkaZd1lFT186pogcYkc6GxfHgXTDnn/hSe5k
         4Fq3xWr8JMx0rHdizTPaT2JNcsLUICQZtbNXPYWLZODnzKM2ozRYG2yPMh3GRPYHLeEw
         0GDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g69si2591488pgc.408.2019.04.18.11.22.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 11:22:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Apr 2019 11:22:57 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,367,1549958400"; 
   d="scan'208";a="144017502"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga007.fm.intel.com with ESMTP; 18 Apr 2019 11:22:56 -0700
Date: Thu, 18 Apr 2019 12:16:43 -0600
From: Keith Busch <keith.busch@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Yang Shi <yang.shi@linux.alibaba.com>,
	mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
	akpm@linux-foundation.org, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190418181643.GB7659@localhost.localdomain>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <20190417092318.GG655@dhcp22.suse.cz>
 <5c2d37e1-c7f6-5b7b-4f8e-a34e981b841e@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5c2d37e1-c7f6-5b7b-4f8e-a34e981b841e@intel.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 10:13:44AM -0700, Dave Hansen wrote:
> On 4/17/19 2:23 AM, Michal Hocko wrote:
> > yes. This could be achieved by GFP_NOWAIT opportunistic allocation for
> > the migration target. That should prevent from loops or artificial nodes
> > exhausting quite naturaly AFAICS. Maybe we will need some tricks to
> > raise the watermark but I am not convinced something like that is really
> > necessary.
> 
> I don't think GFP_NOWAIT alone is good enough.
> 
> Let's say we have a system full of clean page cache and only two nodes:
> 0 and 1.  GFP_NOWAIT will eventually kick off kswapd on both nodes.
> Each kswapd will be migrating pages to the *other* node since each is in
> the other's fallback path.
> 
> I think what you're saying is that, eventually, the kswapds will see
> allocation failures and stop migrating, providing hysteresis.  This is
> probably true.
> 
> But, I'm more concerned about that window where the kswapds are throwing
> pages at each other because they're effectively just wasting resources
> in this window.  I guess we should figure our how large this window is
> and how fast (or if) the dampening occurs in practice.

I'm still refining tests to help answer this and have some preliminary
data. My test rig has CPU + memory Node 0, memory-only Node 1, and a
fast swap device. The test has an application strict mbind more than
the total memory to node 0, and forever writes random cachelines from
per-cpu threads.

I'm testing two memory pressure policies:

  Node 0 can migrate to Node 1, no cycles
  Node 0 and Node 1 migrate with each other (0 -> 1 -> 0 cycles)

After the initial ramp up time, the second policy is ~7-10% slower than
no cycles. There doesn't appear to be a temporary window dealing with
bouncing pages: it's just a slower overall steady state. Looks like when
migration fails and falls back to swap, the newly freed pages occasionaly
get sniped by the other node, keeping the pressure up.

