Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9861AC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:38:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5465B206B6
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:38:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5465B206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F28A06B0005; Wed, 17 Apr 2019 09:38:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFF0A6B0007; Wed, 17 Apr 2019 09:38:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E15E16B0008; Wed, 17 Apr 2019 09:38:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9207C6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:38:56 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o8so12015538edh.12
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:38:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zzbTahPvFzJAf/J/iaw3D5L2MX0o0O0EXoJ7XjyE06M=;
        b=akDPKWX6iyQ81cC29UAi4+5/BclrNJmeffTSM7hmNcrqCMJjS7t5Z8H95jITE/ercJ
         6cg5LwMUtOpPizLWjD/nEEl8b/IrfvlTuDulDMyzAsGwVqCfdsF6KUMK/ajrATkAbnNO
         ToWcJpxEYNJxmjKpJNKVq1aCL8d1R43i8I+O4X8BJGaJJsPEKFrUIi2y0a6h2HZhrgTE
         kxrR7wRhV9+dL8PNmzhbt76xDvUf/Scgfu1kI/K4Xxa99gUlYlQnzYUA+HqNGAVDBGBt
         +Oa2VfsFXhsm9i7XFBHwaALVv+FU4Wgzeoh9zWFpokrqBIo2Fm2K366GakhI8Xz2lvJl
         UGPg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXU9/pUvuAvoBCD8SHRBs4VTjTdnaza2rPL4bK1nTyy6BJqXKOr
	xH2WGK5obERc0CD9s2NFMEYR3Llyl3o9j2eBMw7vK5G2M8rPhevlWMDiZp1TexJcQV9QGkw/Je/
	ZDDYIvt/vltv2WnTUEhowR7uc2XMWQCzQwc0P+J34lYK/WCLT42G8PAM5jw/IAAs=
X-Received: by 2002:a17:906:d1d9:: with SMTP id bs25mr22942402ejb.213.1555508336103;
        Wed, 17 Apr 2019 06:38:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6Sp63y1pLjM26cQibLcspzXtzpdUApZemtc/xweFP0LhjmsGyuWqPyr6SqwKXZxur5QJh
X-Received: by 2002:a17:906:d1d9:: with SMTP id bs25mr22942371ejb.213.1555508335191;
        Wed, 17 Apr 2019 06:38:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555508335; cv=none;
        d=google.com; s=arc-20160816;
        b=t5g/Ab8tZ9yRwMSpzZ7KFUcpBYSKMAA7Xa8FrH6FFW5K//tqmp5TGI1e0Cyv4nuOwA
         JwazZvJDiEI/HPqV2+ECnWZwBSBBVG/CtZHSKY8So7xfinIX/3yiUP9h4cwx7dy0/mfg
         roeESp/1dGKGgskvDrRVtQoi0Heo4RgszrFGFdgY3Y77iVG9BahY+FMSV5mDDvfpuEr9
         Eljuhci9gKL7qqPmmPOcjmUylFhBBXfnY72l7b9v7nRqiUtWseKz79UsDFemNADsDlCq
         HqeHJsEgDIXrzMqGZ0dULtsciCMjZIeCo9o5anBgXTx5euvGwoGTagQ+/tuA7vHem55T
         RKWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zzbTahPvFzJAf/J/iaw3D5L2MX0o0O0EXoJ7XjyE06M=;
        b=c/FdA288tBQbxX5xqMoY3OppNqmojFUFb/G1IrtlSavDWTb0THWk9ik0kGYcEsnsZg
         fxHO+OhF6AbEXyub+TIBEXVC0Mj9WOvH5uLj4QiVUCEPygiFi4vAQ80mHx6s/BEPuCWR
         f6BQNjbTOEskiHo6zcAynRz3MawZ9T7ZP+s7hpS3XfpoD2ujcpTNvmE2tqOLJ7lS2Z1/
         b7xVuJDThbvrdN7P0MPGqo6i25UgJIrRINX1mfQqx48V2Jzr9gwZ7eTX0EVrq6wsC+9b
         cMS7GmbRomzmAGCeZ/6SS8Qb65lMtiXXC4ODd9u46HOv1eZJSUusRmz+b8n9lbQL5TJd
         O16Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v16si6028768ejj.329.2019.04.17.06.38.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 06:38:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7D129B174;
	Wed, 17 Apr 2019 13:38:54 +0000 (UTC)
