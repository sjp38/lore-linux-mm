Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEA8CC5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 23:55:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E44220830
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 23:55:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="S2OMCh/5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E44220830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1451A6B0003; Fri,  5 Jul 2019 19:55:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CE5A8E0003; Fri,  5 Jul 2019 19:55:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDE2F8E0001; Fri,  5 Jul 2019 19:55:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id CBFA26B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 19:55:24 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id u25so11259721iol.23
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 16:55:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=F2QUe/hVMKryIPw+v0O5izKJ1cADvW0fcl9O7Jl5M7o=;
        b=iTsX+X3vrn9EMAUJ+0udqNGn7kWFL3fWjP6j2ILnMa6fqJj5gX7P0UAlp/pmYPlANn
         ydO+SX6awcNldC/x6HS4rLDEyngcRvp/oq30PTB4WNnqlV+x3zP4v8Tq7LZ+I7e1QEWs
         jWMjjJLIST5wUjIBtUun4ynfO+6Uat2aDFQSKbIulfCMcoZCA9mV7VNSxuXrTTT8APQx
         rlGSMgWIpav4zN0AWK2IW3NmO/mWmEG3WjH+8DrdU7+uUlg72cnEyywQv8TV79KYLn3d
         rP0HpbNxhLtbjyXNDpBlyIQ6IO+jvt9SJV2reN7/Kynvoqo2o1GE0M0OpDKwEO+p7tHu
         mASQ==
X-Gm-Message-State: APjAAAWxTJbQ5/e9fIObGRKwiV6soeDFAbXXPRTcNwGIfKaTCcYr24Ke
	6pNvq2+9C2t6B10CjFVfjhvLJBXi6Dt6TBaYTAt0OSRswOM5zloE15b3urlpMfUIvEPz38xSQ7P
	MaEztbYQMj95oIm5q9KPDuaEMxJnUcY82tMTByrKRp6t/ukai6bNtE0w0DAPvBPaO3Q==
X-Received: by 2002:a02:a183:: with SMTP id n3mr7820318jah.74.1562370924589;
        Fri, 05 Jul 2019 16:55:24 -0700 (PDT)
X-Received: by 2002:a02:a183:: with SMTP id n3mr7820288jah.74.1562370924041;
        Fri, 05 Jul 2019 16:55:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562370924; cv=none;
        d=google.com; s=arc-20160816;
        b=r3NH0KaExN4qr88eqD/h2zUMmFPizSIPSW54GM0oKL0eMMM9CwEJTCtNGtGb6wAiZk
         83hgO0V0iG7cxmwTtYXQ9S7T5vk+SGzgrRhcxM3OyXkIIJm6eazzNaipkRN091tM3SA6
         NhMWpiV4i0jGy+nxeR25sYYMuTyLcjxobs6z/jkxAolkthGkT6YaMpdQATaBsY85gEsM
         DCRCT1ptleKmUoQAet4BJcDz2AcgeS+GQH9u2MqxWuTYKoPwz8Csj+BDB2LRDWpieGd3
         k+6rphrAfChYTVNYWpLNV2ZqjZo/WyuheHNCchWUWHlv9OPjB6q3BFn2hpXKWFfxMO5s
         A/cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=F2QUe/hVMKryIPw+v0O5izKJ1cADvW0fcl9O7Jl5M7o=;
        b=MzKo55RacJz0qXq2/59EoRvJ0iVc27KWBVxbd6inJuihQWf1SEzyKhjhJOKZe/ghOt
         YQ8vWxuF6Jfc4sLt0P3Ow7VrI/DuLpnJTJ4b9LiETpAB6U+Lb9XaAbBjdGQ5cHzEkT44
         vmEUiqXtKlMfgPWSioBqD4yK6Z7kyB7AXC91cpUhkFmgPlLs2RTioi8i6trkn6U7oiQ5
         HEgXLezAin3AR6uMEnDwkQmfFpwZVwprdHRa+giUwcn90WQGqvNmCD+FNB+CByff1i7Q
         YIARYzGLsRnkSTr6QT/CJztdtKRg9HXKMphO/jD1ht2oAbKEslhuocE4ghm3EJMyZao6
         KPNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="S2OMCh/5";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r5sor7920819iob.71.2019.07.05.16.55.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 16:55:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="S2OMCh/5";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=F2QUe/hVMKryIPw+v0O5izKJ1cADvW0fcl9O7Jl5M7o=;
        b=S2OMCh/5m5GRTVO00yAqIf7qvEsi6vXFWQVWXEp1HT3l40HX2Ek36Sbz1H0KRpd6vI
         48gqtZulq9zsazsE+xlBzjvQK/oqTlwZ+SJtaYSkK9m0TMVt/IXmv2BfjeHfd16qTaiW
         EI0iYEVjPgXgOIQSL9mE3EYPEQvokhctEptK4ylAZofg9vV8hN0PSU5N5+LRrcssNyKd
         vE0t7+EPMhb4g9fdcwURtK83Dz9ZYz4Ap92NAGIfOWsQNkBudpPrGf0UWsHnOQtfLAb8
         szsi6SLxMOvVYtJUW8ZWjiXEnv3K3Y9VwvXc/yl9e6+oCX5hiBXKknAEG/Lok4c7Hrd6
         ryRw==
