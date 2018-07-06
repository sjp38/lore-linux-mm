Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEABA6B0005
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 13:50:40 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id m2-v6so2859647lfc.7
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 10:50:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t22-v6sor2062072lji.48.2018.07.06.10.50.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 10:50:39 -0700 (PDT)
Date: Fri, 6 Jul 2018 20:50:35 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v8 05/17] mm: Assign memcg-aware shrinkers bitmap to memcg
Message-ID: <20180706175034.lptwrafs5iomb6jf@esperanza>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
 <153063056619.1818.12550500883688681076.stgit@localhost.localdomain>
 <20180703135000.b2322ae0e514f028e7941d3c@linux-foundation.org>
 <aaa98988-29e9-fb81-1d36-6b8bd7a371be@virtuozzo.com>
 <20180705151030.c67eb9a989c5f0023a53d415@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180705151030.c67eb9a989c5f0023a53d415@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Thu, Jul 05, 2018 at 03:10:30PM -0700, Andrew Morton wrote:
> On Wed, 4 Jul 2018 18:51:12 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> 
> > > - why aren't we decreasing shrinker_nr_max in
> > >   unregister_memcg_shrinker()?  That's easy to do, avoids pointless
> > >   work in shrink_slab_memcg() and avoids memory waste in future
> > >   prealloc_memcg_shrinker() calls.
> > 
> > You sure, but there are some things. Initially I went in the same way
> > as memcg_nr_cache_ids is made and just took the same x2 arithmetic.
> > It never decreases, so it looked good to make shrinker maps like it.
> > It's the only reason, so, it should not be a problem to rework.
> > 
> > The only moment is Vladimir strongly recommends modularity, i.e.
> > to have memcg_shrinker_map_size and shrinker_nr_max as different variables.
> 
> For what reasons?

Having the only global variable updated in vmscan.c and used in
memcontrol.c or vice versa didn't look good to me. So I suggested to
introduce two separate static variables: one for max shrinker id (local
to vmscan.c) and another for max allocated size of per memcg shrinker
maps (local to memcontrol.c). Having the two variables instead of one
allows us to define a clear API between memcontrol.c and shrinker
infrastructure without sharing variables, which makes the code easier
to follow IMHO.

It is also more flexible: with the two variables we can decrease
shrinker_id_max when a shrinker is destroyed so that we can speed up
shrink_slab - this is fairly easy to do - but leave per memcg shrinker
maps the same size, because shrinking them is rather complicated and
doesn't seem to be worthwhile - the workload is likely to use the same
amount of memory again in the future.

> 
> > After the rework we won't be able to have this anymore, since memcontrol.c
> > will have to know actual shrinker_nr_max value and it will have to be exported.

Not necessarily. You can pass max shrinker id instead of the new id to
memcontrol.c in function arguments. But as I said before, I really don't
think that shrinking per memcg maps would make much sense.

> >
> > Could this be a problem?
