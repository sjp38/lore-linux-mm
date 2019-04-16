Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41E6BC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:40:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08FBB20656
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:40:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08FBB20656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 885756B02A8; Tue, 16 Apr 2019 10:40:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 833746B02AA; Tue, 16 Apr 2019 10:40:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7231C6B02AB; Tue, 16 Apr 2019 10:40:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 23F5C6B02A8
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:40:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e22so9423300edd.9
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:40:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kE2sK5B8RVXnzpG429UFSw1OEJu2pJbwFBiyEfcLI+A=;
        b=IfDQUmKFAheqkIsVRKVH9O1ondhPkqqxLFahw6H7SMBDb2F301lc32lLksisAqI4zr
         Gtfsnhp3T3mEKIIq1KufTQQGdTt8EpsNe0WhHd2hRsA/WkFZnSUpBu8qqWNsChDy4ksJ
         25z9OhhnwzmxpFpDXYGmBzJ8RQkQYMYX+A9VRqT3p3SUHoulmcOb2Qea8yGGQ0LRsDcu
         zbEXXd8lOzwofrKhkwDadjQYC7uC4a008KzLBPbQTqMzLRDL9JVDiSwuQkga0pkt6DqA
         yxbs0WWXPh6MiQXu2BA250iaVyGPnAHAlA4rKp5hCKOoEKLf4LyTsfh9bTUjDhRV6TsD
         erKQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXrTC5V0YxD/LLfIkP/WdiQ8l8PTsiMryp33yQN905+28CaOsCw
	TTcuXD0psXsnwMs5xGp1yGLiy8+br3sr3XkjaPHDMaX1bA8jdVbTVYIQnMVWZ1KOAC8SIIFYya1
	alU939/PfG2/R39c6wE8Vikv1VGmEo3wWZ9P0Br2BHJ/9Db6oxePgkHFrFqTLLMM=
X-Received: by 2002:a50:b158:: with SMTP id l24mr12241343edd.270.1555425601744;
        Tue, 16 Apr 2019 07:40:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIPDJ1f231Oln811JYJlQkOilViaBpfs3qzISIwd2HHlsklojIj1ic32KMbgPMlIi4wAAd
X-Received: by 2002:a50:b158:: with SMTP id l24mr12241298edd.270.1555425601072;
        Tue, 16 Apr 2019 07:40:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555425601; cv=none;
        d=google.com; s=arc-20160816;
        b=h+0EdTKHsCF4h6ILr7hIl6m29tP6CA1lhkiuoLtYIhZ6GCzYY7meIEK6N2EADr8+VQ
         exeMHlyyS4o52RFq/VbZkvcQaO2pQHo3UD+CuHRXwotauTPN2wlF8LhxPgW+Rh5qN/31
         oSpF8kzGl5+uJmmuBf3itrEE/FDH5GD77x5Vx39nPcV8iDVqRSMEr2caO81Bs1LY2qei
         SHdkk0H15uYq74Ak3/MHq4ZBCRKeCggvszoTJaCD1AAI5/2HLI0cVkfYeI/OY6u0KaNd
         8iRQWEL0SkS2gFm42Zmo9TJ+jq5Z3rN+sPWrwkOEseGESYE+vgQ8jdNbINrlZq5Zlf40
         il/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kE2sK5B8RVXnzpG429UFSw1OEJu2pJbwFBiyEfcLI+A=;
        b=X1yfE1H8RuqhOp54pt85MXdQYcIaDza/DK+MiPM4UO3J+HYNbftF2wFjIcy9mZrHTx
         gIz7l9syNi1gVD874jj3oA/tJJcZRjikO95knynJZHe9wm5zduNZjobxvmbt2YGbpWq+
         Y8qqE9xQBiIVc/2t23zKvr3xU7BAfitw9NwChRbtASbma38S/xFx+tjQ94mCviwoE+jN
         4cBb3Mug3cn01oDDabjzNqDHT2yamqrIT8Ztbj7CHQWzaERnSJqe4CsEkawr/Ymb4wYn
         BVgI7D0pvNjI4Qq3aCVKMQ0o/55mwVKGtTaV/40JmL9EyhJ+xQ9vENAUBFO2K5hfK3A+
         0Dbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c10si2727633ede.439.2019.04.16.07.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 07:40:01 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 366E2AE56;
	Tue, 16 Apr 2019 14:40:00 +0000 (UTC)
Date: Tue, 16 Apr 2019 16:39:58 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net,
	riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
	keith.busch@intel.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190416143958.GI11561@dhcp22.suse.cz>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <b9b40585-cb59-3d42-bcf8-e59bff77c663@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b9b40585-cb59-3d42-bcf8-e59bff77c663@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 16-04-19 07:30:20, Dave Hansen wrote:
> On 4/16/19 12:47 AM, Michal Hocko wrote:
> > You definitely have to follow policy. You cannot demote to a node which
> > is outside of the cpuset/mempolicy because you are breaking contract
> > expected by the userspace. That implies doing a rmap walk.
> 
> What *is* the contract with userspace, anyway? :)
> 
> Obviously, the preferred policy doesn't have any strict contract.
> 
> The strict binding has a bit more of a contract, but it doesn't prevent
> swapping.

Yes, but swapping is not a problem for using binding for memory
partitioning.

> Strict binding also doesn't keep another app from moving the
> memory.

I would consider that a bug.
-- 
Michal Hocko
SUSE Labs

