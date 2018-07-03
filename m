Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5F76B0005
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 13:58:44 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f10-v6so1263319pgv.22
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:58:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f18-v6si1491694pgd.16.2018.07.03.10.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Jul 2018 10:58:43 -0700 (PDT)
Date: Tue, 3 Jul 2018 10:58:08 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v8 03/17] mm: Assign id to every memcg-aware shrinker
Message-ID: <20180703175808.GC4834@bombadil.infradead.org>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
 <153063054586.1818.6041047871606697364.stgit@localhost.localdomain>
 <20180703152723.GB21590@bombadil.infradead.org>
 <2d845a0d-d147-7250-747e-27e493b6a627@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2d845a0d-d147-7250-747e-27e493b6a627@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lirongqing@baidu.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org

On Tue, Jul 03, 2018 at 06:46:57PM +0300, Kirill Tkhai wrote:
> shrinker_idr now contains only memcg-aware shrinkers, so all bits from memcg map
> may be potentially populated. In case of memcg-aware shrinkers and !memcg-aware
> shrinkers share the same numbers like you suggest, this will lead to increasing
> size of memcg maps, which is bad for memory consumption. So, memcg-aware shrinkers
> should to have its own IDR and its own numbers. The tricks like allocation big
> IDs for !memcg-aware shrinkers seem bad for me, since they make the code more
> complicated.

Do we really have so very many !memcg-aware shrinkers?

$ git grep -w register_shrinker |wc
     32     119    2221
$ git grep -w register_shrinker_prepared |wc
      4      13     268
(that's an overstatement; one of those is the declaration, one the definition,
and one an internal call, so we actually only have one caller of _prepared).

So it looks to me like your average system has one shrinker per
filesystem, one per graphics card, one per raid5 device, and a few
miscellaneous.  I'd be shocked if anybody had more than 100 shrinkers
registered on their laptop.

I think we should err on the side of simiplicity and just have one IDR for
every shrinker instead of playing games to solve a theoretical problem.

> > This will actually reduce the size of each shrinker and be more
> > cache-efficient when calling the shrinkers.  I think we can also get
> > rid of the shrinker_rwsem eventually, but let's leave it for now.
> 
> This patchset does not make the cache-efficient bad, since without the patchset the situation
> is so bad, that it's just impossible to talk about the cache efficiently,
> so let's leave lockless iteration/etc for the future works.

The situation is that bad /for your use case/.  Not so much for others.
You're introducing additional complexity here, and it'd be nice if we
can remove some of the complexity that's already there.
