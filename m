Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13969C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:29:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C923420880
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:29:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C923420880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76C0D6B0005; Fri,  2 Aug 2019 19:29:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71C786B0006; Fri,  2 Aug 2019 19:29:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E61F6B0008; Fri,  2 Aug 2019 19:29:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 240FB6B0005
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 19:29:27 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g18so42527677plj.19
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 16:29:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=B+0t0ogglS9VAynkgfocMcVjM7l/gECF0oB6YeWnVfA=;
        b=XzM5Enw3xGdudVAMo9sOCrOGjB2afvjGnHwaz6TQRwES8IRrqJd4b2jAYIg+IF53l4
         RzXGLH2opfdoQsaN6QIEnGULJojDxV5Z6mSe4Yc31rRsJ+aCkwdSPCiZAt4YCEso2Ep2
         2hDl4xkYbcXPiu/DPOmdmezByaa37ggwzBSHii3EPMZ9kUuFtDHdSqy+Vk6jG9cYq+pQ
         vmiJeLlCXMqIkEyuNmGIdjxDawntR9hpzMaBa6ymq43/vrTb1YXo2SkwPDLuLqNVBQl5
         n4sla3/ZFOJslQtSZW0ZRbK8lmHX/N6Or30vSr9vh4dH9RrU0Tv/88H0VfXQvmjYA2Aw
         a0AQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUoUTpfC0FExcyAbKefD1ke16VfiX8WqjM8aeOSKFitn52DtINR
	qB5V2sG/CN8+ePJ4ZZldS1gs/z0xUV9o7uWainKQv5GgSnFBk3bAEFScMQWnUzyWQkZ8Oeld8LV
	3Jy+R3Nk7dqkBA/kGl7EdVGsedYMeCrbfLOWn0CUKSPxJMXwijguApXRTOfk9sP4=
X-Received: by 2002:a65:684c:: with SMTP id q12mr81067828pgt.405.1564788566678;
        Fri, 02 Aug 2019 16:29:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZwDyj6dZ9+f0rCLGv01RPTi3J5UYy0gcmVqgOLWLLfg95r+juPrKOYGsU0b37QJsvQicK
X-Received: by 2002:a65:684c:: with SMTP id q12mr81067797pgt.405.1564788565820;
        Fri, 02 Aug 2019 16:29:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564788565; cv=none;
        d=google.com; s=arc-20160816;
        b=NUtmssqZ5PTPcL31+M+XjjfS2FJJ4UJxZvIk1PDdYIBIeNvijvYUNHE8afd+F6Flsy
         mNiMJr1VojvwWkSzLPBZdAjjOofvDVegP9QFz+w1FucBMGwoCM+/ruVG+HEEr14EtXOL
         nkqDA8QD1vjfx5nHt27P4DvoDeYuFY9F7i7R5eiY6iDxr/yFGHvTCiZG/v+Yb/3b90qD
         L33LDeypgYEk+ARx037qPtEWilh8LNWNQ570pzwkcO95SESVy1hhyjivut4st+KptKXm
         WBnUXv7J84wC+cIWREodffTXelz/MCpZDYSCzB1mzpjXLfVpwnklaX8XbluyGMY8JLKk
         lbMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=B+0t0ogglS9VAynkgfocMcVjM7l/gECF0oB6YeWnVfA=;
        b=A/gKJ/mPEGU0U06yYG+uIeGBR0VqQPrfs8T6mGB3j8wVtSaAlfttVQXzL6y/xRSGUc
         NsJgdRLa17oIaBFZOyj2KmNqJz+hpuR9NCIlUQh3EvEAy7alsZzaidqe9kx2AAMNsGA+
         BG3kVi7njWJWe+NUA/VCIBQPnEnWhmnOSY0/oG9mhPsChGPbuuDSskjINl4PHaQEdVZV
         PPCKZ13LvJskLz++U4jVeVEFkY66+UWlIQHQIX9zs1Ythi9T4fVir35EZtYuS1Om8XI+
         KQzw4gHa73IvuJuajA7IV9oOAPS9irt54X/8sAapIAjCV6a4TcHsd9nytkMZQVP0+aS0
         PQKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id v7si43544210pfb.132.2019.08.02.16.29.25
        for <linux-mm@kvack.org>;
        Fri, 02 Aug 2019 16:29:25 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 0D1457E4EA2;
	Sat,  3 Aug 2019 09:29:21 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1htgy6-0003vE-9w; Sat, 03 Aug 2019 09:28:14 +1000
Date: Sat, 3 Aug 2019 09:28:14 +1000
From: Dave Chinner <david@fromorbit.com>
To: Chris Mason <clm@fb.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 09/24] xfs: don't allow log IO to be throttled
Message-ID: <20190802232814.GP7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-10-david@fromorbit.com>
 <F1E7CC65-D2CB-4078-9AA3-9D172ECDE17B@fb.com>
 <20190801235849.GO7777@dread.disaster.area>
 <7093F5C3-53D2-4C49-9C0D-64B20C565D18@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7093F5C3-53D2-4C49-9C0D-64B20C565D18@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=clMkuYwxY4VUjy_4T2YA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 02:11:53PM +0000, Chris Mason wrote:
> On 1 Aug 2019, at 19:58, Dave Chinner wrote:
> I can't really see bio->b_ioprio working without the rest of the IO 
> controller logic creating a sensible system,

That's exactly the problem we need to solve. The current situation
is ... untenable. Regardless of whether the io.latency controller
works well, the fact is that the wbt subsystem is active on -all-
configurations and the way it "prioritises" is completely broken.

> framework to define weights etc.  My question is if it's worth trying 
> inside of the wbt code, or if we should just let the metadata go 
> through.

As I said, that doesn't  solve the problem. We /want/ critical
journal IO to have higher priority that background metadata
writeback. Just ignoring REQ_META doesn't help us there - it just
moves the priority inversion to blocking on request queue tags.

> Tejun reminded me that in a lot of ways, swap is user IO and it's 
> actually fine to have it prioritized at the same level as user IO.  We 

I think that's wrong. Swap *in* could have user priority but swap
*out* is global as there is no guarantee that the page being swapped
belongs to the user context that is reclaiming memory.

Lots of other user and kernel reclaim contexts may be waiting on
that swap to complete, so it's important that swap out is not
arbitrarily delayed or susceptible to priority inversions. i.e. swap
out must take priority over swap-in and other user IO because that
IO may require allocation to make progress via swapping to free
"user" file data cached in memory....

> don't want to let a low prio app thrash the drive swapping things in and 
> out all the time,

Low priority apps will be throttled on *swap in* IO - i.e. by their
incoming memory demand. High priority apps should be swapping out
low priority app memory if there are shortages - that's what priority
defines....

> other higher priority processes aren't waiting for the memory.  This 
> depends on the cgroup config, so wrt your current patches it probably 
> sounds crazy, but we have a lot of data around this from the fleet.

I'm not using cgroups.

Core infrastructure needs to work without cgroups being configured
to confine everything in userspace to "safe" bounds, and right now
just running things in the root cgroup doesn't appear to work very
well at all.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

