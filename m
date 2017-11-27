Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA5E6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 01:31:58 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 4so28030041pge.8
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 22:31:58 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h14si6939846pfj.360.2017.11.26.22.31.56
        for <linux-mm@kvack.org>;
        Sun, 26 Nov 2017 22:31:57 -0800 (PST)
Date: Mon, 27 Nov 2017 15:31:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Do not stall register_shrinker
Message-ID: <20171127063154.GA27559@bbox>
References: <1511481899-20335-1-git-send-email-minchan@kernel.org>
 <cb35065d-b100-533b-04c1-1188a75220a2@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cb35065d-b100-533b-04c1-1188a75220a2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Nov 27, 2017 at 11:16:46AM +0530, Anshuman Khandual wrote:
> On 11/24/2017 05:34 AM, Minchan Kim wrote:
> > Shakeel Butt reported, he have observed in production system that
> > the job loader gets stuck for 10s of seconds while doing mount
> > operation. It turns out that it was stuck in register_shrinker()
> > and some unrelated job was under memory pressure and spending time
> > in shrink_slab(). Machines have a lot of shrinkers registered and
> > jobs under memory pressure has to traverse all of those memcg-aware
> > shrinkers and do affect unrelated jobs which want to register their
> > own shrinkers.
> > 
> > To solve the issue, this patch simply bails out slab shrinking
> > once it found someone want to register shrinker in parallel.
> > A downside is it could cause unfair shrinking between shrinkers.
> > However, it should be rare and we can add compilcated logic once
> > we found it's not enough.
> > 
> > Link: http://lkml.kernel.org/r/20171115005602.GB23810@bbox
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Reported-and-tested-by: Shakeel Butt <shakeelb@google.com>
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/vmscan.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 6a5a72baccd5..6698001787bd 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -486,6 +486,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
> >  			sc.nid = 0;
> >  
> >  		freed += do_shrink_slab(&sc, shrinker, priority);
> > +		/*
> > +		 * bail out if someone want to register a new shrinker to
> > +		 * prevent long time stall by parallel ongoing shrinking.
> > +		 */
> > +		if (rwsem_is_contended(&shrinker_rwsem)) {
> > +			freed = freed ? : 1;
> > +			break;
> > +		}
> 
> This is similar to when it aborts for not being able to grab the
> shrinker_rwsem at the beginning.
> 
> if (!down_read_trylock(&shrinker_rwsem)) {
> 	/*
> 	 * If we would return 0, our callers would understand that we
> 	 * have nothing else to shrink and give up trying. By returning
> 	 * 1 we keep it going and assume we'll be able to shrink next
> 	 * time.
> 	 */
> 	freed = 1;
> 	goto out;
> }
> 
> Right now, shrink_slab() is getting called from three places. Twice in
> shrink_node() and once in drop_slab_node(). But the return value from
> shrink_slab() is checked only inside drop_slab_node() and it has some
> heuristics to decide whether to keep on scanning over available memcg
> shrinkers registered.
> 
> The question is does aborting here will still guarantee forward progress
> for all the contexts which might be attempting to allocate memory and had
> eventually invoked shrink_slab() ? Because may be the memory allocation
> request has more priority than a context getting bit delayed while being
> stuck waiting on shrinker_rwsem.

Some of routines relied on temporal return's value of shrink_slab to make
decisions in procedure of progress of reclaimaing. It might affect whole
procedure progress of shrinking at that time. However, we have removed such
heusristic and unified it with checking forard progress during MAX_RECAIM_RETRIES
trial so I don't think it makes big difference.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
