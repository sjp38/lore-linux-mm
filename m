Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFDCF6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 04:26:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j69so35469618pfc.7
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:26:42 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 84si8121284pfr.154.2016.10.12.01.26.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 01:26:42 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id s8so2241900pfj.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:26:42 -0700 (PDT)
Date: Wed, 12 Oct 2016 10:26:34 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: Re: [PATCH v2] z3fold: add shrinker
Message-Id: <20161012102634.f32cb17648eff6b2fd452aea@gmail.com>
In-Reply-To: <20161011225206.GJ23194@dastard>
References: <20161012001827.53ae55723e67d1dee2a2f839@gmail.com>
	<20161011225206.GJ23194@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 12 Oct 2016 09:52:06 +1100
Dave Chinner <david@fromorbit.com> wrote:

<snip>
> 
> > +static unsigned long z3fold_shrink_scan(struct shrinker *shrink,
> > +				struct shrink_control *sc)
> > +{
> > +	struct z3fold_pool *pool = container_of(shrink, struct z3fold_pool,
> > +						shrinker);
> > +	struct z3fold_header *zhdr;
> > +	int i, nr_to_scan = sc->nr_to_scan;
> > +
> > +	spin_lock(&pool->lock);
> 
> Do not do this. Shrinkers should not run entirely under a spin lock
> like this - it causes scheduling latency problems and when the
> shrinker is run concurrently on different CPUs it will simply burn
> CPU doing no useful work. Especially, in this case, as each call to
> z3fold_compact_page() may be copying a significant amount of data
> around and so there is potentially a /lot/ of work being done on
> each call to the shrinker.
> 
> If you need compaction exclusion for the shrinker invocation, then
> please use a sleeping lock to protect the compaction work.

Well, as far as I recall, spin_lock() will resolve to a sleeping lock
for PREEMPT_RT, so it is not that much of a problem for configurations
which do care much about latencies. Please also note that the time
spent in the loop is deterministic since we take not more than one entry
from every unbuddied list.

What I could do though is add the following piece of code at the end of
the loop, right after the /break/:
		spin_unlock(&pool->lock);
		cond_resched();
		spin_lock(&pool->lock);

Would that make sense for you?

> 
> >  *****************/
> > @@ -234,6 +335,13 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
> >  		INIT_LIST_HEAD(&pool->unbuddied[i]);
> >  	INIT_LIST_HEAD(&pool->buddied);
> >  	INIT_LIST_HEAD(&pool->lru);
> > +	pool->shrinker.count_objects = z3fold_shrink_count;
> > +	pool->shrinker.scan_objects = z3fold_shrink_scan;
> > +	pool->shrinker.seeks = DEFAULT_SEEKS;
> > +	if (register_shrinker(&pool->shrinker)) {
> > +		pr_warn("z3fold: could not register shrinker\n");
> > +		pool->no_shrinker = true;
> > +	} 
> 
> Just fail creation of the pool. If you can't register a shrinker,
> then much bigger problems are about to happen to your system, and
> running a new memory consumer that /can't be shrunk/ is not going to
> help anyone.

I don't have a strong opinion on this but it doesn't look fatal to me
in _this_ particular case (z3fold) since even without the shrinker, the
compression ratio will never be lower than the one of zbud, which
doesn't have a shrinker at all.

Best regards,
   Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
