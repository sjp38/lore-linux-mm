Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11622C4360F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 20:12:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A37E920880
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 20:12:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A37E920880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B4B36B0003; Mon,  1 Apr 2019 16:12:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 165E86B0005; Mon,  1 Apr 2019 16:12:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0555D6B0007; Mon,  1 Apr 2019 16:12:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A93F96B0003
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 16:12:05 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c40so4849164eda.10
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 13:12:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=G73esi3IaIN9rcdTmb9b44/QMDQN8tLuDYDzwIrgtcc=;
        b=TDQx0phVHySn06lBx6ijIYYgEH/Zx9UdhEIPrIp1dkzIhJHOdRqve+PxRsa/4VJeFx
         cxRv8Kv7UkNZ+aVeMeg40fD1RJtNidPUlj7rVgmgKprpPWtZfsK5M8FhG+mpVzVdQXuc
         mPRgwi32pPvRLbTP1Tutwomf98xGUzRnrHu1qZjm1DWHMJNYXEo2vKOzMEEArIIoDGMK
         IPvmSdpL2cFSt4Wex+UDVA9p6ER65I7xwQgkcxHwC42IoG7lOzYGA9m0VtQ8l0xPSwAZ
         wRYMbxGYQ2Os0UDh4HoXjleZiVFjKyL21eKjHCrbFZKqudpHDobnvSWyZerpUePlP3JM
         nfww==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXzlnbnEPVKeipa+N0TMdFfCfqPCYWPY36FF+9Ofh5q2Q4dw53O
	F9WUspdw4OjTXhovL5lcVlajVq1KyCNPxN0IhUetXT5jwQObK2GcFOCxFCMSrCNtNXgYNP5ookM
	qCIdDoKaA7qj/EGl4g/KdEMxGh7QoukOhMB1uearFHsEQqzlO0QlAcv4If8JruOg=
X-Received: by 2002:a50:aa4d:: with SMTP id p13mr44521503edc.17.1554149525095;
        Mon, 01 Apr 2019 13:12:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSIcLpYM+Vgg6rEbkGXeItU766JNnB5C9/CIcNG30paED9GTlfM+yeJ5TORwWdO2LSdJar
X-Received: by 2002:a50:aa4d:: with SMTP id p13mr44521459edc.17.1554149524059;
        Mon, 01 Apr 2019 13:12:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554149524; cv=none;
        d=google.com; s=arc-20160816;
        b=oeDGAGIrjQ5PChcZQ7/6Ry8rcziZHZ8pV5VYhKnAeACihSXMwMgk4d6fVkf+SuQehD
         44Gr/lt3GqF2Hue7GdvI+sxRFULEhW/FWBDIR/1yzTJlWPKXl6EtMOoXadPi9AqoPy7u
         JjGvh0TfVLHiAEES+7FuZaVmp7qhauBKogBOEFlSyOJTpV3eEgBncKixaAfJ+4w9VUjh
         59v17nMR3HOd7c873/Sej6MCgZhPZNXD6zVjTKzRAguYV6EBY8jWbSVJy2f2pXyoGAQc
         4JQav5iw2oiyCh4RxABqRRQpFYCaQqDWeSO4uiushuQuSWzG+uNrGVXr6kpn+/9Kv/EI
         GDUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=G73esi3IaIN9rcdTmb9b44/QMDQN8tLuDYDzwIrgtcc=;
        b=jca0lc77nxoggfVDZP2Bon15W6ECi/s1IqwfOnmw724zLJF+Vu1AJYdDSM7qkhPJWU
         C58MNC00IU9cqHX2lxzIwrXTAFd+q/ahRS/0/87AJ6YCLWVViFnIqImnc3QKuS8ZJSQG
         JL8rddznayeC7VWVJ3XsERVCyyh8C3j8fscFpTF75M7tHx6hvL1EEI/apmGeby8piWZt
         fRYYWzMccu9l6YQfX3upMjJY67nvEirU8Oh1sWzfcgN6xWE0Zmu3kW92QsJnSEEv481g
         1BpkSJorpH/7X/2HLIc9UMgqB1qYUDVlmFwiC6SjRTv2wH8Qnz4AfDpVx268SM+BbyTH
         ms+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p23si1783289eju.122.2019.04.01.13.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 13:12:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 615C3AC7E;
	Mon,  1 Apr 2019 20:12:03 +0000 (UTC)
Date: Mon, 1 Apr 2019 22:12:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>,
	akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190401201201.GJ28293@dhcp22.suse.cz>
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
 <20190327172955.GB17247@arrakis.emea.arm.com>
 <20190327182158.GS10344@bombadil.infradead.org>
 <20190328145917.GC10283@arrakis.emea.arm.com>
 <20190329120237.GB17624@dhcp22.suse.cz>
 <20190329161637.GC48010@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329161637.GC48010@arrakis.emea.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 29-03-19 16:16:38, Catalin Marinas wrote:
> On Fri, Mar 29, 2019 at 01:02:37PM +0100, Michal Hocko wrote:
> > On Thu 28-03-19 14:59:17, Catalin Marinas wrote:
> > [...]
> > > >From 09eba8f0235eb16409931e6aad77a45a12bedc82 Mon Sep 17 00:00:00 2001
> > > From: Catalin Marinas <catalin.marinas@arm.com>
> > > Date: Thu, 28 Mar 2019 13:26:07 +0000
> > > Subject: [PATCH] mm: kmemleak: Use mempool allocations for kmemleak objects
> > > 
> > > This patch adds mempool allocations for struct kmemleak_object and
> > > kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> > > under memory pressure. The patch also masks out all the gfp flags passed
> > > to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> > 
> > Using mempool allocator is better than inventing its own implementation
> > but there is one thing to be slightly careful/worried about.
> > 
> > This allocator expects that somebody will refill the pool in a finit
> > time. Most users are OK with that because objects in flight are going
> > to return in the pool in a relatively short time (think of an IO) but
> > kmemleak is not guaranteed to comply with that AFAIU. Sure ephemeral
> > allocations are happening all the time so there should be some churn
> > in the pool all the time but if we go to an extreme where there is a
> > serious memory leak then I suspect we might get stuck here without any
> > way forward. Page/slab allocator would eventually back off even though
> > small allocations never fail because a user context would get killed
> > sooner or later but there is no fatal_signal_pending backoff in the
> > mempool alloc path.
> 
> We could improve the mempool code slightly to refill itself (from some
> workqueue or during a mempool_alloc() which allows blocking) but it's
> really just a best effort for a debug tool under OOM conditions. It may
> be sufficient just to make the mempool size tunable (via
> /sys/kernel/debug/kmemleak).

The point I've tried to make is that you really have to fail at some
point but mempool is fundamentally about non-failing as long as the
allocation is sleepable. And we cannot really break that assumptions
because existing users really depend on it. But as I've said I would try
it out and see. This is just a debugging feature and I assume that a
really fatal oom caused by a real memory leak would be detected sooner
than the whole thing just blows up.
-- 
Michal Hocko
SUSE Labs

