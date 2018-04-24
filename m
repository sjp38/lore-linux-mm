Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83C486B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 07:08:37 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id f16-v6so4387616lfl.3
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 04:08:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4sor1416095lja.12.2018.04.24.04.08.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 04:08:36 -0700 (PDT)
Date: Tue, 24 Apr 2018 14:08:32 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 04/12] mm: Assign memcg-aware shrinkers bitmap to memcg
Message-ID: <20180424110832.barhpnnm5u2shmcu@esperanza>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
 <152399121146.3456.5459546288565589098.stgit@localhost.localdomain>
 <20180422175900.dsjmm7gt2nsqj3er@esperanza>
 <552aba74-c208-e959-0b4f-4784e68c6109@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <552aba74-c208-e959-0b4f-4784e68c6109@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Mon, Apr 23, 2018 at 02:06:31PM +0300, Kirill Tkhai wrote:
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 4f02fe83537e..f63eb5596c35 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -172,6 +172,22 @@ static DECLARE_RWSEM(shrinker_rwsem);
> >>  #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> >>  static DEFINE_IDR(shrinkers_id_idr);
> >>  
> >> +static int expand_shrinker_id(int id)
> >> +{
> >> +	if (likely(id < shrinkers_max_nr))
> >> +		return 0;
> >> +
> >> +	id = shrinkers_max_nr * 2;
> >> +	if (id == 0)
> >> +		id = BITS_PER_BYTE;
> >> +
> >> +	if (expand_shrinker_maps(shrinkers_max_nr, id))
> >> +		return -ENOMEM;
> >> +
> >> +	shrinkers_max_nr = id;
> >> +	return 0;
> >> +}
> >> +
> > 
> > I think this function should live in memcontrol.c and shrinkers_max_nr
> > should be private to memcontrol.c.
> 
> It can't be private as shrink_slab_memcg() uses this value to get the last bit of bitmap.

Yeah, you're right, sorry I haven't noticed that.

What about moving id allocation to this function as well? IMHO it would
make the code flow a little bit more straightforward. I mean,

alloc_shrinker_id()
{
	int id = idr_alloc(...)
	if (id >= memcg_nr_shrinker_ids)
		memcg_grow_shrinker_map(...)
	return id;
}

> 
> >>  static int add_memcg_shrinker(struct shrinker *shrinker)
> >>  {
> >>  	int id, ret;
> >> @@ -180,6 +196,11 @@ static int add_memcg_shrinker(struct shrinker *shrinker)
> >>  	ret = id = idr_alloc(&shrinkers_id_idr, shrinker, 0, 0, GFP_KERNEL);
> >>  	if (ret < 0)
> >>  		goto unlock;
> >> +	ret = expand_shrinker_id(id);
> >> +	if (ret < 0) {
> >> +		idr_remove(&shrinkers_id_idr, id);
> >> +		goto unlock;
> >> +	}
> >>  	shrinker->id = id;
> >>  	ret = 0;
> >>  unlock:
> >>
