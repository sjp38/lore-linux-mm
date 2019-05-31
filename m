Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1C90C28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 19:27:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 696AF26E56
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 19:27:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="SbI05ChM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 696AF26E56
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E36096B026A; Fri, 31 May 2019 15:27:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE5896B026E; Fri, 31 May 2019 15:27:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD4B46B027E; Fri, 31 May 2019 15:27:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 97C226B026A
	for <linux-mm@kvack.org>; Fri, 31 May 2019 15:27:44 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r12so7935296pfl.2
        for <linux-mm@kvack.org>; Fri, 31 May 2019 12:27:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3oPC7MpGNkmIv4lC37rTS0RoLjGGQjB5vfa5jgin/Xo=;
        b=e2Ch+BMRcyXId/nTHICa7kKS2DIN1LM6VB/7CecN9YhHvIFeGKMOPzZEeH9zgfZGKp
         KpDCpElJzbvCp7omx+DFBdu10YygBFzDQXdcORn2RPMXF7ZJc21InEA10BV/e8oM6YXD
         XaYHeyRTddrpGCpjx5RHh9Nzl/JvpWlv4d1NFS9k8ne0ZHaYza+J+qURfrjSi227Xj+Z
         sZ+807QoiIixozh1oeEzfC5j+xLDJtyPNs9cMyL6N5QjaLGaPKB/jBac8IDe+8a52M5A
         6LIz2wnz4ZuxpHJPy3N0t0YXJqOcknlLYylPNlSFTfv09JSWkCFVZHRdmgOMPNrrbYK2
         QwzA==
X-Gm-Message-State: APjAAAWi1pTvA5ZJBfTJXax12vVXxmPSz+gYym4RwtjCf5pJerbi/ZTb
	xz4/zkDibi+7KfC6lWE+diQD84a0lEl4KAr4ax7qQEe/AS7B79KMKJKqjE5FAD20idHlVvJU72C
	FruyU2v7AIJ7M9gVZHDNXrX5NZHr209VNtz/9MKauZS4wRjNx4lLqjWDqUgJ4jplvng==
X-Received: by 2002:a17:90a:22ea:: with SMTP id s97mr11288543pjc.39.1559330864070;
        Fri, 31 May 2019 12:27:44 -0700 (PDT)
X-Received: by 2002:a17:90a:22ea:: with SMTP id s97mr11288509pjc.39.1559330863231;
        Fri, 31 May 2019 12:27:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559330863; cv=none;
        d=google.com; s=arc-20160816;
        b=cOhc3x0QVmDon/BxWCivQStwzh1JCdoL/nNlgUlltetYSjDoLNnQX8/BgDFTYZMZNL
         i7/oL+fpem8kHs+CZxRhdEKGWAwuFWoPgxaKvAI5r2smAP4fJTfiTRemOygi0TR1w/AO
         ZS+QHn2uAA0tMCjnFF/K3pWuxOXYjIyqvx07l9j9bNVky8Lb8G6jjfwOkfICbG4J/U7D
         gM7c4cStY1uVQyO6RIC21Lfu+gud3666VHr55FUbrrR3X7Kah5P28l8K89fYgbF7nZ4l
         JQgsC2asE7PUGIdNDXplSPVQmFgxdVN7rWlHIQXxC4u4f9bTOfsM4AT5XwhYPEejj3t4
         8KQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3oPC7MpGNkmIv4lC37rTS0RoLjGGQjB5vfa5jgin/Xo=;
        b=O/KW9lGAdpDqR8yqaDxYBoqFrhjajnKx7VdP8Py+q4C2r0EsBHZqqok9agljWS7DFP
         XmBef/QzlAB0GrLkUtDF3l7VkMsIT6WxucO43/TDimQ1drnxJpG7otyEDeV+1E1Pmykg
         8jVx9bGzcfH4IUNCmwh8+ExETdd52eCm9tHoZlWxVmW8wbN6tO5tMORqdWemy2VLDeR1
         dgh+5uXDht2Wp+LBudl7z3LfGBygDl3bX7u5aToSTR32e2K96ip/P0tpKC5/aGz1z5Ob
         VEi1+wWptDLn++f3OstFG5Nq0Ypqh0Tp9R+wcu078wbciJyL7v6sr7el4i0Vv6YhoFvA
         qkIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=SbI05ChM;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor7945991pfi.35.2019.05.31.12.27.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 12:27:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=SbI05ChM;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3oPC7MpGNkmIv4lC37rTS0RoLjGGQjB5vfa5jgin/Xo=;
        b=SbI05ChMOHpTulNwmjhSR5ZbY9idO2IxEcT87P8CRpkS49RpLitZ6wSoqJeEdL1yVK
         cww6Si5nneZ2edimkGsX9/iIsmxdqDJDY5OVjkYb730pjSBbLnqr5fWiePVGdfkZ6x8p
         K2nnnRVs/YngzaK04SXScheJ4pWXrpnvyJLow=
X-Google-Smtp-Source: APXvYqx8hFRJFZmWhsZTcS5jPsQcgCdx6RY9Azo2rv/4QAY3o3jE3z984dUqq8bjDr4wU09ByZJlcQ==
X-Received: by 2002:a62:1885:: with SMTP id 127mr12522926pfy.48.1559330862439;
        Fri, 31 May 2019 12:27:42 -0700 (PDT)
Received: from localhost ([2620:10d:c090:200::3:3d82])
        by smtp.gmail.com with ESMTPSA id f2sm5497516pgs.83.2019.05.31.12.27.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 31 May 2019 12:27:41 -0700 (PDT)
Date: Fri, 31 May 2019 12:27:40 -0700
From: Chris Down <chris@chrisdown.name>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Message-ID: <20190531192740.GA286159@chrisdown.name>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
 <20190530061221.GA6703@dhcp22.suse.cz>
 <20190530064453.GA110128@chrisdown.name>
 <20190530065111.GC6703@dhcp22.suse.cz>
 <20190530205210.GA165912@chrisdown.name>
 <20190531062854.GG6896@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190531062854.GG6896@dhcp22.suse.cz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko writes:
>On Thu 30-05-19 13:52:10, Chris Down wrote:
>> Michal Hocko writes:
>> > On Wed 29-05-19 23:44:53, Chris Down wrote:
>> > > Michal Hocko writes:
>> > > > Maybe I am missing something so correct me if I am wrong but the new
>> > > > calculation actually means that we always allow to scan even min
>> > > > protected memcgs right?
>> > >
>> > > We check if the memcg is min protected as a precondition for coming into
>> > > this function at all, so this generally isn't possible. See the
>> > > mem_cgroup_protected MEMCG_PROT_MIN check in shrink_node.
>> >
>> > OK, that is the part I was missing, I got confused by checking the min
>> > limit as well here. Thanks for the clarification. A comment would be
>> > handy or do we really need to consider min at all?
>>
>> You mean as part of the reclaim pressure calculation? Yeah, we still need
>> it, because we might only set memory.min, but not set memory.low.
>
>But then the memcg will get excluded as well right?

I'm not sure what you mean, could you clarify? :-)

The only thing we use memory.min for in this patch is potentially as the 
protection size, which we then use to determine reclaim pressure. We don't use 
this information if the cgroup is below memory.min, because you'll never come 
in here. This is for if you *do* have memory.min or memory.low set and you are 
*exceeding* it (or we are in low reclaim), in which case we want it (or 
memory.low if higher) considered as the protection size.

