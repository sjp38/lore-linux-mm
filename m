Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A28FEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 20:40:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F4D420811
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 20:40:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F4D420811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDA016B027B; Thu, 28 Mar 2019 16:40:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8A806B027C; Thu, 28 Mar 2019 16:40:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D79CD6B027D; Thu, 28 Mar 2019 16:40:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 880EB6B027B
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:40:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k8so64592edl.22
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 13:40:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hc7fiIiWmOSD+Ln83eWPMA2KwRVoDGhWsKvEerkgNWs=;
        b=VL5tPl7/3U98QpK/q6SN9hBu6uvi35SIOywBsFD0A8jf1yuqN9mALNi2ns5Ua5d5ig
         H0DM/Riq6DfoI1pH8fHzVz4/blo0eP87AmXJhmRGlXBq2KT2vagfCBxCkq1xSLYjzDmz
         X7NkJk8NREMqJYNcqL3kTOOzUtoPkVFVfNuQGDHmTckaWb8dhQLylKTMxHH1zuWQoi+6
         weVZcD9sJIsLgSF9cpGbi16/ZveFQfWpbw2XzwmqDX9XmbSEA2pNKAJZiiTSHbr9f6ZV
         kVe6+myaS0ue916hU2Go9+TIc+JNfDtWaMM6R/fmOLcseDctwEVkS3TPvWRk6dJp6S6N
         l7Ng==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUlxFJCRAEhc1gicHadMmXs3qf+6eM+qk64EJ4mJnt+12tcUfeK
	L7iEs4PRql1lDfIrjXgdKRslZq0EFmvEmoYiJyjlSjfuhVJ/hlhTLfJ2jyq/ehQipyWfl1tWBI3
	2M2TQGMx1i/P4Uh2FH/5RTaE73uFs+4aFHvuVLLb+mvmn5yaDHpANZfw/d0l45ZU=
X-Received: by 2002:a17:906:5a59:: with SMTP id l25mr25347517ejs.122.1553805624070;
        Thu, 28 Mar 2019 13:40:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx842bGRbu/vHtWhww7jdVasfclctqQXXg7ypOl/4DvjWr/zGOTJrg2zx5xJyWQoBCDKVyD
X-Received: by 2002:a17:906:5a59:: with SMTP id l25mr25347488ejs.122.1553805623162;
        Thu, 28 Mar 2019 13:40:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553805623; cv=none;
        d=google.com; s=arc-20160816;
        b=C1z8aGjJ5J737FWeE/ibdE1DrDg9Rs6LO3RZVSMwrNifH9tVLCZUEJO+Jk6Ale0z19
         Oc5LpKBofUZbHTArl+O6FCMBSdH0/0YIYEIyo7QB6pz2LOYibiyOnIkSEx49WJmSSykw
         kotOhBgM4iWW/15TE7G8tC0kuL2JqYvqCb+XrOpviex4G1CJXco9yNmjqaYSR/qpJpHK
         LvT/JiV07+k98STGbMd0DOIQSMFmFgMknioKiNGOOm4iKhEWcTnwy/IC5lAM0O8BGBu8
         yQAcgchGw4foaxI5GEaHS7pVOMGbH1RiQ+QYgUPodbSWRBMilRcAk/I6Ft2mgjw1mTRE
         vHRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hc7fiIiWmOSD+Ln83eWPMA2KwRVoDGhWsKvEerkgNWs=;
        b=Qo0f7CLjjiVSFOtBU6K1XbgXRrLh0cK+43Bhx2fRyyh2G/EjLX6pJBLnbZLo83NsXP
         XfEKJlvV7sBwuL1f/OdgLVXm/uWuP9vpSuQ0JJpnLECoI9VJXPag83WMA3qt1n0NdEXu
         NJRUhNpmLKygCAgw8ol1eY749OD8i5TMt8TjsO9eyzJ6Nv+3S5fbHZp9VOADxSUW8y8p
         jcVCJw2nvK/z59lVQF0srGUb9WXK6MCSumepVeVKEXLfSHHNT0dFymu8u8cyjdX/6KvO
         zyTXvnKHaA1G/kBNbq0gK0gq5fA9liagO8GhWRl59V3uBxwnCeOf/tGdqTt10RyISh5B
         H5sw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l40si20834edc.343.2019.03.28.13.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 13:40:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 20388AC18;
	Thu, 28 Mar 2019 20:40:22 +0000 (UTC)
Date: Thu, 28 Mar 2019 21:40:20 +0100
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
Message-ID: <20190328204020.GD7155@dhcp22.suse.cz>
References: <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
 <20190327090100.GD11927@dhcp22.suse.cz>
 <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
 <c3690a19-e2a6-7db7-b146-b08aa9b22854@linux.alibaba.com>
 <20190327193918.GP11927@dhcp22.suse.cz>
 <6f8b4c51-3f3c-16f9-ca2f-dbcd08ea23e6@linux.alibaba.com>
 <20190328065802.GQ11927@dhcp22.suse.cz>
 <6487e0f5-aee4-3fea-00f5-c12602b8ad2b@linux.alibaba.com>
 <20190328191206.GC7155@dhcp22.suse.cz>
 <5934ed42-c512-a4c7-cbed-9062065bf276@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5934ed42-c512-a4c7-cbed-9062065bf276@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-03-19 12:40:14, Yang Shi wrote:
> 
> 
> On 3/28/19 12:12 PM, Michal Hocko wrote:
> > On Thu 28-03-19 11:58:57, Yang Shi wrote:
> > > 
> > > On 3/27/19 11:58 PM, Michal Hocko wrote:
> > > > On Wed 27-03-19 19:09:10, Yang Shi wrote:
> > > > > One question, when doing demote and promote we need define a path, for
> > > > > example, DRAM <-> PMEM (assume two tier memory). When determining what nodes
> > > > > are "DRAM" nodes, does it make sense to assume the nodes with both cpu and
> > > > > memory are DRAM nodes since PMEM nodes are typically cpuless nodes?
> > > > Do we really have to special case this for PMEM? Why cannot we simply go
> > > > in the zonelist order? In other words why cannot we use the same logic
> > > > for a larger NUMA machine and instead of swapping simply fallback to a
> > > > less contended NUMA node? It can be a regular DRAM, PMEM or whatever
> > > > other type of memory node.
> > > Thanks for the suggestion. It makes sense. However, if we don't specialize a
> > > pmem node, its fallback node may be a DRAM node, then the memory reclaim may
> > > move the inactive page to the DRAM node, it sounds not make too much sense
> > > since memory reclaim would prefer to move downwards (DRAM -> PMEM -> Disk).
> > There are certainly many details to sort out. One thing is how to handle
> > cpuless nodes (e.g. PMEM). Those shouldn't get any direct allocations
> > without an explicit binding, right? My first naive idea would be to only
> 
> Wait a minute. I thought we were arguing about the default allocation node
> mask yesterday. And, the conclusion is PMEM node should not be excluded from
> the node mask. PMEM nodes are cpuless nodes. I think I should replace all
> "PMEM node" to "cpuless node" in the cover letter and commit logs to make it
> explicitly.

No, this is not about the default allocation mask at all. Your
allocations start from a local/mempolicy node. CPUless nodes thus cannot be a
primary node so it will always be only in a fallback zonelist without an
explicit binding.

-- 
Michal Hocko
SUSE Labs

