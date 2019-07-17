Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37D37C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 05:35:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAF4020818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 05:35:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAF4020818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CBC76B0003; Wed, 17 Jul 2019 01:35:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87D286B0005; Wed, 17 Jul 2019 01:35:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76BF28E0001; Wed, 17 Jul 2019 01:35:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 26DD26B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 01:35:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so17304341edt.4
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 22:35:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vaYjibo0IOC09JUFY8G2xxjYHdHkXbwPhY4d+akquT4=;
        b=g/YmwSXzKvOeWvzZZ6nerNfTTP22MoqWw1Yw1ankVcteaDdjeCBRwuFdyGMGVm6Zdz
         RocBKVSnnlgpL9FBFJs4UpWW91wZjdsZ9rFVR8g9XRtmHmHZpNGR4g7hKf6wTohysYxw
         cK5LK1kMwIoUWDTl+2PJuDEqTG1rLAxc+Uvh1ndYIzt2DtCfbLBNKNbxJoL/N1J81P85
         URfRvbsMi5yaME3QI0fD/C0nbk/N0HXIaAUdShrjZroea/9FgvsZpooxbGMzYWA6HmZZ
         H61BgvN+wnjbTvQB85YLe5cf0pZOp86RaLSINXasncr2CXpE51GVtvXkUlJyJSnz0bvk
         Ehzg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXZHzHlHFaeg3FWdZgjSw7tZs7vxVsB1v4kqEtwRUNXLjroDO7m
	tBtpEI/DVdlb2h1WyPQiVk8ewPIMKcXmEeq8DCto4kHDHcJy7NBWdyNCoFtUgpwEnG91uKrXJBf
	EFmwxFwfXedQMzcFGgekz5KMvB+Ha0J7OWCUyYA2TjY2sJY7qhTYQoXFyJp1zepA=
X-Received: by 2002:aa7:d404:: with SMTP id z4mr33037057edq.131.1563341724612;
        Tue, 16 Jul 2019 22:35:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCDYdWHbj+X51pD8uyrSHgSumhK9hU7YDAsOBr8247TRjL1hwuJBBymAoNl68/EhS34KKi
X-Received: by 2002:aa7:d404:: with SMTP id z4mr33037022edq.131.1563341723823;
        Tue, 16 Jul 2019 22:35:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563341723; cv=none;
        d=google.com; s=arc-20160816;
        b=No1vNjy3SCnjcr+rvBRFFCTBNb+UxY4JdmkdbrQJOS1ksI6PjZOmtdqIyYXLRe7+C+
         BNCYb9/mm0EqpHDKzH91DaPtvKxsUAZQeVB/BX8DxyuraNAm0U61ByF+tc9j/Uy38f6u
         8fXpj0ujLH/fOhCi210TGq0WnQW8edlortJj7Y91MviE3Ok2OrnO6ETS+kroG2f4z2Wf
         HPpB0UxEHy5uv9ggYSeWp+U4xBprVghXHJpveVs5/E1NCldbcvuL3dWc17EHmsxASJV8
         JHbFq/kwylLPbLriVQ+ww/E+on5KCwn5ntmeOB47mb3QETUOrVRFS8BX0uFj3zYPGuRL
         +52A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vaYjibo0IOC09JUFY8G2xxjYHdHkXbwPhY4d+akquT4=;
        b=IItysyZ5f+9gcKcDmUhounSh9yAZ0+VzrkMqcAzLB0TE+LBDRLmx7ORoJ42+9rewRD
         nCHt0QtCgY7WkFIftmAaWSF55iD50zzTYT8T1z9DU+f4dFrKNUnbqrtlBDrZo4D9gnNV
         CMBBoBEpjmUM1tbNpBUxXefHldLmK5I7qPAJeyZe7ZgplVm/I4FjxHgrFsIAk/UnxADZ
         jHd3XOzjKuJvEsIOwTaGQGifbcahxukvwFhuZ0RIP71RyAhsShgVJ2zNGizm9zmopJ7o
         TgUVW9xTXC/SST3NRSp29Fa66F86p1Y2PqL2Yc7+vtQKNTYfDeijECll7GP9C89IyGpz
         QxWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m36si13695527edm.236.2019.07.16.22.35.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 22:35:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F1366AC84;
	Wed, 17 Jul 2019 05:35:22 +0000 (UTC)
Date: Wed, 17 Jul 2019 07:35:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, catalin.marinas@arm.com,
	dvyukov@google.com, rientjes@google.com, willy@infradead.org,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Revert "kmemleak: allow to coexist with fault injection"
Message-ID: <20190717053521.GC16284@dhcp22.suse.cz>
References: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
 <1563301410.4610.8.camel@lca.pw>
 <a198d00d-d1f4-0d73-8eb8-6667c0bdac04@linux.alibaba.com>
 <1563304877.4610.10.camel@lca.pw>
 <20190716200715.GA14663@dhcp22.suse.cz>
 <1563308901.4610.12.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563308901.4610.12.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 16-07-19 16:28:21, Qian Cai wrote:
> On Tue, 2019-07-16 at 22:07 +0200, Michal Hocko wrote:
> > On Tue 16-07-19 15:21:17, Qian Cai wrote:
> > [...]
> > > Thanks to this commit, there are allocation with __GFP_DIRECT_RECLAIM that
> > > succeeded would keep trying with __GFP_NOFAIL for kmemleak tracking object
> > > allocations.
> > 
> > Well, not really. Because low order allocations with
> > __GFP_DIRECT_RECLAIM basically never fail (they keep retrying) even
> > without GFP_NOFAIL because that flag is actually to guarantee no
> > failure. And for high order allocations the nofail mode is actively
> > harmful. It completely changes the behavior of a system. A light costly
> > order workload could put the system on knees and completely change the
> > behavior. I am not really convinced this is a good behavior of a
> > debugging feature TBH.
> 
> While I agree your general observation about GFP_NOFAIL, I am afraid the
> discussion here is about "struct kmemleak_object" slab cache from a single call
> site create_object(). 

OK, this makes it less harmfull because the order aspect doesn't really
apply here. But still stretches the NOFAIL semantic a lot. The kmemleak
essentially asks for NORETRY | NOFAIL which means no oom but retry for
ever semantic for sleeping allocations. This can still lead to
unexpected side effects. Just consider a call site that holds locks and
now cannot make any forward progress without anybody else hitting the
oom killer for example. As noted in other email, I would simply drop
NORETRY flag as well and live with the fact that the oom killer can be
invoked. It still wouldn't solve the NOWAIT contexts but those need a
proper solution anyway.
-- 
Michal Hocko
SUSE Labs

