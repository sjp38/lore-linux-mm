Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4183C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:35:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B64A72083B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:35:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B64A72083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4ABF08E0003; Thu, 20 Jun 2019 11:35:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4823C8E0001; Thu, 20 Jun 2019 11:35:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 371E48E0003; Thu, 20 Jun 2019 11:35:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DBAD58E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:35:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i9so4773446edr.13
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:35:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=u+mmkWAHRBgKlRAKMtOSMbXS1tIdbWjLVcOXwPY9fFQ=;
        b=ExlF9N94T1zGkOMgiR43YyG96P4s3tiFyXdyJ+kQj3mDnGtHXcjKbL9Ht8Hwejo4HX
         K8bCZucJPgtxwWNxHdQ/G3T90JVOWERaPT/pckhKIGrH8U7ooxzEt4LhS5Mr7EQ5/YM4
         EUNcG34b9wxkGM5PsAwVP0XW6tr3oJLPIFyOi0XqV3XDEAGcCQnhLXX3t8ygo0zdsmW5
         dQmhcnAZIuMLK4jyB2fi7yL6PuW7mJa4YF0xU1igtN+iNNhQ3wquof0NhWRD6phfl43n
         +Ak9S3aRSbBg0Y/dxWqUGgpTHnP0Voq4h9mFqaJNx5OGhYklgO2PfAqFKv2bxOYRldp+
         BMAw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVU+1FYtOy26mpnqLFlueLXlO7pFVQWO7MOWihm+3voCqPj2FQB
	5GXjqT5FjWy2c8oqfR/dQmsI6QPLF+I/iMF+1JaoPNXsNAIxDd1/BBPMeQcUnVg0hTkjA8gGco5
	j9fVP8GzItqI5l+2e9ujxUGzyC9tW1Sv9nGFXOpymtLnC89lDm3uBDlV/E4BF7ME=
X-Received: by 2002:a17:906:ce21:: with SMTP id sd1mr95265259ejb.189.1561044919372;
        Thu, 20 Jun 2019 08:35:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpUB+k1u5PRZz38XhpJzzPqElrN2rXv7KH4MkE10wlAa9oaq12WDyseWt+KKIIHPpuhoZu
X-Received: by 2002:a17:906:ce21:: with SMTP id sd1mr95265190ejb.189.1561044918646;
        Thu, 20 Jun 2019 08:35:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561044918; cv=none;
        d=google.com; s=arc-20160816;
        b=E5XhRJLL0dygVwdm1Wf6ouXzab878zhmSbLBJvX80qd78IzUXzgqaphK6++DeBMN6j
         fGjikxEg7ZXQhBiKnLqvftNt6zeb/JXaofOMH3sO+M8R/yYrE8pgdBmMaZAZDvxOgs9Q
         WnQirkFFIwFFZMffzziBbsAy8TokFBWLAvR0Ke3f8kBD41HZMnNG9yRyCexZUyA3E1Cp
         UI3aZlMfgyoPKf2p006+2QjnF5p8KFtciXIHh2gGFyGW+J+BHkyRHX69nlwhk0N310ya
         4aVgPWE/QoEwfKBdJkXuTWooCBnvX0Bdf414JM96xq7UF7KLAwDQjYjv3O2O+Bd1Ao2x
         KIVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=u+mmkWAHRBgKlRAKMtOSMbXS1tIdbWjLVcOXwPY9fFQ=;
        b=sK4Jiyzq4l/L4KihiKwsWMmqbYkUxAv3zecMC6+aY0Q52uUl2/JLeOJyM3NJHPkvaq
         Fo+hhco9yXRJJatyGuHWjIeIRtQTdWwjGKaDtrPWBVN7r6CI67G/n66Wa388GKy+0c2n
         yZ04c/kzGYdo+c2WV0nLw9/DD0lIdYGgB0Ohx8Iy3tJRqslZM9Jkh1kad5Kq8vwy8P/+
         LHkdz+t8uwICxLR/Hgmha9346hulrDDwttKtlwez1lNxNYOuPWDvHRb8kpJl3rC7izdf
         dYKUIoGQF2457rYXETMWseID0evxfy+7LxdRvn6/w2pDN2UuWoVpuaOr7qvb6KAMMjKZ
         1Uyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v5si12921472eje.348.2019.06.20.08.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 08:35:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1977EAE46;
	Thu, 20 Jun 2019 15:35:18 +0000 (UTC)
Date: Thu, 20 Jun 2019 17:35:16 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: [PATCH] slub: Don't panic for memcg kmem cache creation failure
Message-ID: <20190620153516.GG12083@dhcp22.suse.cz>
References: <20190619232514.58994-1-shakeelb@google.com>
 <20190620055028.GA12083@dhcp22.suse.cz>
 <CALvZod4Fd5X91CzDLaVAvspQL-zoD7+9OGTiOro-hiMda=DqBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod4Fd5X91CzDLaVAvspQL-zoD7+9OGTiOro-hiMda=DqBA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 20-06-19 07:44:27, Shakeel Butt wrote:
> On Wed, Jun 19, 2019 at 10:50 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Wed 19-06-19 16:25:14, Shakeel Butt wrote:
> > > Currently for CONFIG_SLUB, if a memcg kmem cache creation is failed and
> > > the corresponding root kmem cache has SLAB_PANIC flag, the kernel will
> > > be crashed. This is unnecessary as the kernel can handle the creation
> > > failures of memcg kmem caches.
> >
> > AFAICS it will handle those by simply not accounting those objects
> > right?
> >
> 
> The memcg kmem cache creation is async. The allocation has already
> been decided not to be accounted on creation trigger. If memcg kmem
> cache creation is failed, it will fail silently and the next
> allocation will trigger the creation process again.

Ohh, right I forgot that it will get retried. This would be useful to
mention in the changelog as it is not straightforward from reading just
the particular function.

> > > Additionally CONFIG_SLAB does not
> > > implement this behavior. So, to keep the behavior consistent between
> > > SLAB and SLUB, removing the panic for memcg kmem cache creation
> > > failures. The root kmem cache creation failure for SLAB_PANIC correctly
> > > panics for both SLAB and SLUB.
> >
> > I do agree that panicing is really dubious especially because it opens
> > doors to shut the system down from a restricted environment. So the
> > patch makes sesne to me.
> >
> > I am wondering whether SLAB_PANIC makes sense in general though. Why is
> > it any different from any other essential early allocations? We tend to
> > not care about allocation failures for those on bases that the system
> > must be in a broken state to fail that early already. Do you think it is
> > time to remove SLAB_PANIC altogether?
> >
> 
> That would need some investigation into the history of SLAB_PANIC. I
> will look into it.

Well, I strongly suspect this is a relict from the past. I have hard
time to believe that the system would get to a usable state if many of
those caches would fail to allocate. And as Dave said in his reply it is
quite silly to give this weapon to a random driver hands. Everybody just
thinks his toy is the most important one...

-- 
Michal Hocko
SUSE Labs

