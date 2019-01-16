Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 242D48E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:08:48 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id v64so6560133qka.5
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:08:48 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d10sor86390475qvn.64.2019.01.16.13.08.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 13:08:47 -0800 (PST)
MIME-Version: 1.0
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com> <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
 <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com> <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
 <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com> <CAHbLzkrE887hR_2o_1zJkBcReDt-KzezUE4Jug8zULdV7g17-w@mail.gmail.com>
 <9B56B884-8FDD-4BB5-A6CA-AD7F84397039@bytedance.com> <CAHbLzkpHst6bA=eVjoHRFuCuOfo8kKnCPE7Tg4voaJ_kwruVqw@mail.gmail.com>
 <C7C72217-D4AF-474C-A98E-975E389BC85C@bytedance.com> <20190116070614.GG24149@dhcp22.suse.cz>
In-Reply-To: <20190116070614.GG24149@dhcp22.suse.cz>
From: Yang Shi <shy828301@gmail.com>
Date: Wed, 16 Jan 2019 13:08:35 -0800
Message-ID: <CAHbLzkrtofJ8jv8DFX=ngWvwsXn_TXMd8JicqtP-xc7gM0c6hQ@mail.gmail.com>
Subject: Re: memory cgroup pagecache and inode problem
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Fam Zheng <zhengfeiran@bytedance.com>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?UTF-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com

On Tue, Jan 15, 2019 at 11:06 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 16-01-19 11:52:08, Fam Zheng wrote:
> [...]
> > > This is what force_empty is supposed to do.  But, as your test shows
> > > some page cache may still remain after force_empty, then cause offlin=
e
> > > memcgs accumulated.  I haven't figured out what happened.  You may tr=
y
> > > what Michal suggested.
> >
> > None of the existing patches helped so far, but we suspect that the
> > pages cannot be locked at the force_empty moment. We have being
> > working on a =E2=80=9Cretry=E2=80=9D patch which does solve the problem=
. We=E2=80=99ll
> > do more tracing (to have a better understanding of the issue) and post
> > the findings and/or the patch later. Thanks.
>
> Just for the record. There was a patch to remove
> MEM_CGROUP_RECLAIM_RETRIES restriction in the path. I cannot find the
> link right now but that is something we certainly can do. The context is
> interruptible by signal and it from my experience any retry count can

Do you mean this one https://lore.kernel.org/patchwork/patch/865835/ ?

I think removing retries is feasible as long as exit is handled correctly.

Yang

> lead to unexpected failures. But I guess you really want to check
> vmscan tracepoints to see why you cannot reclaim pages on memcg LRUs
> first.
> --
> Michal Hocko
> SUSE Labs
