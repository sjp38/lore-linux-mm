Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 913D4C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:49:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F83221929
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:49:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="dzOycvFR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F83221929
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 031F56B0007; Fri, 22 Mar 2019 18:49:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED24B6B0008; Fri, 22 Mar 2019 18:49:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9D506B000A; Fri, 22 Mar 2019 18:49:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 88E746B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 18:49:49 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id k4so1695965wrw.11
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 15:49:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Y9aDRaeIImkqbs3RD6gMjzp9RFeZ93eNkXfZogPMzV4=;
        b=O6JaHw+KPpdrUDOeW6R3JweCryOxaKZ1qyM+srUU68kzl7tQMTn3Fubc7C6n4qUnon
         KdjjslkS6QaBOrwSXxKVBj+BWuN4srLqJ/gftkcatJ+TPCjh8XJ+oKm3FyJpbGoauHdQ
         NEd8Js3WnoEmUPLfps881ywzbQXNmQ5CZTEmItLHIBQgaJvXn7vOnMzXZXHlm65MRiBp
         EoolPgKBY6IHEKyo/eh2tYflcowYZk0cQMGdEE91NX4gqSm5KyXWtG87nzm4SUMgeXoy
         t9hOG1OgqwB3hgMqWf7xcwYiJlfDZZ1IlM9BFiW3rBEfPxg6Ec496BmL6/CXtSMW7sj9
         Jt5A==
X-Gm-Message-State: APjAAAUQTp7zoUqmofpMBZ+63UPZCcnJIu39e7/qTXbJieyAsR1wI0gT
	/cLaInKD/MlvX5lRmrCWA94oVw2oHId6T8riEnGFrIm2j3OI7CXlpzE6pnLP5s8Pefqew3a5hy1
	+lSnPTXSL9/h7WgLvpfuJ2zuMHX5CaruqRUh5Ac7HzFp+232aVWMQyOpgjtb2PRfwUQ==
X-Received: by 2002:a1c:f205:: with SMTP id s5mr184426wmc.124.1553294989053;
        Fri, 22 Mar 2019 15:49:49 -0700 (PDT)
X-Received: by 2002:a1c:f205:: with SMTP id s5mr184401wmc.124.1553294988382;
        Fri, 22 Mar 2019 15:49:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553294988; cv=none;
        d=google.com; s=arc-20160816;
        b=pI4SqJyVVqN3zTwkfobJniTFKTREF5iFcOALoj+KMYnM7wtv/vZLZqM8aAfhEnlb/R
         0cx0EQi+EKcL+M1H7SMF2dRpr6wPzowvC+I+g/2a1YRxmK7IruFoJCqQP+eDfEdTZmaH
         C+Hpl9fSUPu03W43/5Oa11Gb7dJ5z5TAZF0+Hc94IUwZO3+MqZ7fxBlEN8bKcQ4kPoSn
         CR4wz/524EOsfDApFpVZ9ZLV3kXWS4kSOIq4G1pgsCZglDvEG/KdEZwPuNAwMo9vo4h8
         wqGdfD9h6Zotys/QGULLSKmcrzDjNdIAsPzVMopdwGY6ZqBprV5t/Ne5En7WvbcpSL/t
         Mh9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Y9aDRaeIImkqbs3RD6gMjzp9RFeZ93eNkXfZogPMzV4=;
        b=IhIgC6t8R3syN2zM9L68zibxTJFOtn2A8clVfeuVWHWt5WlcPNxYxH4N+xY/Zx+OY3
         MehpGGBIQgRfgfj9wFyQNv2zkQl6fnGQ/+oRR7GGUquuWKK4fvG/ZqOHxqYOb567rPnt
         omoiv//coYZ+qiObCN4ZCt3hWcYw/S4MIttIeDYW4tvjue/7vQjXd6LZcm093+hr/Vb5
         GVNjj5Exzlru9petRMIka6XTOWSuNgpW/SNdE+vqBRNcOtQuPq1Fhqd+xE4X9HjV1kZ9
         lZiHvf7mknQrMspBulGzkJhdSqkSumAOWB1Bk84pz08Gfx/jcyGBf+Cb0F+7xrFYKlg2
         282g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=dzOycvFR;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d25sor6328962wmb.28.2019.03.22.15.49.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 15:49:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=dzOycvFR;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Y9aDRaeIImkqbs3RD6gMjzp9RFeZ93eNkXfZogPMzV4=;
        b=dzOycvFR3LXcdAJzc1cZuTdB5YuJ4celv5OXmLq76bC6fhuIRBXXymUZ2X1e4X3GPz
         g+RHtQxVTPHKrMHRvLhSlNJtytCLr+c/sSTjz6Ejtz9K6fAOuiJqD90x+aTB17NOUbU2
         C2jzjifh8zT6akDauo5+bFHj33WXlPFIZB7+0=
X-Google-Smtp-Source: APXvYqwdz61zVqNkLMZqtOFJF0lk6vAo9J3Kz5QBK9eFpbbP8HIiqceSQ3TxUDoETV5aA9ODpBzhFQ==
X-Received: by 2002:a1c:ac87:: with SMTP id v129mr4695169wme.72.1553294987958;
        Fri, 22 Mar 2019 15:49:47 -0700 (PDT)
Received: from localhost ([89.36.66.5])
        by smtp.gmail.com with ESMTPSA id u12sm9138257wrt.2.2019.03.22.15.49.47
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 22 Mar 2019 15:49:47 -0700 (PDT)
Date: Fri, 22 Mar 2019 22:49:46 +0000
From: Chris Down <chris@chrisdown.name>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>,
	Dennis Zhou <dennis@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Message-ID: <20190322224946.GA12527@chrisdown.name>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
 <20190322222907.GA17496@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190322222907.GA17496@tower.DHCP.thefacebook.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000071, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Roman Gushchin writes:
>I've noticed that the old version is just wrong: if cgroup_size is way smaller
>than max(min, low), scan will be set to -lruvec_size.
>Given that it's unsigned long, we'll end up with scanning the whole list
>(due to clamp() below).

Are you certain? If so, I don't see what you mean. This is how the code looks 
in Linus' tree after the fixups:

    unsigned long cgroup_size = mem_cgroup_size(memcg);
    unsigned long baseline = 0;

    if (!sc->memcg_low_reclaim)
            baseline = lruvec_size;
    scan = lruvec_size * cgroup_size / protection - baseline;

This works correctly as far as I can tell:

low reclaim case:

    In [1]: cgroup_size=50; lruvec_size=10; protection=2000; baseline=0; lruvec_size * cgroup_size // protection - baseline
    Out[1]: 0

normal case:

    In [2]: cgroup_size=3000; lruvec_size=10; protection=2000; baseline=lruvec_size; lruvec_size * cgroup_size // protection - baseline
    Out[2]: 5

