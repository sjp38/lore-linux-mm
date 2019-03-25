Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F15A7C10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 23:42:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE1662084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 23:42:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="pfdpTNH3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE1662084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B3A56B0003; Mon, 25 Mar 2019 19:42:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 462956B0006; Mon, 25 Mar 2019 19:42:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 305126B0007; Mon, 25 Mar 2019 19:42:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 001296B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 19:42:13 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id o132so4558524oib.5
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 16:42:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=brbNukUZJqv8C4b8aKpAXrJlBkgotqWH0iKEU/UDCkc=;
        b=HpCG7b02f+XPBW19EvFLOpkq7RB1c/pWq2LbrRkxmrkGaY46wkHFwh2ET+s/dTS2uU
         pT0Q0KUlwOY74SWhdncEUw7HVa9d5/hRwZq6w3bCICU/QaR7ZZmx7f+S0zPMHqANJ8Mo
         FpA+5DKqOsERlk6UoDW0PBJLzY6TzBIB6DZ/TJtBUzutiHXsSmwJFcq5gu+ZDiTwDymw
         cP6SVsfg1nzm1yp2WpFxXqOliCRyUoANhRlrARMdHn0Wm6frlCMyJh0353spZJ6B96jt
         zxyPaPe4ZXOY4aD9vHBEb2ikMTpkIvqgXzwiiVB0/SRe/GuQng3bc60Z6GumexdV3jqT
         Iypw==
X-Gm-Message-State: APjAAAUYZnJR9Nu/bc5i5zGA0KiyrIpmZ3mmdrf0aS7qOICoB4mlpHWA
	715g+ol4vFzyD4E64cF4H04gcRXKgusJiAEZCOCGkjKxzhOdoslDCz4z6T1F13kZWL9iC6D66A8
	HKiu3bCW72osrxA5rdrhFH4mpRyny7Nz81G6HfWpVp5UV8JoskIh/AiWcvvvIn03DLg==
X-Received: by 2002:a05:6830:1592:: with SMTP id i18mr16925672otr.244.1553557333708;
        Mon, 25 Mar 2019 16:42:13 -0700 (PDT)
X-Received: by 2002:a05:6830:1592:: with SMTP id i18mr16925639otr.244.1553557332924;
        Mon, 25 Mar 2019 16:42:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553557332; cv=none;
        d=google.com; s=arc-20160816;
        b=DkNi9hekFypFN/xnT3bp0fWanuvZn/3zuR4LO5AIEPq8Hj8sez16aFao5ufKNC3WcD
         9YISDrMAS0A8KF2nPltwKnM5Qr+XZyjiQcXJ4HvMtgZysVzGPbqPCOsf1OoZm3xSNJIu
         UOQJD1RShewArkP3G1+FvCrnSFUShzSZWUVQmKdDji5IXFH5mcVV/voiXSQUzd5FEzm3
         ezFtb/HI6a1edG6q1GFsSKxczaBeuCudb+nUsrx7wYoVrYi+HLI2vIk4IRPnKnZgHFK2
         syMxVn9UJZ4t+F17Zr3wVh7jNXl2aDDRCZhMZjXiQRm1OJwLaj1nJexdHRhDNQo3+3Zr
         F75A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=brbNukUZJqv8C4b8aKpAXrJlBkgotqWH0iKEU/UDCkc=;
        b=SuB6X32tyjHsmgpKC76+8f3SDU1nmojSC5Mze5Zd9dEtq2KIzWUbo9bZsHNtTZZDcZ
         yYM+3MA9jXjSYNrdJZa00q2sGdPrnY0FMdxHeK+oHVxIeoaqQoVkFoXgPKgaQT+4NEOA
         OEaJJY9HQPRXl1BXlpe5aNFC2U3e0qlhqHBITVWx3K4yJEqIwYpe27NtKgZLAtus5mCa
         ziq0XZUdIfGk2tz9d+VoAH1f33/XrzoT6vGOkq4Gvm41itw58wdumuMOWY/M497FCrO9
         ALW1SCLTHM9nI+ZsHnWOSVOH7JxxEHWV5SBaXj5paDpne1lCurwS5iMDYttC2egJ8wHS
         /Rxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=pfdpTNH3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w23sor39336otk.38.2019.03.25.16.42.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 16:42:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=pfdpTNH3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=brbNukUZJqv8C4b8aKpAXrJlBkgotqWH0iKEU/UDCkc=;
        b=pfdpTNH3kMtoL8jz01jwkZ8HTaSp6GdZcMydIuMPWTRr7qH8mqJiOhi04rVWFjHfI2
         i1J4MxrfKqoydzGIQTP0YUs5lSrZqClnJLTW4PdCJduTEWcQw/cTVlL+kDn0QtVlUCw2
         5LdAVRJV15QUklVMWeWQ4erbA/D0cak87OIZ2xc+oWPb7XsJgXjL9v5lD4r6dGhjCfIs
         abnPCXt2NYePh+o/9L1zR0QbKjXAsGu+4MunONZAeezqBUhDxbSiyeftp+8E36O+8yPB
         lJbjC62zGS1t0qCUz569etjL+B2dZUSKuNtp8oYj4wLGYYZTLoVoSH535daHwu8i7fXR
         Ygng==
