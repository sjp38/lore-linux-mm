Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1086B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 23:29:15 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y17-v6so3855891lfj.19
        for <linux-mm@kvack.org>; Mon, 14 May 2018 20:29:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h84-v6sor2391576lfl.97.2018.05.14.20.29.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 20:29:13 -0700 (PDT)
Date: Tue, 15 May 2018 06:29:09 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v5 01/13] mm: Assign id to every memcg-aware shrinker
Message-ID: <20180515032909.kjbhxxg7463nnvwo@esperanza>
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
 <152594593798.22949.6730606876057040426.stgit@localhost.localdomain>
 <20180513051509.df2tcmbhxn3q2fp7@esperanza>
 <e4889603-c337-c389-a819-17f8d4fd03ad@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e4889603-c337-c389-a819-17f8d4fd03ad@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Mon, May 14, 2018 at 12:03:38PM +0300, Kirill Tkhai wrote:
> On 13.05.2018 08:15, Vladimir Davydov wrote:
> > On Thu, May 10, 2018 at 12:52:18PM +0300, Kirill Tkhai wrote:
> >> The patch introduces shrinker::id number, which is used to enumerate
> >> memcg-aware shrinkers. The number start from 0, and the code tries
> >> to maintain it as small as possible.
> >>
> >> This will be used as to represent a memcg-aware shrinkers in memcg
> >> shrinkers map.
> >>
> >> Since all memcg-aware shrinkers are based on list_lru, which is per-memcg
> >> in case of !SLOB only, the new functionality will be under MEMCG && !SLOB
> >> ifdef (symlinked to CONFIG_MEMCG_SHRINKER).
> > 
> > Using MEMCG && !SLOB instead of introducing a new config option was done
> > deliberately, see:
> > 
> >   http://lkml.kernel.org/r/20151210202244.GA4809@cmpxchg.org
> > 
> > I guess, this doesn't work well any more, as there are more and more
> > parts depending on kmem accounting, like shrinkers. If you really want
> > to introduce a new option, I think you should call it CONFIG_MEMCG_KMEM
> > and use it consistently throughout the code instead of MEMCG && !SLOB.
> > And this should be done in a separate patch.
> 
> What do you mean under "consistently throughout the code"? Should I replace
> all MEMCG && !SLOB with CONFIG_MEMCG_KMEM over existing code?

Yes, otherwise it looks messy - in some places we check !SLOB, in others
we use CONFIG_MEMCG_SHRINKER (or whatever it will be called).

> 
> >> diff --git a/fs/super.c b/fs/super.c
> >> index 122c402049a2..16c153d2f4f1 100644
> >> --- a/fs/super.c
> >> +++ b/fs/super.c
> >> @@ -248,6 +248,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
> >>  	s->s_time_gran = 1000000000;
> >>  	s->cleancache_poolid = CLEANCACHE_NO_POOL;
> >>  
> >> +#ifdef CONFIG_MEMCG_SHRINKER
> >> +	s->s_shrink.id = -1;
> >> +#endif
> > 
> > No point doing that - you are going to overwrite the id anyway in
> > prealloc_shrinker().
> 
> Not so, this is done deliberately. alloc_super() has the only "fail" label,
> and it handles all the allocation errors there. The patch just behaves in
> the same style. It sets "-1" to make destroy_unused_super() able to differ
> the cases, when shrinker is really initialized, and when it's not.
> If you don't like this, I can move "s->s_shrink.id = -1;" into
> prealloc_memcg_shrinker() instead of this.

Yes, please do so that we don't have MEMCG ifdefs in fs code.

Thanks.
