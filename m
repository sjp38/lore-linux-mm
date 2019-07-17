Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79E02C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:02:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D9CE21848
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:02:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BIgpOWEL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D9CE21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD13A6B000D; Wed, 17 Jul 2019 13:02:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5B078E0003; Wed, 17 Jul 2019 13:02:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FA158E0001; Wed, 17 Jul 2019 13:02:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7FE6B000D
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 13:02:25 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id q79so19067109ywg.13
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:02:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=BgLO7AOlxApfrZ8As7HxY8L1byop/yjZk5edDlBCjHc=;
        b=c+6BPM5rRAV9+zXNPRaYr1zPC0BFZDAp4//XqL/rxSIzK2HyDXMbFzPCZDm2LrlwaO
         pazKbLh1ENaRTZ1Ouu/ssaklQQF+sxgjzyatAnCW1ZZQqiggiEjl0x7jHPb6WEANLfrj
         Uo+g4S+Qtq6r5Ms1R29lNGYC7V7NpOPAB/GP+vpdIL9ucLU79AsGsTNLUYuf7l7v6LRx
         g4j5HIF0WpciUkqRQQAXnCWEzaKSeDBwlmoTI63eVg/V2Yy/xylaZWhwhvkx2tebYZ7F
         mDAJDVp+b6aXJvQKusqEG1jc2kqnR3nw3mcX4Y9Le/nt8WnwWw+QCHUGrsQ7UufCe0kY
         J31Q==
X-Gm-Message-State: APjAAAVj/LsRGyP/nj8OGAzKTYK4Biu4st7Cz0bIiLBeiBOMy0Q1LSpR
	q6gGQo2cKe+DEgWc3jddjJeWKHr/u8gWJSAQeqIT/pa79HoyZro+YcCjWEOBUyb8dv2OEUnjgjm
	tbCJc1Q34qXKNB3M5icy9roZY9ZZvvQwLj/kPMgg9Q2jlbA5XgEZJ9dCw582A3YHk9g==
X-Received: by 2002:a81:1f87:: with SMTP id f129mr24152804ywf.135.1563382945214;
        Wed, 17 Jul 2019 10:02:25 -0700 (PDT)
X-Received: by 2002:a81:1f87:: with SMTP id f129mr24152718ywf.135.1563382944194;
        Wed, 17 Jul 2019 10:02:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563382944; cv=none;
        d=google.com; s=arc-20160816;
        b=u3eE5p/0iA8iBDTL5DpfCxFm6u5fAgdnCsnLXmg+PsQUouwMmPPbVbhxVJsFAOym5k
         mMENJDrdpSqaUoz+KBW7tbDoQPgnZQCtCdvYP7W5CfIFDg+vaf15NX3Xq3EMSL+68IAP
         snyG3grX6+IEP18GmRgq5sHBQ4jXDB7BKfDLYwEdS3EIeRYzDiqNkhK+olYuKrhTMwFH
         HmMsyJayUgClRaKb03EjoD14r17iUjEHm4PRcgM/oHde7M5VY6f0t26Qy3A9KC2Xi+zW
         JA7FZ5NXomW6oiOqiAr8UrP3ktAHfEubTumn/ecTngHtRELG/WlJFjJXGe+VvV3pjWNZ
         iw3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=BgLO7AOlxApfrZ8As7HxY8L1byop/yjZk5edDlBCjHc=;
        b=v7MhQNsHfH+vku/Ki0C/1Ik8Cwxz/5F65E1psUgPSXXTwImSuuzia4qEXDZvEPNmfY
         UHoXlckbLjUtkorIgwR+fl5GTpw+EnwNrhyDatZZSFurDGYHTOQp3K3tMWJoSFBRT2np
         VdALhC2ykimTfhMqnscGazjDvkZUlXTeKGzM1X1MepYp+JUPgFpzTUp+0CVFl1/AERs4
         x6CMvAVT+957LhzqDDmC0byCNOFhN9BJB4xSM4PNGyKHRKlt4MtMhVdUTWRd/KWPI/yV
         246jDkTwjq6+v6YU7YkkaIlSH5MQ1HU+HKeoha5JqJq9mWSb1R4YNpSIWspUTimg+VSE
         2s0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BIgpOWEL;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n18sor2757096ybk.173.2019.07.17.10.02.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 10:02:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BIgpOWEL;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=BgLO7AOlxApfrZ8As7HxY8L1byop/yjZk5edDlBCjHc=;
        b=BIgpOWELXYgjF12yzOPDUoGbuLq1zi1FwFQmt9xkcQGc5AVH1aQ1fmd7au9DmtxE77
         SY+UU54YPYCG1nAZxTVSGzseRtCjafwhDZ4sq+T155nDh5SQweIb9Kv9bmYkXEF0rBAi
         Jce01AB+F19yWiKmos650B41EbFmKiIZJwLInUaHQalp7zYlU1jxlVWD9vhSa/fRuu6a
         b7nzcGo609oS8EbLaA+IMQnzkmWt+L0RtcEdtpSxuAl99/rSV6wMPBnSXbct22f0l89n
         1tIqPXgR2BPMAU6RK7mybiSNYzP5Ck/ztcB15ywooaPz0qniKKdifZmb+u3kc6V6fdgA
         eNUg==
X-Google-Smtp-Source: APXvYqyzz4GHd+f0tyqhFDhqf2xn/zwFnrM7OEtFPR5C7USenjzkjt+qzoGBfAeU/vHGi6p5DKvh/u3O85iL5H8T2SE=
X-Received: by 2002:a25:6412:: with SMTP id y18mr13200161ybb.100.1563382943463;
 Wed, 17 Jul 2019 10:02:23 -0700 (PDT)