X-Google-Smtp-Source: APXvYqyg8lWmRXsXdSMNbDrwiKoh3GF/oAwMMkgZ0rAcnw8htq21c8WLRwG+lDz+A4nlb93mvhOClYHlgNMmOjj0Qbo=
X-Received: by 2002:a9d:4d0b:: with SMTP id n11mr18663296otf.98.1553557332317;
 Mon, 25 Mar 2019 16:42:12 -0700 (PDT)
MIME-Version: 1.0
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-2-git-send-email-yang.shi@linux.alibaba.com>
 <CAPcyv4g5RoHhXhkKQaYkqYLN1y3KavbGeM1zVus-3fY5Q+JdxA@mail.gmail.com>
 <688dffbc-2adc-005d-223e-fe488be8c5fc@linux.alibaba.com> <CAPcyv4g3xzuS8hP9jOX_BXWyFEH32YfCEDs3a_K_VRODfATc=Q@mail.gmail.com>
 <406a78f6-9bac-b0f8-9acc-b72540a72a11@linux.alibaba.com>
In-Reply-To: <406a78f6-9bac-b0f8-9acc-b72540a72a11@linux.alibaba.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 25 Mar 2019 16:42:01 -0700
Message-ID: <CAPcyv4iH72ppy+=c3BitJ=qxJAFvpNza6Y5yz01Rt1Tky=MZNA@mail.gmail.com>
Subject: Re: [PATCH 01/10] mm: control memory placement by nodemask for two
 tier main memory
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, 
	Keith Busch <keith.busch@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	"Du, Fan" <fan.du@intel.com>, "Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Vishal L Verma <vishal.l.verma@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 4:36 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
[..]
> >>> Hmm, no, I don't think we should do this. Especially considering
> >>> current generation NVDIMMs are energy backed DRAM there is no
> >>> performance difference that should be assumed by the non-volatile
> >>> flag.
> >> Actually, here I would like to initialize a node mask for default
> >> allocation. Memory allocation should not end up on any nodes excluded by
> >> this node mask unless they are specified by mempolicy.
> >>
> >> We may have a few different ways or criteria to initialize the node
> >> mask, for example, we can read from HMAT (when HMAT is ready in the
> >> future), and we definitely could have non-DRAM nodes set if they have no
> >> performance difference (I'm supposed you mean NVDIMM-F  or HBM).
> >>
> >> As long as there are different tiers, distinguished by performance, for
> >> main memory, IMHO, there should be a defined default allocation node
> >> mask to control the memory placement no matter where we get the information.
> > I understand the intent, but I don't think the kernel should have such
> > a hardline policy by default. However, it would be worthwhile
> > mechanism and policy to consider for the dax-hotplug userspace
> > tooling. I.e. arrange for a given device-dax instance to be onlined,
> > but set the policy to require explicit opt-in by numa binding for it
> > to be an allocation / migration option.
> >
> > I added Vishal to the cc who is looking into such policy tooling.
>
> We may assume the nodes returned by cpu_to_node() would be treated as
> the default allocation nodes from the kernel point of view.
>
> So, the below code may do the job:
>
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index d9e0ca4..a3e07da 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -764,6 +764,8 @@ void __init init_cpu_to_node(void)
>                          init_memory_less_node(node);
>
>                  numa_set_node(cpu, node);
> +
> +              node_set(node, def_alloc_nodemask);
>          }
>   }
>
> Actually, the kernel should not care too much what kind of memory is
> used, any node could be used for memory allocation. But it may be better
> to restrict to some default nodes due to the performance disparity, for
> example, default to regular DRAM only. Here kernel assumes the nodes
> associated with CPUs would be DRAM nodes.
>
> The node mask could be exported to user space to be override by
> userspace tool or sysfs or kernel commandline.

Yes, sounds good.

> But I still think kernel does need a default node mask.

Yes, just depends on what is less surprising for userspace to contend
with by default. I would expect an unaware userspace to be confused by
the fact that the system has free memory, but it's unusable. So,
usable by default sounds a safer option, and special cases to forbid
default usage of given nodes is an administrator / application opt-in
mechanism.

