Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E651C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:50:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2DFD21773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:50:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brouer-com.20150623.gappssmtp.com header.i=@brouer-com.20150623.gappssmtp.com header.b="v/hGZ1f5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2DFD21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brouer.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CDDE6B0003; Wed, 17 Apr 2019 04:50:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37F286B0006; Wed, 17 Apr 2019 04:50:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26F806B0007; Wed, 17 Apr 2019 04:50:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACF5F6B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:50:25 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id m85so4775565lje.19
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:50:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:organization:mime-version
         :content-transfer-encoding;
        bh=qnWCBlM9SFBUmDRR+A8TsvVH6yTv02dm2O49KOiT/Vg=;
        b=iFZtcRLQyiCs4bSQt8/1sXuPOxLE1SfY7fk8xrAtXhILOhQEQWDN1XoS2mcV72+U5z
         iUU0p5uj37xqzQ2EDWpcEz0NUhH5BxGnwV+jMrTcMJvzg8D2+pbMAkMKM1LKnzXBZeiP
         C/pVqj8q1b65Zg7sUO5Y+F4tH2uCDavPV3H0O7EWQEYrLOiogR9340LOd4VS3AOXM86o
         DEPGxzZoFfICiwWeAFkFn8WjRFBTclJJrcI2LKRH0jHNWAWD6fVdjsPS79MuDf3/WO0g
         YT4R7L+tlUVebWg+v1vu1YUxWcWyqxgHVLATtmII0T7UycAjXEtly++RhpF4jV1nNHwN
         HtXA==
X-Gm-Message-State: APjAAAUbJCC1QoTfjgAgKqeBRPU6FJ9KDptUtb17U0WfkAwdB00ue2lN
	Z6UUW6D66bMqp+j5DiUTghxkHkybmglG6C4cRH2h+BKQSM68ZhqzfobeW94mXSfq+26Q7MppQi/
	XlC5aFDzNa0CT6wD3rfUFTFaj3phezIuLircoaiNXpC1oBh6DHBh4evfdqjzF8E76Hg==
X-Received: by 2002:a2e:6e14:: with SMTP id j20mr29795243ljc.172.1555491024805;
        Wed, 17 Apr 2019 01:50:24 -0700 (PDT)
X-Received: by 2002:a2e:6e14:: with SMTP id j20mr29795188ljc.172.1555491023576;
        Wed, 17 Apr 2019 01:50:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555491023; cv=none;
        d=google.com; s=arc-20160816;
        b=XXdkBrc+ZoxDNmgKq7Q0Ev0Q0ZGf5PszDSs4fjnDpTKCPT5rEAEVq6v5kfuNG5j5LR
         Ss9c+sW/3l/RnHdGGkJlaDads/D1X0ryPT/GvZ75pMmvdOn9WG83Mt9U+ig33p5k7uwE
         JHjUAuI8cRo74n291rsRVuu749Xzmb5tL/fJyjQUGABqk0DbTUWjLzG/dBMwXkoHu7vD
         HcJTT3srI4bUb8cpcmWdrZD1IsXoslFTMXyvN9Y03NO1QJ8NV/b5/Cdjzagg1eWndJtD
         LzknMDCPX//7upQO+w5LKMR7RISsrmsh2FMEcCzF8NOWY03Shml3OW4EhILc5cM9zwVx
         RU+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=qnWCBlM9SFBUmDRR+A8TsvVH6yTv02dm2O49KOiT/Vg=;
        b=Iastx4Zcu8CFc5lASvWm/0qKji2c/Y/yghgzD6lvkQjATTVa4CG1/z+Pmj6em1VKgX
         bfZWAnMDRLJT5hCItiaQkHVtnwrD7NooImp0+/VCv7+ZI8IqKxAa5i9NWCHiD1m9OVo8
         hWzfFjKF1TvSGHwhPpeWy/fy5jsAlzLknFS+9g/KoCG0gQULPimbyXBO8fAP3UVENiEA
         HMsDIkO9xpLMjTDMLtRNLjzDsgbeJ7Pd1jrZYBiSF9hXJIjftuHS29ZHyUXwN0WRYxKq
         h8D9WgmpfFSzR3oXcyyaKihgUsvbTJgRghmMCm4W/rPC9NRoNAAX6W1dEizscSfH++wU
         JaYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brouer-com.20150623.gappssmtp.com header.s=20150623 header.b="v/hGZ1f5";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of netdev@brouer.com) smtp.mailfrom=netdev@brouer.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b10sor34139819ljk.35.2019.04.17.01.50.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 01:50:23 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of netdev@brouer.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brouer-com.20150623.gappssmtp.com header.s=20150623 header.b="v/hGZ1f5";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of netdev@brouer.com) smtp.mailfrom=netdev@brouer.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brouer-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :organization:mime-version:content-transfer-encoding;
        bh=qnWCBlM9SFBUmDRR+A8TsvVH6yTv02dm2O49KOiT/Vg=;
        b=v/hGZ1f53eTD32V2VFQhFuLi5dQw5P/ejWYxs7PYgiTLsS2k6X+2urxmVU7xYoikJp
         naKK/s4iAO2FWjzKybTXloRELpOhUkqNfWKqMOCWVKJ7ytZ1kSvHhBxQGgMFUNfpVyLN
         B0/SwwcNB3wqc6iAiCPK85wwjM90ZndT8zG7hLbaYb0oV8Hti9OgMO7g8hIQWgFN6nDV
         vzyCmeJWYj2kZ0ptumLh04qyYOuoIqJFlaneyNHpevTNGWXzG+lA8TorOFJTuLKexmGu
         3UIYmul2GyvyWkyp+n4ng78FNtIVULvvHqsOJy4Nzjk/GUwnyq/KsfCyWaUxGxLFbQ2d
         r6nA==