X-Google-Smtp-Source: APXvYqwDlyKB9c2ZvWbIS7jItMkQi4k5pqhky/amC8ILp5krM67Ihh3QVYB9yAUgKi6JKUQBdvnAHo3/68JxCkXN6oA=
X-Received: by 2002:a6b:5115:: with SMTP id f21mr7182488iob.173.1562370923812;
 Fri, 05 Jul 2019 16:55:23 -0700 (PDT)
MIME-Version: 1.0
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
 <20190705090902.GF8231@dhcp22.suse.cz> <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
 <20190705111043.GJ8231@dhcp22.suse.cz> <CALOAHbA3PL6-sBqdy-sGKC8J9QGe_vn4-QU8J1HG-Pgn60WFJA@mail.gmail.com>
 <20190705195419.GM8231@dhcp22.suse.cz>
In-Reply-To: <20190705195419.GM8231@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 6 Jul 2019 07:54:47 +0800
Message-ID: <CALOAHbDVUejmPZF6KEbAxh6Om=FX7VUofkbt=bp63LzZxCxHhg@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in cgroup v1
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Shakeel Butt <shakeelb@google.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 6, 2019 at 3:54 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 05-07-19 22:33:04, Yafang Shao wrote:
> > On Fri, Jul 5, 2019 at 7:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Fri 05-07-19 17:41:44, Yafang Shao wrote:
> > > > On Fri, Jul 5, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > [...]
> > > > > Why cannot you move over to v2 and have to stick with v1?
> > > > Because the interfaces between cgroup v1 and cgroup v2 are changed too
> > > > much, which is unacceptable by our customer.
> > >
> > > Could you be more specific about obstacles with respect to interfaces
> > > please?
> > >
> >
> > Lots of applications will be changed.
> > Kubernetes, Docker and some other applications which are using cgroup v1,
> > that will be a trouble, because they are not maintained by us.
>
> Do they actually have to change or they can simply use v2? I mean, how
> many of them really do rely on having tasks in intermediate nodes or
> rely on per-thread cgroups? Those should be the most visibile changes in
> the interface except for control files naming. If it is purely about the
> naming then it should be quite trivial to update, no?
>

This is not a technical issue.
There're many other factors we have to consider, i.e. the cost.
One simple example is in publich cloud, if we upgrade our system and
force the customers to modify their user code to run on our new
system, we may lost these customers.
As this is not a techical issue really, I don't think we can make a
clear conclusion here.

> Brian has already answered the xfs part I believe. I am not really
> familiar with that topic so I cannot comment anyway.
>
> > Do you know which companies  besides facebook are using cgroup v2  in
> > their product enviroment?
>
> I do not really know who those users are but it has been made a wider
> decision that v2 is going to be a rework of a new interface and the the
> v1 will be preserved and maintain for ever for backward compatibility.
> If there are usecases which cannot use v2 because of some fundamental
> reasons then we really want to hear about those. And if v2 really is not
> usable we can think of adding features to v1 of course.
> --
> Michal Hocko
> SUSE Labs

