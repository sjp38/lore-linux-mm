Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 165CCC31E5D
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:36:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D252D21880
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:36:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="shPcVD/R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D252D21880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F9BE8E0002; Wed, 19 Jun 2019 11:36:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AA188E0001; Wed, 19 Jun 2019 11:36:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6712B8E0002; Wed, 19 Jun 2019 11:36:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 45CD48E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 11:36:00 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id v83so17741458ybv.17
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:36:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dwSXE2HJvCidsxfi3LfOlPWV76WiyrJo+zGle1/Posk=;
        b=oEj2tqdBYGjcLZoJnOSMcDV6MKK92VnaGqfHyY/E26aTKhmfm6WzeVTY4Giiho6/vr
         smB5UAtaZrtX/fZREQZgKS1RssOhnbgyYJACQvUgqVy5HJNEgHZSB0dJggF9DqCvVT7s
         B5bDkUhDIJJVL31kuJ8/zjyfi/PijCVicoiNtgi6bz4zKvd8jmixq22vpP6O+4w2qEd4
         T1mApjU/4kFTXF4j7nWMPpZEmFPmvGdBpgomtG6ac8NVm1MSaPoLOH0eETt0IYrNiZOa
         f9xTf2jo0Wjymrt24rjqtsziHTXrHALrlKy5oDkb3MzWcv34EruKodvw3NyzGeMScnYz
         veyw==
X-Gm-Message-State: APjAAAVq22JmYCOrmgAeh0ohMR7+5ZHd48Cdi8Em1dNu+XDnWwebvjl1
	9jk8LpS9vIq/4OGdP6Z3KH9vwRQPBP1WeTjcZUAsIIboKGSo78mNTAzzVOnpTfMLNZ9rA4sjD1B
	RCeJJGB+Rmy2iR5jpizN51FxVvKTWtDihuARDtjZwXPtQYoe6VLU9lYos92HXQvNUZw==
X-Received: by 2002:a25:cf0d:: with SMTP id f13mr59915980ybg.323.1560958560043;
        Wed, 19 Jun 2019 08:36:00 -0700 (PDT)
X-Received: by 2002:a25:cf0d:: with SMTP id f13mr59915946ybg.323.1560958559531;
        Wed, 19 Jun 2019 08:35:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560958559; cv=none;
        d=google.com; s=arc-20160816;
        b=eQussr9J0+9RtHwSsezng/UXigXHVIsOBpZ1lDp6ZufwO+wErCgrtTes2Ub7ShSj5c
         pi2Mlul7ZOGE7HvL15lTr13OA7gMksoHThFwyBkDbD/V3LEY9tTRR12SJ8JVrrI3l7Jp
         T/fGZSQHmmewN0mPjUWdnVrz2d0RKOdGSA1KtuDafIvaCou/fzDZ6GrQJhsdr1hmV3dD
         bKkoI20nwXRpQuheNRmImWmJcW6yYq1OPdW9SzSAfZ4aYWEU0T9n2LWRzx894xB2ZMgd
         H3B5xj4TkhiZZGe9rVL1nxKcXtwW7fDz6YP8l+K+f379CDNkvIpBUMV9GJ3C9oHXtskN
         qbHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dwSXE2HJvCidsxfi3LfOlPWV76WiyrJo+zGle1/Posk=;
        b=whmI+pSoSTDQaGxNSUzYV4buwbWy+KdSh9sdStELb1jnqPPT9fuvg53Km6atBA49HM
         Xkh7wwYcRsE0NofpgREmiCCUssOs+eScQ4MIzvZf3QkaU7df3yNxFN9oZzrvI/he++PT
         DXLBF1knIgyMHiTnCQmiwvzz5cEUdBb+H1AfB+0PJKGbAtjI2yPpugsXELE14g56Mr96
         /LXXfT4yc0ikt/661C60n/QUIIInXogmw8xzXrhErk2N1Y1E+0uUGAjw+qpJSvHtJbZi
         YRq/XwSmWRrziaZ6DV/D4jUg/mQT1NloRLlL+GVBPb1NLp8T9/G4eMlvSLkQcZJo9sqk
         WLYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="shPcVD/R";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e138sor543890ywa.30.2019.06.19.08.35.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 08:35:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="shPcVD/R";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dwSXE2HJvCidsxfi3LfOlPWV76WiyrJo+zGle1/Posk=;
        b=shPcVD/RnA32q5R954zhbHbCNmUv9WV3y1RqIyqvsdpscKxDrx898pdEDLhp5LN0to
         DbXYXu+gvach7KLfWm2FSbsVhYhvyvmXGjhENsRkiMKSnzsr2EcXvlHfynmEaSSmHkie
         5Yts8FyiwXSFtBQH6RFnmuWPot9WB3/pECxotkeyoOEWY/zSS12ndpAUC0/eRSSv0R9U
         yZ3R5iGCjfEkm/U8Cqn+k5IXrPvpygVj1VJXilucmRW00bBqpvtpm69ynGQS7hLw53mK
         vTA414ToCI8UTtvUA421mNTNbwrVbYtIQ7ja94Ya4nfK98Lsk+qkHykltGKqlw+41fs5
         JPBQ==