X-Google-Smtp-Source: APXvYqz1/mxhYc8RhNzAJ0ZoMX+koD42ryEcAcylM7bFqCOPK3SEaW7zD0vqbSz6hnd1nL+ZU9msCg==
X-Received: by 2002:a2e:9719:: with SMTP id r25mr6784693lji.29.1555491023092;
        Wed, 17 Apr 2019 01:50:23 -0700 (PDT)
Received: from carbon (80-167-222-154-cable.dk.customer.tdc.net. [80.167.222.154])
        by smtp.gmail.com with ESMTPSA id v4sm7754208ljh.40.2019.04.17.01.50.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 17 Apr 2019 01:50:22 -0700 (PDT)
Date: Wed, 17 Apr 2019 10:50:18 +0200
From: Jesper Dangaard Brouer <netdev@brouer.com>
To: Pekka Enberg <penberg@iki.fi>
Cc: Michal Hocko <mhocko@kernel.org>, "Tobin C. Harding" <me@tobin.cc>,
 Vlastimil Babka <vbabka@suse.cz>, "Tobin C. Harding" <tobin@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter
 <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes
 <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo
 <tj@kernel.org>, Qian Cai <cai@lca.pw>, Linus Torvalds
 <torvalds@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Alexander Duyck
 <alexander.duyck@gmail.com>
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
Message-ID: <20190417105018.78604ad8@carbon>
In-Reply-To: <262df687-c934-b3e2-1d5f-548e8a8acb74@iki.fi>
References: <20190410024714.26607-1-tobin@kernel.org>
	<f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
	<20190410081618.GA25494@eros.localdomain>
	<20190411075556.GO10383@dhcp22.suse.cz>
	<262df687-c934-b3e2-1d5f-548e8a8acb74@iki.fi>
Organization: Red Hat Inc.
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Apr 2019 11:27:26 +0300
Pekka Enberg <penberg@iki.fi> wrote:

> Hi,
> 
> On 4/11/19 10:55 AM, Michal Hocko wrote:
> > Please please have it more rigorous then what happened when SLUB was
> > forced to become a default  
> 
> This is the hard part.
> 
> Even if you are able to show that SLUB is as fast as SLAB for all the 
> benchmarks you run, there's bound to be that one workload where SLUB 
> regresses. You will then have people complaining about that (rightly so) 
> and you're again stuck with two allocators.
> 
> To move forward, I think we should look at possible *pathological* cases 
> where we think SLAB might have an advantage. For example, SLUB had much 
> more difficulties with remote CPU frees than SLAB. Now I don't know if 
> this is the case, but it should be easy to construct a synthetic 
> benchmark to measure this.

I do think SLUB have a number of pathological cases where SLAB is
faster.  If was significantly more difficult to get good bulk-free
performance for SLUB.  SLUB is only fast as long as objects belong to
the same page.  To get good bulk-free performance if objects are
"mixed", I coded this[1] way-too-complex fast-path code to counter
act this (joined work with Alex Duyck).

[1] https://github.com/torvalds/linux/blob/v5.1-rc5/mm/slub.c#L3033-L3113


> For example, have a userspace process that does networking, which is 
> often memory allocation intensive, so that we know that SKBs traverse 
> between CPUs. You can do this by making sure that the NIC queues are 
> mapped to CPU N (so that network softirqs have to run on that CPU) but 
> the process is pinned to CPU M.

If someone want to test this with SKBs then be-aware that we netdev-guys
have a number of optimizations where we try to counter act this. (As
minimum disable TSO and GRO).

It might also be possible for people to get inspired by and adapt the
micro benchmarking[2] kernel modules that I wrote when developing the
SLUB and SLAB optimizations:

[2] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm


> It's, of course, worth thinking about other pathological cases too. 
> Workloads that cause large allocations is one. Workloads that cause lots 
> of slab cache shrinking is another.

I also worry about long uptimes when SLUB objects/pages gets too
fragmented... as I said SLUB is only efficient when objects are
returned to the same page, while SLAB is not.


I did a comparison of bulk FREE performance here (where SLAB is
slightly faster):
 Commit ca257195511d ("mm: new API kfree_bulk() for SLAB+SLUB allocators")
 [3] https://git.kernel.org/torvalds/c/ca257195511d

You might also notice how simple the SLAB code is:
  Commit e6cdb58d1c83 ("slab: implement bulk free in SLAB allocator")
  [4] https://git.kernel.org/torvalds/c/e6cdb58d1c83


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

