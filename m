Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E28AC6B0007
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 15:19:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q8-v6so1126760wmc.2
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 12:19:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e140-v6sor609935wma.4.2018.07.03.12.19.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 12:19:48 -0700 (PDT)
MIME-Version: 1.0
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
 <153063054586.1818.6041047871606697364.stgit@localhost.localdomain>
 <20180703152723.GB21590@bombadil.infradead.org> <2d845a0d-d147-7250-747e-27e493b6a627@virtuozzo.com>
 <20180703175808.GC4834@bombadil.infradead.org> <94c282fd-1b5a-e959-b344-01a51fd5fc2e@virtuozzo.com>
In-Reply-To: <94c282fd-1b5a-e959-b344-01a51fd5fc2e@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 3 Jul 2018 12:19:35 -0700
Message-ID: <CALvZod7v4n62PVvC50VSNV12ZV0WdsY4GOQt68EmY4u5fc9hfQ@mail.gmail.com>
Subject: Re: [PATCH v8 03/17] mm: Assign id to every memcg-aware shrinker
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, stummala@codeaurora.org, gregkh@linuxfoundation.org, Stephen Rothwell <sfr@canb.auug.org.au>, Roman Gushchin <guro@fb.com>, mka@chromium.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Chris Wilson <chris@chris-wilson.co.uk>, longman@redhat.com, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, jbacik@fb.com, Guenter Roeck <linux@roeck-us.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, lirongqing@baidu.com, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jul 3, 2018 at 12:13 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> On 03.07.2018 20:58, Matthew Wilcox wrote:
> > On Tue, Jul 03, 2018 at 06:46:57PM +0300, Kirill Tkhai wrote:
> >> shrinker_idr now contains only memcg-aware shrinkers, so all bits from memcg map
> >> may be potentially populated. In case of memcg-aware shrinkers and !memcg-aware
> >> shrinkers share the same numbers like you suggest, this will lead to increasing
> >> size of memcg maps, which is bad for memory consumption. So, memcg-aware shrinkers
> >> should to have its own IDR and its own numbers. The tricks like allocation big
> >> IDs for !memcg-aware shrinkers seem bad for me, since they make the code more
> >> complicated.
> >
> > Do we really have so very many !memcg-aware shrinkers?
> >
> > $ git grep -w register_shrinker |wc
> >      32     119    2221
> > $ git grep -w register_shrinker_prepared |wc
> >       4      13     268
> > (that's an overstatement; one of those is the declaration, one the definition,
> > and one an internal call, so we actually only have one caller of _prepared).
> >
> > So it looks to me like your average system has one shrinker per
> > filesystem, one per graphics card, one per raid5 device, and a few
> > miscellaneous.  I'd be shocked if anybody had more than 100 shrinkers
> > registered on their laptop.
> >
> > I think we should err on the side of simiplicity and just have one IDR for
> > every shrinker instead of playing games to solve a theoretical problem.
>
> It just a standard situation for the systems with many containers. Every mount
> introduce a new shrinker to the system, so it's easy to see a system with
> 100 or ever 1000 shrinkers. AFAIR, Shakeel said he also has the similar
> configurations.
>

I can say on our production systems, a couple thousand shrinkers is normal.

Shakeel
