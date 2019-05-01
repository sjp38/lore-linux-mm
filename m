Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5E6CC04AA8
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 05:20:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68D0A20866
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 05:20:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68D0A20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2F436B0005; Wed,  1 May 2019 01:20:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDF9C6B0006; Wed,  1 May 2019 01:20:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA77B6B0007; Wed,  1 May 2019 01:20:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 747AF6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 01:20:48 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z12so10388533pgs.4
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 22:20:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uTdrxOi+GUa7zPdGGvZw/0jeRxd+WIdkYwK6Kndz/Uc=;
        b=l2lnwQhB2H5Kf5WyahUQrZluOAfYqGKZwbg0uI+oJCfLQaApxKBljhESnZurFapAmP
         NT5AnVC55pg5D/TQF0WMUcrd+YVLlZUKClo0tts+VhKQjCJtlFFhZMr1iPpO3+DZiw/M
         TosDqWR6zsMNyw5d4xktdAoE4B0qKpto/DhU3c7KJAp9rg6k2QEjbwTQ4qGjvtATZD12
         C2TzvHsKkIak+ewlBgVGk0h3tfc8t7bEYVf5XsEif/3m1X3kh/i6RnSKymbaO+MbVvX5
         fufxsw1uCYdnNyxPn1ISpNimX5GduxNNHdH1oKBg7Tkf5Ver/tGDU24S53yGDUtZUbzg
         WahQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUZsgQnq/E852IY5NKXMcqlZcgk2ZzygjP30Y7mjGltaKOdzKgM
	lJCHZS3OdJNFTVkXoRU5mWXmmF3WGifJqr57NZiWMZ8Ec1hcLVVXGonOv0gQ1LAaLn+GrmJ1x3f
	rMkZzqF2V2zfjenK0K2jtL2FRrvT1C0zPU27+0OltOxpFl4R0BqHNkh0I6AvPL2l3iA==
X-Received: by 2002:a17:902:8f88:: with SMTP id z8mr4920730plo.54.1556688048147;
        Tue, 30 Apr 2019 22:20:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiplVKCyjJk57YUSkRl93zFhIZrcpcivzYDPhRWbfJFrQdjdetG+AN+9hfAd4SmHN/MtC5
X-Received: by 2002:a17:902:8f88:: with SMTP id z8mr4920672plo.54.1556688047159;
        Tue, 30 Apr 2019 22:20:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556688047; cv=none;
        d=google.com; s=arc-20160816;
        b=t24ghVraAMECHwFqPWj8CuCkkItWIErXQ9Gz+5wCVn3ZaFyRpSvlhOfADd8wfjmKhy
         z0ENoHc/L1g+Rg2RNLEItDZ/HPpptJfLRLvYkWAgJhLUfmWvuewgci2UHHhZO4HdOasK
         BHJ6au5Qh0ZiJnegvIFC40RqIeqH280cyxm93CQp6PaWZjckhqwbdLSU2dQ6mKjqd8c9
         Lm1OpAhIg9j/+flr12Cuo/NHhh2gwerQ9eXn+b003pG+ACNliWiZJ7ZjIVh8myQxAUXT
         UknzB1R8aJcs16/QvTYEHSdZJWKYO4HgJk9xAtnB2YRavARh9VaUstuoaFllm+Df0Ax4
         qzOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uTdrxOi+GUa7zPdGGvZw/0jeRxd+WIdkYwK6Kndz/Uc=;
        b=xw2nCf1HTcLGZw0hFvAbn2FMTCKejNCQfIOW+TK6mrqzFh/RpwP7HfOVJjcbi2zcUS
         AS106irvCDF3dPdD/+boCbrDtYd49iE6CNbG6h9jqp9HM1TItd0ygbZzhUXTf7QKAziA
         2pecQUrvw0qW45v2k9RTSXm14bkvdywM/U//J3uRsiV5c20HKFIOJu+oc7m5NqM8JH1U
         Empg4whQIwyKjAxhAi2POzalSJlzIAtmm9UkjmT5HBlFEAuPngqKTJHqaDMQ+HDuoy4N
         ixnBJClbMWrTclHfuFDNhKzJ2rosbCUQhLlboyudf1WlkTJOOnHWhUTwidLbvqZjsGYe
         yVSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id w12si37182026pgr.412.2019.04.30.22.20.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 22:20:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 Apr 2019 22:20:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,416,1549958400"; 
   d="scan'208";a="153757165"
Received: from wul-mobl.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.212.158])
  by FMSMGA003.fm.intel.com with ESMTP; 30 Apr 2019 22:20:34 -0700
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1hLhfT-0005Vd-6o; Wed, 01 May 2019 13:20:31 +0800
Date: Wed, 1 May 2019 13:20:31 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net,
	riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
	dave.hansen@intel.com, keith.busch@intel.com,
	dan.j.williams@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190501052031.dt7zbkw5n5gzf2eg@wfg-t540p.sh.intel.com>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <c0fe0c54-b61a-4f5d-8af5-59818641e747@linux.alibaba.com>
 <20190418090227.GG6567@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190418090227.GG6567@dhcp22.suse.cz>
User-Agent: NeoMutt/20170609 (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 11:02:27AM +0200, Michal Hocko wrote:
>On Wed 17-04-19 13:43:44, Yang Shi wrote:
>[...]
>> And, I'm wondering whether this optimization is also suitable to general
>> NUMA balancing or not.
>
>If there are convincing numbers then this should be a preferable way to
>deal with it. Please note that the number of promotions is not the only
>metric to watch. The overal performance/access latency would be another one.

Good question. Shi and me aligned today. Also talked with Mel (but
sorry I must missed some points due to poor English listening). It
becomes clear that

1) PMEM/DRAM page promotion/demotion is a hard problem to attack.
There will and should be multiple approaches for open discussion
before settling down. The criteria might be balanced complexity,
overheads, performance, etc.

2) We need a lot more data to lay solid foundation for effective
discussions. Testing will be a rather time consuming part for
contributor. We'll need to work together to create a number of
benchmarks that can well exercise the kernel promotion/demotion paths
and gather the necessary numbers. By collaborating on a common set of
tests, we can not only amortize efforts, but also compare different
approaches or compare v1/v2/... of the same approach conveniently.

Ying has already created several LKP test cases for that purpose.
Shi and me plan to join the efforts, too.

Thanks,
Fengguang

