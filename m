Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4FFA16B002C
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 05:15:09 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h92-v6so6842313lfi.21
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 02:15:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v6sor184883ljg.22.2018.03.27.02.15.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 02:15:07 -0700 (PDT)
Date: Tue, 27 Mar 2018 12:15:04 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 01/10] mm: Assign id to every memcg-aware shrinker
Message-ID: <20180327091504.zcqvr3mkuznlgwux@esperanza>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163847740.21546.16821490541519326725.stgit@localhost.localdomain>
 <20180324184009.dyjlt4rj4b6y6sz3@esperanza>
 <0db2d93f-12cd-d703-fce7-4c3b8df5bc12@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0db2d93f-12cd-d703-fce7-4c3b8df5bc12@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On Mon, Mar 26, 2018 at 06:09:35PM +0300, Kirill Tkhai wrote:
> Hi, Vladimir,
> 
> thanks for your review!
> 
> On 24.03.2018 21:40, Vladimir Davydov wrote:
> > Hello Kirill,
> > 
> > I don't have any objections to the idea behind this patch set.
> > Well, at least I don't know how to better tackle the problem you
> > describe in the cover letter. Please, see below for my comments
> > regarding implementation details.
> > 
> > On Wed, Mar 21, 2018 at 04:21:17PM +0300, Kirill Tkhai wrote:
> >> The patch introduces shrinker::id number, which is used to enumerate
> >> memcg-aware shrinkers. The number start from 0, and the code tries
> >> to maintain it as small as possible.
> >>
> >> This will be used as to represent a memcg-aware shrinkers in memcg
> >> shrinkers map.
> >>
> >> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> >> ---
> >>  include/linux/shrinker.h |    1 +
> >>  mm/vmscan.c              |   59 ++++++++++++++++++++++++++++++++++++++++++++++
> >>  2 files changed, 60 insertions(+)
> >>
> >> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> >> index a3894918a436..738de8ef5246 100644
> >> --- a/include/linux/shrinker.h
> >> +++ b/include/linux/shrinker.h
> >> @@ -66,6 +66,7 @@ struct shrinker {
> >>  
> >>  	/* These are for internal use */
> >>  	struct list_head list;
> >> +	int id;
> > 
> > This definition could definitely use a comment.
> > 
> > BTW shouldn't we ifdef it?
> 
> Ok
> 
> >>  	/* objs pending delete, per node */
> >>  	atomic_long_t *nr_deferred;
> >>  };
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 8fcd9f8d7390..91b5120b924f 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -159,6 +159,56 @@ unsigned long vm_total_pages;
> >>  static LIST_HEAD(shrinker_list);
> >>  static DECLARE_RWSEM(shrinker_rwsem);
> >>  
> >> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> >> +static DEFINE_IDA(bitmap_id_ida);
> >> +static DECLARE_RWSEM(bitmap_rwsem);
> > 
> > Can't we reuse shrinker_rwsem for protecting the ida?
> 
> I think it won't be better, since we allocate memory under this semaphore.
> After we use shrinker_rwsem, we'll have to allocate the memory with GFP_ATOMIC,
> which does not seems good. Currently, the patchset makes shrinker_rwsem be taken
> for a small time, just to assign already allocated memory to maps.

AFAIR it's OK to sleep under an rwsem so GFP_ATOMIC wouldn't be
necessary. Anyway, we only need to allocate memory when we extend
shrinker bitmaps, which is rare. In fact, there can only be a limited
number of such calls, as we never shrink these bitmaps (which is fine
by me).

> 
> >> +static int bitmap_id_start;
> >> +
> >> +static int alloc_shrinker_id(struct shrinker *shrinker)
> >> +{
> >> +	int id, ret;
> >> +
> >> +	if (!(shrinker->flags & SHRINKER_MEMCG_AWARE))
> >> +		return 0;
> >> +retry:
> >> +	ida_pre_get(&bitmap_id_ida, GFP_KERNEL);
> >> +	down_write(&bitmap_rwsem);
> >> +	ret = ida_get_new_above(&bitmap_id_ida, bitmap_id_start, &id);
> > 
> > AFAIK ida always allocates the smallest available id so you don't need
> > to keep track of bitmap_id_start.
> 
> I saw mnt_alloc_group_id() does the same, so this was the reason, the additional
> variable was used. Doesn't this gives a good advise to ida and makes it find
> a free id faster?

As Matthew pointed out, this is rather pointless.