MIME-Version: 1.0
References: <1562795006.8510.19.camel@lca.pw> <cd6e10bc-cb79-65c5-ff2b-4c244ae5eb1c@linux.alibaba.com>
 <1562879229.8510.24.camel@lca.pw> <b38ee633-f8e0-00ee-55ee-2f0aaea9ed6b@linux.alibaba.com>
 <1563225798.4610.5.camel@lca.pw> <5c853e6e-6367-d83c-bb97-97cd67320126@linux.alibaba.com>
 <8A64D551-FF5B-4068-853E-9E31AF323517@lca.pw> <e5aa1f5b-b955-5b8e-f502-7ac5deb141a7@linux.alibaba.com>
 <CALvZod7+ComCUROSBaj==r0VmCczs=npP4u6C9LuJWNWdfB0Pg@mail.gmail.com> <50f57bf8-a71a-c61f-74f7-31fb7bfe3253@linux.alibaba.com>
In-Reply-To: <50f57bf8-a71a-c61f-74f7-31fb7bfe3253@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 17 Jul 2019 10:02:11 -0700
Message-ID: <CALvZod7Je+gekSGR61LMeHdYoC_PJune_0qGNiDfNH2=oNeOgw@mail.gmail.com>
Subject: Re: list corruption in deferred_split_scan()
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Roman Gushchin <guro@fb.com>, Qian Cai <cai@lca.pw>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 5:12 PM Yang Shi <yang.shi@linux.alibaba.com> wrote=
:
>
>
>
> On 7/16/19 4:36 PM, Shakeel Butt wrote:
> > Adding related people.
> >
> > The thread starts at:
> > http://lkml.kernel.org/r/1562795006.8510.19.camel@lca.pw
> >
> > On Mon, Jul 15, 2019 at 8:01 PM Yang Shi <yang.shi@linux.alibaba.com> w=
rote:
> >>
> >>
> >> On 7/15/19 6:36 PM, Qian Cai wrote:
> >>>> On Jul 15, 2019, at 8:22 PM, Yang Shi <yang.shi@linux.alibaba.com> w=
rote:
> >>>>
> >>>>
> >>>>
> >>>> On 7/15/19 2:23 PM, Qian Cai wrote:
> >>>>> On Fri, 2019-07-12 at 12:12 -0700, Yang Shi wrote:
> >>>>>>> Another possible lead is that without reverting the those commits=
 below,
> >>>>>>> kdump
> >>>>>>> kernel would always also crash in shrink_slab_memcg() at this lin=
e,
> >>>>>>>
> >>>>>>> map =3D rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_=
map, true);
> >>>>>> This looks a little bit weird. It seems nodeinfo[nid] is NULL? I d=
idn't
> >>>>>> think of where nodeinfo was freed but memcg was still online. Mayb=
e a
> >>>>>> check is needed:
> >>>>> Actually, "memcg" is NULL.
> >>>> It sounds weird. shrink_slab() is called in mem_cgroup_iter which do=
es pin the memcg. So, the memcg should not go away.
> >>> Well, the commit =E2=80=9Cmm: shrinker: make shrinker not depend on m=
emcg kmem=E2=80=9D changed this line in shrink_slab_memcg(),
> >>>
> >>> -     if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
> >>> +     if (!mem_cgroup_online(memcg))
> >>>                return 0;
> >>>
> >>> Since the kdump kernel has the parameter =E2=80=9Ccgroup_disable=3Dme=
mory=E2=80=9D, shrink_slab_memcg() will no longer be able to handle NULL me=
mcg from mem_cgroup_iter() as,
> >>>
> >>> if (mem_cgroup_disabled())
> >>>        return NULL;
> >> Aha, yes. memcg_kmem_enabled() implicitly checks !mem_cgroup_disabled(=
).
> >> Thanks for figuring this out. I think we need add mem_cgroup_dsiabled(=
)
> >> check before calling shrink_slab_memcg() as below:
> >>
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index a0301ed..2f03c61 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -701,7 +701,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, i=
nt
> >> nid,
> >>           unsigned long ret, freed =3D 0;
> >>           struct shrinker *shrinker;
> >>
> >> -       if (!mem_cgroup_is_root(memcg))
> >> +       if (!mem_cgroup_disabled() && !mem_cgroup_is_root(memcg))
> >>                   return shrink_slab_memcg(gfp_mask, nid, memcg, prior=
ity);
> >>
> >>           if (!down_read_trylock(&shrinker_rwsem))
> >>
> > We were seeing unneeded oom-kills on kernels with
> > "cgroup_disabled=3Dmemory" and Yang's patch series basically expose the
> > bug to crash. I think the commit aeed1d325d42 ("mm/vmscan.c:
> > generalize shrink_slab() calls in shrink_node()") missed the case for
> > "cgroup_disabled=3Dmemory". However I am surprised that root_mem_cgroup
> > is allocated even for "cgroup_disabled=3Dmemory" and it seems like
> > css_alloc() is called even before checking if the corresponding
> > controller is disabled.
>
> I'm surprised too. A quick test with drgn shows root memcg is definitely
> allocated:
>
>  >>> prog['root_mem_cgroup']
> *(struct mem_cgroup *)0xffff8902cf058000 =3D {
> [snip]
>
> But, isn't this a bug?

It can be treated as a bug as this is not expected but we can discuss
and take care of it later. I think we need your patch urgently as
memory reclaim and /proc/sys/vm/drop_caches is broken for
"cgroup_disabled=3Dmemory" kernel. So, please send your patch asap.

thanks,
Shakeel

