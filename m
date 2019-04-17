Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFA3FC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:57:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B91621773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:57:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B91621773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AA296B0005; Wed, 17 Apr 2019 13:57:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2599D6B0006; Wed, 17 Apr 2019 13:57:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 122C86B0007; Wed, 17 Apr 2019 13:57:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B48576B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:57:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f42so7990711edd.0
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:57:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ilvRUx3wmP7GZ9qaUFWLZQbmKvfv6koXKSl+KoMq7LY=;
        b=qwREJ4ESZh2tN0cuK0V85/zRVY/rSwDXmuU0Ty1V7bawPXL7R9ICw003lEmtccoFOW
         Lp3g8PF+70/T1kOxrD2+rmt+QofB283lRxJMYa9B3KWXUOYCYRwV1FucAhIKfAzf7IJD
         4BNDOk7nWN30REIeVmsKx3DW5kJSebZIpL9YequgIeVLU3M3gS7FrEQoizDpEj22ixGn
         30EbHjPA8h82TpIip1ejzPyINasxKjh7JHUlh9ElqrGi/X2EZ16NeymhWEskHgu8cVqu
         Os2TeMMVXqLcG9F/wvVmw0UFS6B4TtIaMfqEg5t6GZHawURBKWmNrfid7VzrN7mOz2bX
         xuEA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWD06RfhvX1I3tpzlyt1MO4WNirP0kYs4wLT9EKScQFEgGKV2my
	o0LcsS1Lq63FSmn9b/vhzFZlQP2c0Nqg93odYZaCMMjHUserk4iHKIpHzlQs5QvOzCEjzn/HAs8
	D66GjcgX96aRUt6PZ/Oy7TvAJ0VvvdIC38xuvVe3yZnXV7FRZdYRhGzShSddWQ6Q=
X-Received: by 2002:a50:9eec:: with SMTP id a99mr29013754edf.186.1555523867166;
        Wed, 17 Apr 2019 10:57:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxj6fz0HLcIkOAPDafcOD9UDz8ONCJ7QZhmFz3bOdwG2Dbsd/ZVa1YkB58dyjazIaS7pIma
X-Received: by 2002:a50:9eec:: with SMTP id a99mr29013706edf.186.1555523866361;
        Wed, 17 Apr 2019 10:57:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555523866; cv=none;
        d=google.com; s=arc-20160816;
        b=v8eUHBapMN/hEy55JHxTF5PkXBy96q9sp6gDGxffMHU0wCi/ZGLVCAVZ6oWYJugqgT
         MMNTGfrI8UUmb4nVl7QX0Knxuq9Eb4BMA0sXFF6PumC1luSTlIZnwV0knQIpwweV9XXS
         1QbBmqRzcW282EGzZeR0pTb+7J+yYxjCpLVGoCkmxSgP+F2sL/vX3dCvrMvmwkoheLDG
         H9TOEIkd4J0NdGtExH+ZR+SCR8nvbTpkNt4QNKWKHUABqtjwcAXtjH393dyW1Fhhv3En
         8OEk+O0I/sUSimMiLe3QaRNP08/3Ly/CZzYshaf1b18KpTKGl65xbi3tqQpTh0lHw6qh
         ze2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ilvRUx3wmP7GZ9qaUFWLZQbmKvfv6koXKSl+KoMq7LY=;
        b=M9ROWsEatFEfK1Zox3f/sx+7//7EkMOMFF1EccRs5LHrliaSsFdtPZ4Uni2jJ9XdGB
         AgXs96XpxUWhP89fuDFHPlyPLwfLzqEvZV18F8xJs/UWkI19J8LvFGHq+WdHtirBkiHX
         BZkBtrgmBY6KZCjTfzpuBsoZBY6ZEZSnrqhjfgUIWt02Oh/h0fe44bhf5qhJ0fE6Wujw
         SGzhQOaTZlTAdgdMfvyI6odgZj2DvqFwIO0H87wWMUB/De2dewpiaAO4HG2qWBlxHsA9
         8TFcjKee6O3L+vw65TZs4bv2auuiySGrvIEhzYmVg4nv3KaK2TcR8FvO28hhO/k/G+KX
         9WEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y4si6947182eju.298.2019.04.17.10.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 10:57:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 60BC9AC63;
	Wed, 17 Apr 2019 17:57:45 +0000 (UTC)
Date: Wed, 17 Apr 2019 19:57:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net,
	riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
	keith.busch@intel.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190417175743.GC9523@dhcp22.suse.cz>
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
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 10:13:44, Dave Hansen wrote:
> On 4/17/19 2:23 AM, Michal Hocko wrote:
> >> 3. The demotion path can not have cycles
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

I was thinking along node reclaim like based migration. You are right
that a parallel kswapd might reclaim enough to cause the ping pong and
we might need to play some watermaks tricks but as you say below this is
to be seen and a playground to explore. All I am saying is to try the
most simplistic approach first without all the bells and whistles to see
how this plays out with real workloads and build on top of that.

We already do have model - node_reclaim - which turned out to suck a lot
because the reclaim was just too aggressive wrt. refault. Maybe
migration will turn out much more feasible. And maybe I am completely
wrong and we need a much more complex solution.

> I think what you're saying is that, eventually, the kswapds will see
> allocation failures and stop migrating, providing hysteresis.  This is
> probably true.
> 
> But, I'm more concerned about that window where the kswapds are throwing
> pages at each other because they're effectively just wasting resources
> in this window.  I guess we should figure our how large this window is
> and how fast (or if) the dampening occurs in practice.

-- 
Michal Hocko
SUSE Labs

