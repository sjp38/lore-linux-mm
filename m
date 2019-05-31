Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 033E1C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 13:56:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADF7B269DD
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 13:56:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADF7B269DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 197E16B026F; Fri, 31 May 2019 09:56:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14A326B0272; Fri, 31 May 2019 09:56:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 037CD6B027A; Fri, 31 May 2019 09:56:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A6C706B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 09:56:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r48so14095726eda.11
        for <linux-mm@kvack.org>; Fri, 31 May 2019 06:56:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I1P7naRodGCFyc+ZCbKrDsqR+sRhSkr/Jwiv27tzjuA=;
        b=DpsqrR1RR4tivdTFxaOQRGFNHO0hHPDgiUOmKHktJoq8+asPAXUW01lnXJtLiYLZL2
         9nsFGYfSB0nwFemkL/vyZZM2HTmNFYTY0RQQV4o1V7/JGV9Vz6MVVNAHxYNewAlQBHHW
         +RLenAA7S6woTLauaEadkXDLYosU27Xcwn4Y1QAGr2JpmWA6Q9nni/8LgZFEJpTfCuQr
         YVd/KN1M/rXcYYMJWC6HZ7aqOIL6bZL+XhRTvV9IfzWGbMOYa/jzFbz/iFttk8EjG2sf
         iqh1W50gvTUHoLpfzzWzbEE8H6WJqamiFdKV6kjVW1YNy9XGqhprkwFkmbVDDfEnoFke
         t+Vw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX4NU8o8NBrPcB0/Vq2EmI2K/liHnfYrD5vQbYl7seDFqcY1A5c
	6e3u6JzkeJbQitSJCSXJq0umO6+ucbaM7AYjlV0vhpav6NQ4Asdoyw1xBTzct11FsFIdrF73xkB
	gFTBVUgHbXfJ3IOqHPpqJ1vVB/A7cBQjMZnBHVHE/Ja7zK0c08sXTdNl40ThlKR4=
X-Received: by 2002:a17:906:329a:: with SMTP id 26mr9566679ejw.9.1559310984169;
        Fri, 31 May 2019 06:56:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzw3bccV6tsE/ESZPstkDfmOb7jv1RsFpqSzUXjZ/i7UdHnYbG2L+xN85l+/GOYiE79l18u
X-Received: by 2002:a17:906:329a:: with SMTP id 26mr9566615ejw.9.1559310983244;
        Fri, 31 May 2019 06:56:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559310983; cv=none;
        d=google.com; s=arc-20160816;
        b=Cb0tOd2R5qrPMnflAPUlsAB1IEWm+W54EJrp1AKrRnwoJ62aR9A/c1NCy9ER1dkbBH
         4qa9yWDf8RcaNNCIzgjkX9DBS/fZq5QXSXoQlzyM2ubXZN4tKU3gRhPPdKuOqXMC3uo9
         gubGXsbxH/OefRXdhE/GbtQYbu2nz+rRRhLvSiZjZxIPtCIRnho2nzG3HNIGkQupVCHl
         sqOatKISZOD3h9wiDD7dB3q2bbSMbGp2vFMWiKl4EjEneN1USYVPjGfq+DgllT8GP7zr
         CMnZHphgBNkPMLjrmry8BNIMORDHDEKxLu4tyafpHaJ263l3BqrwZlpYG77lcMPv48OX
         6tOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I1P7naRodGCFyc+ZCbKrDsqR+sRhSkr/Jwiv27tzjuA=;
        b=LUm8gNhXvd//aYnToo7G78ybU9EfhlSTWXA39aq5Eljn6PprjSBFUVjZOzdstdqTtY
         MRg9s+/OMDbKw0Pp2P9bSBCKFHd6BU8xVWG9437uxx9+BfJ7Kh5O9450Yd1Ap8um4vj+
         xpGzkV4dqj4aXpIkXVxFrOtH0RGXWPmEeQa50TAG04G7hZZDp7k0IK9oRJ7CqMQG8PjU
         C51rasQo98IUoGwJb6csI/FJzZx2sy7qhJAX9DVpmpZoLmpp/Ijb8KXZjTq1kLRSyJge
         QTta9oYM/jNEZ4F0VZ8N8m7cFjHeAxPmU7/cFFii/CC0p5R2xdbQ9cwRARaacdSEohZt
         ZMmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r22si454172eda.325.2019.05.31.06.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 06:56:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 98465AF21;
	Fri, 31 May 2019 13:56:22 +0000 (UTC)
Date: Fri, 31 May 2019 15:56:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Mel Gorman <mgorman@techsingularity.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: [HELP] How to get task_struct from mm
Message-ID: <20190531135621.GR6896@dhcp22.suse.cz>
References: <5cf71366-ba01-8ef0-3dbd-c9fec8a2b26f@linux.alibaba.com>
 <20190530154119.GF6703@dhcp22.suse.cz>
 <352de468-9091-9866-ccbd-10d80c25ebb4@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <352de468-9091-9866-ccbd-10d80c25ebb4@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 20:51:05, Yang Shi wrote:
> 
> 
> On 5/30/19 11:41 PM, Michal Hocko wrote:
> > On Thu 30-05-19 14:57:46, Yang Shi wrote:
> > > Hi folks,
> > > 
> > > 
> > > As what we discussed about page demotion for PMEM at LSF/MM, the demotion
> > > should respect to the mempolicy and allowed mems of the process which the
> > > page (anonymous page only for now) belongs to.
> > cpusets memory mask (aka mems_allowed) is indeed tricky and somehow
> > awkward.  It is inherently an address space property and I never
> > understood why we have it per _thread_. This just doesn't make any
> > sense to me. This just leads to weird corner cases. What should happen
> > if different threads disagree about the allocation affinity while
> > working on a shared address space?
> 
> I'm supposed (just my guess) such restriction should just apply for the
> first allocation. Just like memcg charge, who does it first, whose policy
> gets applied.

I am not really sure that was the deliberate design choice. Maybe
somebody has a different recollection though.

> > > The vma that the page is mapped to can be retrieved from rmap walk easily,
> > > but we need know the task_struct that the vma belongs to. It looks there is
> > > not such API, and container_of seems not work with pointer member.
> > I do not think this is a good idea. As you point out in the reply we
> > have that for memcgs but we really hope to get rid of mm->owner there
> > as well. It is just more tricky there. Moreover such a reverse mapping
> > would be incorrect. Just think of a disagreeing yet overlapping cpusets
> > for different threads mapping the same page.
> > 
> > Is it such a big deal to document that the node migrate is not
> > compatible with cpusets?
> 
> Not only cpuset, but get_vma_policy() also needs find task_struct from vma.
> Currently, get_vma_policy() just uses "current", so it just returns the
> current process's mempolicy if the vma doesn't have mempolicy. For the node
> migrate case, "current" is definitely not correct.
>
> It looks there is not an easy way to workaround it unless we claim node
> migrate is not compatible with both cpusets and mempolicy.

yep, it seems so.
-- 
Michal Hocko
SUSE Labs

