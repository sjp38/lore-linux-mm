Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB4C7C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:23:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8350D2173C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:23:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8350D2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 033826B0269; Wed, 17 Apr 2019 05:23:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F26CA6B026A; Wed, 17 Apr 2019 05:23:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E16746B026B; Wed, 17 Apr 2019 05:23:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91AF46B0269
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:23:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p90so12292955edp.11
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 02:23:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HORiY95GMN/mO773EnGdlQfVVR5Tp0nuHGoBjQjbqhk=;
        b=PtLIljvJDzltHs3ttCHVPN8F3703YiHoCjUAfQg83BwR5aMZyCNnRWhjie7n0r3NgW
         Tq9Q5y/uTqBwXUvOnjK3DzUWB7eG3PR5O5OL9GedU6R9EuTnXtQez0Au3ytqRi2lLbhQ
         W2Ob/eOvzBsQUqKrsq5e4wWqPCmp6HLwB/sID7f4s0HsZw1nBWd1zEM05w1hztIpBtIz
         Xrd0FTcCUFTF6JA6/rYtESi9CQcf1qPAEuHekwQ7AUqAzf3MhMm/YK7GYpa45Y99MeIB
         oIKzVS5fmLHpnqfqxX8xzPIAOiVjRJvninXFe+KJxpmtt1vcZUYOeuUfC998G7ZI2goM
         d9vw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUSkKU9PFPBhMdSpLhFY0hAp8nwxfwcQ+7zhe5i4SBmwWGhi2e8
	saeOl9YswK/b6U66bBr+1wmqlTk9S6+UTjDsVMXBMqhnYaT4ZyMCRB4UG1FtAu/K9tleyot03sC
	NG4h6QqpxakzOt5slVdnY24mzSIS30Ylmf7zXnbWIvHZgC3vTEpH178pokO3SZh8=
X-Received: by 2002:a50:ad11:: with SMTP id y17mr15777484edc.184.1555493001158;
        Wed, 17 Apr 2019 02:23:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwen6JYHP5NmlP78Tr487bF1jVUgsGFQtizkHhD9p0tRYaaPZCfL8y+zlN9ffAZ+eKKbgjC
X-Received: by 2002:a50:ad11:: with SMTP id y17mr15777447edc.184.1555493000370;
        Wed, 17 Apr 2019 02:23:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555493000; cv=none;
        d=google.com; s=arc-20160816;
        b=m2yRP1CFL3FqYaPQo513zsafpvLKJQIZje2YifpxyYrFuI9fTqWURvOuSVZfp8rq3v
         +mO7UYE2vsLZmvGTqO/QGqFFBAObxMsnB50ebnytmgqKDGIwq55g8vk9KcLZn3wyjFfN
         PPD8QnkZOj5RhLFFp7QsK5aO3cNr8F1eAKBo+f2fK6Odyk8CMxhtRAuutCoKwvpZncKR
         rslrflqNKe7Qv+x1E168fr/JA6+AlveqkBrLSslOYm0wuplLeGgdZ/7xeOk0kvKe6A0g
         Pzc0abcogG/YMfalrAwliRXFkyN9HU8EbQa7xrl5a8BhyyMVrovffUrJIJTPh1xsYmEH
         bFTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HORiY95GMN/mO773EnGdlQfVVR5Tp0nuHGoBjQjbqhk=;
        b=vYKvvF7IeHqZs53nOCYyupkr5ZyyenNEiZGmW9NBYy9Ut/4oFa+BEcC1/phSnnvxyK
         9TtRPOSRJcgf7qAfeAw5mKGOrEbVuy0cQVO5riYqqSzM25kUqcJpCwsZEkCHXM2XPwEN
         Tma0HEbmV/HFJ0dPJhZsBIXFNrxdi4AhKx+nuluIXmMtUNqMXiCpwikpvL6+4u6HPGmy
         GJfbPLOWzvVG1iqgODPQLR+d2LtQsexiiiJeLLnmm8tJteJF9tKPHkwaWXKRSXhMFqMt
         9cSC4lx6sNbktyrFJk69NUFh8kVmL+/YUOc2/hd2a4GhLQTbXplkQ4aWydlWf17SYCvF
         L85Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3si11472897edp.192.2019.04.17.02.23.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 02:23:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9FF4CB143;
	Wed, 17 Apr 2019 09:23:19 +0000 (UTC)
Date: Wed, 17 Apr 2019 11:23:18 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net,
	riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
	keith.busch@intel.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190417092318.GG655@dhcp22.suse.cz>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 16-04-19 14:22:33, Dave Hansen wrote:
> On 4/16/19 12:19 PM, Yang Shi wrote:
> > would we prefer to try all the nodes in the fallback order to find the
> > first less contended one (i.e. DRAM0 -> PMEM0 -> DRAM1 -> PMEM1 -> Swap)?
> 
> Once a page went to DRAM1, how would we tell that it originated in DRAM0
> and is following the DRAM0 path rather than the DRAM1 path?
> 
> Memory on DRAM0's path would be:
> 
> 	DRAM0 -> PMEM0 -> DRAM1 -> PMEM1 -> Swap
> 
> Memory on DRAM1's path would be:
> 
> 	DRAM1 -> PMEM1 -> DRAM0 -> PMEM0 -> Swap
> 
> Keith Busch had a set of patches to let you specify the demotion order
> via sysfs for fun.  The rules we came up with were:

I am not a fan of any sysfs "fun"

> 1. Pages keep no history of where they have been

makes sense

> 2. Each node can only demote to one other node

Not really, see my other email. I do not really see any strong reason
why not use the full zonelist to demote to

> 3. The demotion path can not have cycles

yes. This could be achieved by GFP_NOWAIT opportunistic allocation for
the migration target. That should prevent from loops or artificial nodes
exhausting quite naturaly AFAICS. Maybe we will need some tricks to
raise the watermark but I am not convinced something like that is really
necessary.

-- 
Michal Hocko
SUSE Labs