X-Google-Smtp-Source: APXvYqxkP5tURjFEv1pLRgOMle49c6W6qB/eYRu2b+HirEU7vb0z2HAUJr63bUo2XJQhzwumW474OnOIqm7cAPB2g2Y=
X-Received: by 2002:a81:3a0f:: with SMTP id h15mr70130882ywa.34.1560958558977;
 Wed, 19 Jun 2019 08:35:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190619144610.12520-1-longman@redhat.com> <CALvZod5yHbtYe2x3TGQKGtxjvTDpAGjvSc8Pvphbn00pdRfs2g@mail.gmail.com>
 <20831975-590f-ecab-53db-5d7e6b1a053f@redhat.com>
In-Reply-To: <20831975-590f-ecab-53db-5d7e6b1a053f@redhat.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 19 Jun 2019 08:35:47 -0700
Message-ID: <CALvZod6T31z2P+wdUz3LVYO3dTSbOc89cKDn=8LKpN+ZovL8jw@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: Add a memcg_slabinfo debugfs file
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 8:30 AM Waiman Long <longman@redhat.com> wrote:
>
> On 6/19/19 11:18 AM, Shakeel Butt wrote:
> > On Wed, Jun 19, 2019 at 7:46 AM Waiman Long <longman@redhat.com> wrote:
> >> There are concerns about memory leaks from extensive use of memory
> >> cgroups as each memory cgroup creates its own set of kmem caches. There
> >> is a possiblity that the memcg kmem caches may remain even after the
> >> memory cgroup removal. Therefore, it will be useful to show how many
> >> memcg caches are present for each of the kmem caches.
> >>
> >> This patch introduces a new <debugfs>/memcg_slabinfo file which is
> >> somewhat similar to /proc/slabinfo in format, but lists only slabs that
> >> are in memcg kmem caches. Information available in /proc/slabinfo are
> >> not repeated in memcg_slabinfo.
> >>
> > At Google, we have an interface /proc/slabinfo_full which shows each
> > kmem cache (root and memcg) on a separate line i.e. no accumulation.
> > This interface has helped us a lot for debugging zombies and memory
> > leaks. The name of the memcg kmem caches include the memcg name, css
> > id and "dead" for offlined memcgs. I think these extra information is
> > much more useful for debugging. What do you think?
> >
> > Shakeel
>
> Yes, I think that can be a good idea. My only concern is that it can be
> very verbose. Will work on a v2 patch.
>

Yes, it is very verbose but it is only for debugging and normal users
should not be (continuously) reading that interface.

Shakeel

