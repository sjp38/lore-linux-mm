Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00DE7C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:17:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9E7621773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:17:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9E7621773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 568FE6B000D; Wed, 17 Apr 2019 05:17:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 519066B000E; Wed, 17 Apr 2019 05:17:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42F216B0010; Wed, 17 Apr 2019 05:17:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E95AA6B000D
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:17:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id j3so12442712edb.14
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 02:17:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=t752BW4qXRp59Rcl77ihQois3ZtYc8icuukK40133oY=;
        b=PSgY8ku2BplN8H6183NYsbUj9rQ+LWEs14pGUojL/Q3x9bnb2R/XkI4PEM68BDeRqS
         /FAAxt4otHnbaV82HNaCijC6335bAFmHx+vGibnrfoMK9bQ1W7hgXFX4e6RyQdnpXSFN
         DvJgcsZUEWXIbm8AddQA9hfx58OHevtFAwWPKXGDy0inlk2OTXBczHL5BHuZlDtAUrK5
         T4dsG5SNv+d3Ln1YPVhpZSxKGRML5LRGLrK9z7HjKVs/cVSiMgmXpl5I5rWQqcvl6ZnD
         XegEovC7zzDJzo4G2cByVoXnguqmZGyD82yAHdY1Ul6iVZNSIogymkRm2ZUmXXLWE5eK
         G6Mg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU+sYXSWYcOyeqBwR6RumdgBR2wWh+tOh0mA3aPUuCQymSX5niN
	ApbyzC2B+E4UbeKVN+w+abPWtAyKMZ36sSZpDVYT1Hhp0lcgRBqvCnUX5JVVFkQppIR0OIGAtkX
	PD3/RdleMb9iGVvYBoxCQTz3NnAp1TAxa97GXbioTf8YDagk09pTKi7LVxMTa8NQ=
X-Received: by 2002:a50:ad9b:: with SMTP id a27mr2477885edd.206.1555492671517;
        Wed, 17 Apr 2019 02:17:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDfIgLyGIRFrHQk+QQ9KMYA7lLXbvPzIoyWLcfSi2/6OoOGOqaeFrbyLKFJoAQB6khA25d
X-Received: by 2002:a50:ad9b:: with SMTP id a27mr2477832edd.206.1555492670646;
        Wed, 17 Apr 2019 02:17:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555492670; cv=none;
        d=google.com; s=arc-20160816;
        b=KoVGF9iJTp/JvLq63/0TVSHFkfMJmvyPNYDlRwSfrcnTn++49fkktzibuQP6R/imKd
         azirFTt16oLUgKuLrM8H+HTeYLVFVLkQjhUv+hz6E2FHH+PQMtT4GGA7CB1wSAe0w3n1
         /whrPXeXd1EyGPPPXaneSDdF15e2GN+/sO3lbQZQuh8DFEAdsQM+xyhYQls1b+TfCA9G
         5SsT7Zfei8wvAc1bTZeXQKofIon5qOncLXGsIaPQmmQUEceXGq0WZgntZa3uQRrxzGlN
         t7LmFdqTa0SosYindA+540H2VDTeEaLofSxvrJIPArCZkljiW95WSsm9HaIfx0+liR3M
         zdxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=t752BW4qXRp59Rcl77ihQois3ZtYc8icuukK40133oY=;
        b=WUxNA/zfX5tT5y4CV1kZHt6OMzdBTcyVTtHp5jTizpSeajDmK38X7SHeKntv7IjnkR
         uxamv3WVHMgCxz8hhC1OEvWZAUahZLj1/CIHVYqEA4e4wAc/misYjdd2Xc0XpS8h4bZL
         QLPFrMA86srmVuyLAoUVr9f4hx9GShLmsD6+Vx+CUhjy0e/Z2v3nzpFzW/GUgqGtPRUX
         Ds4QyUJ9ZQffT1VodCgHDS/htHW5Jqy9658FEmHJesg3FzLGGoTXf4/Df7xxRZBc5k1G
         HjtZ7YOssdWAIAk1klGu1kQFoQKY8awQhrA7KTWkDKgG5Z4quQ3K83Ho4ZYeS8A8Woin
         M3VA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3si393417edm.104.2019.04.17.02.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 02:17:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BCCB7AE16;
	Wed, 17 Apr 2019 09:17:49 +0000 (UTC)
Date: Wed, 17 Apr 2019 11:17:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
	akpm@linux-foundation.org, dave.hansen@intel.com,
	keith.busch@intel.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190417091748.GF655@dhcp22.suse.cz>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 16-04-19 12:19:21, Yang Shi wrote:
> 
> 
> On 4/16/19 12:47 AM, Michal Hocko wrote:
[...]
> > Why cannot we simply demote in the proximity order? Why do you make
> > cpuless nodes so special? If other close nodes are vacant then just use
> > them.
> 
> We could. But, this raises another question, would we prefer to just demote
> to the next fallback node (just try once), if it is contended, then just
> swap (i.e. DRAM0 -> PMEM0 -> Swap); or would we prefer to try all the nodes
> in the fallback order to find the first less contended one (i.e. DRAM0 ->
> PMEM0 -> DRAM1 -> PMEM1 -> Swap)?

I would go with the later. Why, because it is more natural. Because that
is the natural allocation path so I do not see why this shouldn't be the
natural demotion path.

> 
> |------|     |------| |------|        |------|
> |PMEM0|---|DRAM0| --- CPU0 --- CPU1 --- |DRAM1| --- |PMEM1|
> |------|     |------| |------|       |------|
> 
> The first one sounds simpler, and the current implementation does so and
> this needs find out the closest PMEM node by recognizing cpuless node.

Unless you are specifying an explicit nodemask then the allocator will
do the allocation fallback for the migration target for you.

> If we prefer go with the second option, it is definitely unnecessary to
> specialize any node.
> 
> > > > I would expect that the very first attempt wouldn't do much more than
> > > > migrate to-be-reclaimed pages (without an explicit binding) with a
> > > Do you mean respect mempolicy or cpuset when doing demotion? I was wondering
> > > this, but I didn't do so in the current implementation since it may need
> > > walk the rmap to retrieve the mempolicy in the reclaim path. Is there any
> > > easier way to do so?
> > You definitely have to follow policy. You cannot demote to a node which
> > is outside of the cpuset/mempolicy because you are breaking contract
> > expected by the userspace. That implies doing a rmap walk.
> 
> OK, however, this may prevent from demoting unmapped page cache since there
> is no way to find those pages' policy.

I do not really expect that hard numa binding for the page cache is a
usecase we really have to lose sleep over for now.

> And, we have to think about what we should do when the demotion target has
> conflict with the mempolicy.

Simply skip it.

> The easiest way is to just skip those conflict
> pages in demotion. Or we may have to do the demotion one page by one page
> instead of migrating a list of pages.

Yes one page at the time sounds reasonable to me. THis is how we do
reclaim anyway.
-- 
Michal Hocko
SUSE Labs

