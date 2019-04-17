Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5295CC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 16:39:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1DF42064B
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 16:39:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1DF42064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7539C6B0005; Wed, 17 Apr 2019 12:39:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7014B6B0006; Wed, 17 Apr 2019 12:39:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CACB6B0007; Wed, 17 Apr 2019 12:39:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A69A6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:39:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h27so12786726eda.8
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:39:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rrCf6SVtM07NH9+OMGHudPfvaV1SdrS/yUvdQP0a1Lw=;
        b=glCDGoQ8W6GFtIMAAwn0yAai1ebVDJ0suXaUFwV6Dl8UmwE7Y1bo9jby9QMylASiu5
         LxxspZ8YAmSLN6+oKfZMSbTyBgJ6BZN0kmSl4dDhkgBnfaQfgBudDwMViLAG0tyBZfxe
         4fasYLOUHJyBx7gMQR+2wYjucGzX0ZPc8C6U+e6qjSRQr2MXSRkcK4TutaYodsyQ1MBr
         dcgaE/pJGHhF8MPhctrkctZLc/yKoS/OBBAjnRbPPzZQF/9VJFsk64iDOe+iYzTs5XGM
         4T0osjD9+4GvYbKsM4NlOby6tpIYdquikt8q8dxe9lbuBKZ3EOMfuN2jdzM6faStSgOR
         9YRQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUgVVDk6OqYQVfYoM7CQhTnjWl6tW/n/I+eUPNKFp07PjBqEmWK
	0UC0/RZPlUF2TsZl0X5qgKUGOTke/hG2flAiMv5QSxv+tjlAUbluCoaPk2Ba32T9f/VmB+J8FNs
	vvlwYEW/9lnW1na+dqdn5hYrC4lbfB9q9izQROayFtvrHGNm2CK88OyKIfMWkJ6o=
X-Received: by 2002:a17:906:69d3:: with SMTP id g19mr26914872ejs.212.1555519154495;
        Wed, 17 Apr 2019 09:39:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+d98IRurxCg57hf9HT5in9MmwsASaTksh7CnDTNHY+QcT9AjYTceNoByjpxoRZjIJBNp4
X-Received: by 2002:a17:906:69d3:: with SMTP id g19mr26914827ejs.212.1555519153571;
        Wed, 17 Apr 2019 09:39:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555519153; cv=none;
        d=google.com; s=arc-20160816;
        b=qQ5lU8Ag1GPUcGDs4dYyWWVrxXt4qWUJVO2CLMBFK8FLoc+TpoDym4+/ZnTVeEAXk7
         BXFw2e949i1d+ZiSGeYeKZRUXifCtJgfueVvTlMOM/ce8ujCDJd5faJ5c5ASsBUGIq7Y
         vblnhjR+GNrIDeo7V3+d23jYMBgP6IS1Uypsk20AsDrtb6a1QlwZFkQF1trKDvX7u05a
         S7rAKY4eX9uDrskb740ruGef9CC7jnwr/+bx80VpR9in7cHXeaiZNRvzg1t9wIsb7qu0
         LYpW+G/T4nNEky1IIbcZ4GVwJmO8q4SPA4P+H/7HuXBinJiZmuBT9mq8/A/1enIme1le
         mRFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rrCf6SVtM07NH9+OMGHudPfvaV1SdrS/yUvdQP0a1Lw=;
        b=B6Gc9aCr8ncGuR6eMYYh0O6RmI1WETmEdaE2CPnWf+VwmgjXkh/Qe6fpVjWVs9p0iJ
         8bWV7TApPbwFkJgwF3O/oMKZxNi7r1oR/dxeQ8MRwCJO+TNFQsAlHw1QuPMnAAGU6Jbx
         sxJCkZAXsF+w9CBU0f28ntkmltI+V1gEq122ae4e+Vi/dasKfTI+E2jz767WKemstxYD
         k5PnxjDuQ45UYCvqmgwFuUYbZPqjedeUTjfFjCrJtrsvZk875WSssMVkKRPH72wr7s5B
         n7EdquaAdjB+kHGppJu/d32ahGKGCvDb/WI8HNguBvdBJwoI/sD7tNXoBKzTB7ww0trR
         k5HQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h24si1781474edh.413.2019.04.17.09.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 09:39:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A99A9B113;
	Wed, 17 Apr 2019 16:39:12 +0000 (UTC)
Date: Wed, 17 Apr 2019 18:39:11 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net,
	riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
	dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
	ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190417163911.GA9523@dhcp22.suse.cz>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <20190417092318.GG655@dhcp22.suse.cz>
 <20190417152345.GB4786@localhost.localdomain>
 <20190417153923.GO5878@dhcp22.suse.cz>
 <20190417153739.GD4786@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417153739.GD4786@localhost.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 09:37:39, Keith Busch wrote:
> On Wed, Apr 17, 2019 at 05:39:23PM +0200, Michal Hocko wrote:
> > On Wed 17-04-19 09:23:46, Keith Busch wrote:
> > > On Wed, Apr 17, 2019 at 11:23:18AM +0200, Michal Hocko wrote:
> > > > On Tue 16-04-19 14:22:33, Dave Hansen wrote:
> > > > > Keith Busch had a set of patches to let you specify the demotion order
> > > > > via sysfs for fun.  The rules we came up with were:
> > > > 
> > > > I am not a fan of any sysfs "fun"
> > > 
> > > I'm hung up on the user facing interface, but there should be some way a
> > > user decides if a memory node is or is not a migrate target, right?
> > 
> > Why? Or to put it differently, why do we have to start with a user
> > interface at this stage when we actually barely have any real usecases
> > out there?
> 
> The use case is an alternative to swap, right? The user has to decide
> which storage is the swap target, so operating in the same spirit.

I do not follow. If you use rebalancing you can still deplete the memory
and end up in a swap storage. If you want to reclaim/swap rather than
rebalance then you do not enable rebalancing (by node_reclaim or similar
mechanism).

-- 
Michal Hocko
SUSE Labs

