Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FBB0C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:24:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6398225979
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:24:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6398225979
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EED0E6B0274; Thu, 30 May 2019 02:24:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9DD66B0280; Thu, 30 May 2019 02:24:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D66446B0281; Thu, 30 May 2019 02:24:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE166B0274
	for <linux-mm@kvack.org>; Thu, 30 May 2019 02:24:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26so7095730eda.15
        for <linux-mm@kvack.org>; Wed, 29 May 2019 23:24:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lFbxJVmwwDktBP7Omlp2VSDl1R2lSTomTFt7z7dkoXE=;
        b=m2atYvoBXKm0q3aICDmb8dgc9jCEg0GvhHpW7zzSgcvW9iNegrbfcUxnA9p5gvkxqz
         NpGO7KtfA1DYCs4zKYh7uZMic/qm2PL4NJ4CmueTYL0xcLmaquJk7s7za7xSeC3jPq3F
         Ga48Dd0x+5VkPMHXCdu0rSSDYaaF2RgpxMX+AgslIaw5L3a7XrrugNn4un2WeBgrVsR9
         Q9YMLFzsm+PsFLfzhvh2xtRzAR2VmRnFMCuaBM4YT6dU1L5WtjWB6W8FYw9uQ+rOqoFL
         VgAD1QFEBpjs9q4+0KwvLRY27CB0c9rDOaqUM7gzsuqiObytT/CWi4NIPmuBapfHTHB/
         loKw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUUcKSw4c35zGuc2DFwnfOruP0RzeTF9UXbQQUkgoZs2c2CFgK/
	2nNvMLmDgYFM7taWNyDOc8CweEFPNwcGWRMIymRuCPR5gNIzGQiOpOIoHLW3VRttOcqTJEAqg18
	3TivzMkQoAleA96ToCxXsMMUUrTLOaShSTiCRnhs8LjpnZaxwzjwjK6qQkHWwyjA=
X-Received: by 2002:aa7:db0c:: with SMTP id t12mr2524170eds.170.1559197462139;
        Wed, 29 May 2019 23:24:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2NwHxmFww9k5aR7cCryzfmiAUSa3wcvDs0SqWUq3oKQRkN6oAKUtZIcf/OFYMNb9udtU9
X-Received: by 2002:aa7:db0c:: with SMTP id t12mr2524111eds.170.1559197461262;
        Wed, 29 May 2019 23:24:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559197461; cv=none;
        d=google.com; s=arc-20160816;
        b=XgubDouvojcsYoIXqoOTrixpkZTJ24pqReVVABayPPnXHBSHTTiC6SaFFhC0+mS8rt
         Sh96pumyq2ODsu//G41epbHMxfDWBOr7G2yLwpU/jwkIZs1H1MzWGMqD5+UMS59i61K8
         G42BYHe0GZ8ntgQ0lZoO9eWHnpuyoBFHk+xMn4vLM8DpBpwAUzO8sv24v+wb2irDsmfu
         wdJhYxZOqlaaTw2g+K8vTN6s9V1dTMO2KHsAs+1zTYyiMJhtgX2pRkeTXhuw9nhhk/Jq
         CBTeIC0020Pg2ee9ynw5Bkcr1+a8WBTO8hHD63wgjmzvuVXnFVa4o0Ip+oHpjt9ICewq
         BbHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lFbxJVmwwDktBP7Omlp2VSDl1R2lSTomTFt7z7dkoXE=;
        b=MSzr904gn59n3wQvvZ3+GmBb9WDFG/XXN3Ix4ekq15dPOwe+JGoLvAXui/qqvpy8BB
         ZJ8oGu9eiePi5F0WgJVYkKZfoveLIdLu5RykerGgl/QZLOwwSqe1t16OKQFCm6mKT5z5
         Qx1PJRgS5RC89JjexN/MURmGL1vidKthvN5pWqbk8aXMz7yyAKAQAvqfeRRD4fJfpmuN
         fCHfCxX143zaQBOW88oVxpYuA3lGrBbPRBGAbfnjZk4B41sbGIwy0jQypPNnPVhjcBmm
         zcNCsjNtrPQQFL6/gyqZ5HWI/lUgK7ZIOBKlhHXmgop7UJASVZmiV6yQZYzTh79ZBgHs
         /XRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bo3si1175106ejb.43.2019.05.29.23.24.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 23:24:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 38A4AACA8;
	Thu, 30 May 2019 06:24:20 +0000 (UTC)
Date: Thu, 30 May 2019 08:24:18 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dianzhang Chen <dianzhangchen0@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/slab_common.c: fix possible spectre-v1 in
 kmalloc_slab()
Message-ID: <20190530062418.GB6703@dhcp22.suse.cz>
References: <1559133448-31779-1-git-send-email-dianzhangchen0@gmail.com>
 <20190529162532.GG18589@dhcp22.suse.cz>
 <CAFbcbMDJB0uNjTa9xwT9npmTdqMJ1Hez3CyeOCjjrLF2W0Wprw@mail.gmail.com>
 <20190529174931.GH18589@dhcp22.suse.cz>
 <CAFbcbMA6XjZqrgHmG70Vm_a34Rn4tKqoMgQkRBXES2r3+ymYwg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFbcbMA6XjZqrgHmG70Vm_a34Rn4tKqoMgQkRBXES2r3+ymYwg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Please do not top-post]

On Thu 30-05-19 13:20:01, Dianzhang Chen wrote:
> It is possible that a CPU mis-predicts the conditional branch, and
> speculatively loads size_index[size_index_elem(size)], even if size >192.
> Although this value will subsequently be discarded,
> but it can not drop all the effects of speculative execution,
> such as the presence or absence of data in caches. Such effects may
> form side-channels which can be
> observed to extract secret information.

I understand the general mechanism of spectre v1. What I was asking for
is an example of where userspace directly controls the allocation size
as this is usually bounded to an in kernel object size. I can see how
and N * sizeof(object) where N is controlled by the userspace could be
the target. But calling that out explicitly would be appreciated.
 
> As for "why this particular path a needs special treatment while other
> size branches are ok",
> i think the other size branches need to treatment as well at first place,
> but in code `index = fls(size - 1)` the function `fls` will make the
> index at specific range,
> so it can not use `kmalloc_caches[kmalloc_type(flags)][index]` to load
> arbitury data.
> But, still it may load some date that it shouldn't, if necessary, i
> think can add array_index_nospec as well.

Please mention that in the changelog as well.
 
> On Thu, May 30, 2019 at 1:49 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 30-05-19 00:39:53, Dianzhang Chen wrote:
> > > It's come from `192+1`.
> > >
> > >
> > > The more code fragment is:
> > >
> > >
> > > if (size <= 192) {
> > >
> > >     if (!size)
> > >
> > >         return ZERO_SIZE_PTR;
> > >
> > >     size = array_index_nospec(size, 193);
> > >
> > >     index = size_index[size_index_elem(size)];
> > >
> > > }
> >
> > OK I see, I could have looked into the code, my bad. But I am still not
> > sure what is the potential exploit scenario and why this particular path
> > a needs special treatment while other size branches are ok. Could you be
> > more specific please?
> > --
> > Michal Hocko
> > SUSE Labs

-- 
Michal Hocko
SUSE Labs