Date: Wed, 17 Apr 2019 15:38:52 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jesper Dangaard Brouer <netdev@brouer.com>
Cc: Pekka Enberg <penberg@iki.fi>, "Tobin C. Harding" <me@tobin.cc>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Mel Gorman <mgorman@techsingularity.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
Message-ID: <20190417133852.GL5878@dhcp22.suse.cz>
References: <20190410024714.26607-1-tobin@kernel.org>
 <f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
 <20190410081618.GA25494@eros.localdomain>
 <20190411075556.GO10383@dhcp22.suse.cz>
 <262df687-c934-b3e2-1d5f-548e8a8acb74@iki.fi>
 <20190417105018.78604ad8@carbon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417105018.78604ad8@carbon>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 10:50:18, Jesper Dangaard Brouer wrote:
> On Thu, 11 Apr 2019 11:27:26 +0300
> Pekka Enberg <penberg@iki.fi> wrote:
> 
> > Hi,
> > 
> > On 4/11/19 10:55 AM, Michal Hocko wrote:
> > > Please please have it more rigorous then what happened when SLUB was
> > > forced to become a default  
> > 
> > This is the hard part.
> > 
> > Even if you are able to show that SLUB is as fast as SLAB for all the 
> > benchmarks you run, there's bound to be that one workload where SLUB 
> > regresses. You will then have people complaining about that (rightly so) 
> > and you're again stuck with two allocators.
> > 
> > To move forward, I think we should look at possible *pathological* cases 
> > where we think SLAB might have an advantage. For example, SLUB had much 
> > more difficulties with remote CPU frees than SLAB. Now I don't know if 
> > this is the case, but it should be easy to construct a synthetic 
> > benchmark to measure this.
> 
> I do think SLUB have a number of pathological cases where SLAB is
> faster.  If was significantly more difficult to get good bulk-free
> performance for SLUB.  SLUB is only fast as long as objects belong to
> the same page.  To get good bulk-free performance if objects are
> "mixed", I coded this[1] way-too-complex fast-path code to counter
> act this (joined work with Alex Duyck).
> 
> [1] https://github.com/torvalds/linux/blob/v5.1-rc5/mm/slub.c#L3033-L3113

How often is this a real problem for real workloads?

> > For example, have a userspace process that does networking, which is 
> > often memory allocation intensive, so that we know that SKBs traverse 
> > between CPUs. You can do this by making sure that the NIC queues are 
> > mapped to CPU N (so that network softirqs have to run on that CPU) but 
> > the process is pinned to CPU M.
> 
> If someone want to test this with SKBs then be-aware that we netdev-guys
> have a number of optimizations where we try to counter act this. (As
> minimum disable TSO and GRO).
> 
> It might also be possible for people to get inspired by and adapt the
> micro benchmarking[2] kernel modules that I wrote when developing the
> SLUB and SLAB optimizations:
> 
> [2] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm

While microbenchmarks are good to see pathological behavior, I would be
really interested to see some numbers for real world usecases.
 
> > It's, of course, worth thinking about other pathological cases too. 
> > Workloads that cause large allocations is one. Workloads that cause lots 
> > of slab cache shrinking is another.
> 
> I also worry about long uptimes when SLUB objects/pages gets too
> fragmented... as I said SLUB is only efficient when objects are
> returned to the same page, while SLAB is not.

Is this something that has been actually measured in a real deployment?
-- 
Michal Hocko
SUSE Labs

