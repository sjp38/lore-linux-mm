Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A4B4C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 11:26:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 320E420880
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 11:26:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 320E420880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD4C78E0003; Tue, 29 Jan 2019 06:26:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B84ED8E0001; Tue, 29 Jan 2019 06:26:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9B7C8E0003; Tue, 29 Jan 2019 06:26:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 51D1F8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 06:26:18 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c3so7912487eda.3
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 03:26:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Y6Dpi77XEkR00NlkpV9Xe6nmtJK5HvSU0II/OAMV36M=;
        b=YWdpit4FLhhpPnr12bHpSFpq+GY1VAMz33lj/AkNoeC8sDkcx4MeLRLM3OJpNCnPEa
         6uDK88XB43m8+Abgd8yJBZxWTgYN0syTphASgd/a3ig9VK85arVrPR6NSmGPPYTLxVFh
         4/psl29yNdD0nMOICSxJjqh87g2MsJjoVo+dCC8Csq8jXSvlGOsjxXJXnaEiY2lu5h7p
         oWN0yUm4iNeujHVm2wzeznyN600SQmC3reZKnZ2y2bWEslYBhRBTT2gjxjO9NJ3F908f
         wS/zKzVjqvxBcztsMI4amCCfa8AtA9mGB6gRXJK+g0OHSGHwp/PT94fOCiieC/pLPMhe
         wm6g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukccOWkl9Ont3jJAgdpgFgb6cf6SzFKFKu9jALeu1qVzdGDqXL2H
	mM19H66Zv3afedjSEtBWT5jBwv28M0UzF2D6myK2KDAZVG+kPwy8qlat9sptxETSYLviQEz/3uP
	UTboSMur22kQ0zyOU3g3atW5y95iMS64QacFq7uvDiIPX0L/Eo47gFC12JDSc0oI=
X-Received: by 2002:a17:906:b2cc:: with SMTP id cf12mr20883876ejb.36.1548761177868;
        Tue, 29 Jan 2019 03:26:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN40gtqavSs8nL3yDPYkvUM0oWRLvFPNxb8gq8bGXmYo1kBFPPMUAM5lj0GVdIGycxKocxKH
X-Received: by 2002:a17:906:b2cc:: with SMTP id cf12mr20883822ejb.36.1548761176809;
        Tue, 29 Jan 2019 03:26:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548761176; cv=none;
        d=google.com; s=arc-20160816;
        b=IaZjyEnNTQUNK1VFeHGvc7WcU1TdTEb0c83FHG7VTJFjaXYZuxK3AD14sjSg6Wkl/S
         7sUrkonBrsi8+q9mGRRcUbfKMn4YkSG8hgiInHU/+pmEphskqo6VGWT/FuHtpriY7yKs
         wu0ItutJMPwSsbz+4qH4UgkYS5Jrkcp2HJESdD5o502J8X26vURhp+hm7Zb1o7f9iZgd
         6z2/huNRN568420HJAemD8bso55k88WlSxZ6OTFnZ1PlV/RfDRlaUVz8rDjpzdtkh+s+
         MuvAFtIFC/bsKReORCaXXH8rbsalQb2Z8ihNOWzAztPkPORIzayFNKdlfL0aCDC0hm85
         pLUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Y6Dpi77XEkR00NlkpV9Xe6nmtJK5HvSU0II/OAMV36M=;
        b=IgzKS8rF4k0dmcicR7XoFaLd0AKQS+ya4teCysp92piVX9q1rhEluDjtY4PE15V+jj
         C6Ia1UDgo0evvbvei59jBNlaPQNr3fk7Mh9dGbaBVn2AvINZB75gEXj0EzZpCeoSIpGm
         O2r8YNVEUwM4APqldIfe2ZEw+CY1oKVf4FSpAgSaYwZUAd9wAHYD+Ck42pXIU9DTK1zs
         IjTZK6EPhcBfhfa+Ob3fwOieQ0+OCVpZpWQPFCBgOwrerBSiJGNuu0M1yvGHrbmyhTrY
         MbMWvDr3/wsgHqgEr133CKmAyQ0Va2/LuZGdt8v7lYtVZly31aAmkVPv/S4IxZs+8l8A
         yoTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i32si2549126edc.292.2019.01.29.03.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 03:26:16 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F318CAE8F;
	Tue, 29 Jan 2019 11:26:15 +0000 (UTC)
Date: Tue, 29 Jan 2019 12:26:15 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: [LSF/MM TOPIC] Test cases to choose for demonstrating mm
 features or fixing mm bugs
Message-ID: <20190129112615.GI18811@dhcp22.suse.cz>
References: <20190128112033.GI26056@350D>
 <20190128113442.GG18811@dhcp22.suse.cz>
 <20190129104328.GJ26056@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129104328.GJ26056@350D>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 29-01-19 21:43:28, Balbir Singh wrote:
> On Mon, Jan 28, 2019 at 12:34:42PM +0100, Michal Hocko wrote:
> > On Mon 28-01-19 22:20:33, Balbir Singh wrote:
> > > Sending a patch to linux-mm today has become a complex task. One of the
> > > reasons for the complexity is a lack of fundamental expectation of what
> > > tests to run.
> > > 
> > > Mel Gorman has a set of tests [1], but there is no easy way to select
> > > what tests to run. Some of them are proprietary (spec*), but others
> > > have varying run times. A single line change may require hours or days
> > > of testing, add to that complexity of configuration. It requires a lot
> > > of tweaking and frequent test spawning to settle down on what to run,
> > > what configuration to choose and benefit to show.
> > > 
> > > The proposal is to have a discussion on how to design a good sanity
> > > test suite for the mm subsystem, which could potentially include
> > > OOM test cases and known problem patterns with proposed changes
> > 
> > I am not sure I follow. So what is the problem you would like to solve.
> > If tests are taking too long then there is a good reason for that most
> > probably. Are you thinking of any specific tests which should be run or
> > even included to MM tests or similar?
> 
> Let me elaborate, everytime I think I find something interesting, in terms
> of something to develop/fix, I think of how to test the changes. I think
> for well established code (such as reclaim) or even other features, it's hard
> to find good test cases to run as a base to ensure that
> 
> 1. There is good coverage of tests against the changes
> 2. The right test cases have been run from a performance perspective
> 
> The reason I brought up the time was not the time for a single test,
> but all the tests cumulative in the absence of good guidance for
> (1) and (2) above.
> 
> IOW, what guidance can we provide to patch writers and bug fixers in terms
> of what testing to carry out? How do we avoid biases in results and
> ensure consistency?

Well, I am afraid that there is no reference workload for the reclaim
behavior or many other heuristics MM uses. This will always be workload
dependant. Mel's mm-tests have a wider variety of workloads. There might
be more of course. The most important part is how those represent real
workload people do care about.

Abstracting workloads which are not in the test suits yet is definitely
a step in the right direction.
-- 
Michal Hocko
SUSE Labs

