Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9736F6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 02:46:48 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so2111308pad.9
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 23:46:48 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tn3si26351835pab.3.2015.01.12.23.46.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 23:46:47 -0800 (PST)
Date: Tue, 13 Jan 2015 10:46:33 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 1/2] mm: vmscan: account slab pages on memcg reclaim
Message-ID: <20150113074633.GG2110@esperanza>
References: <880700a513472a8b86fd3100aef674322c66c68e.1421054931.git.vdavydov@parallels.com>
 <20150112221839.GB25609@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150112221839.GB25609@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 12, 2015 at 05:18:39PM -0500, Johannes Weiner wrote:
> On Mon, Jan 12, 2015 at 12:30:37PM +0300, Vladimir Davydov wrote:
> > Since try_to_free_mem_cgroup_pages() can now call slab shrinkers, we
> > should initialize reclaim_state and account reclaimed slab pages in
> > scan_control->nr_reclaimed.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> > ---
> >  mm/vmscan.c |   33 ++++++++++++++++++++++-----------
> >  1 file changed, 22 insertions(+), 11 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 16f3e45742d6..b2c041139a51 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -367,13 +367,16 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> >   * the ->seeks setting of the shrink function, which indicates the
> >   * cost to recreate an object relative to that of an LRU page.
> >   *
> > - * Returns the number of reclaimed slab objects.
> > + * Returns the number of reclaimed slab objects. The number of reclaimed
> > + * pages is added to *@ret_nr_reclaimed.
> >
> >  static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
> >  				 struct mem_cgroup *memcg,
> >  				 unsigned long nr_scanned,
> > -				 unsigned long nr_eligible)
> > +				 unsigned long nr_eligible,
> > +				 unsigned long *ret_nr_reclaimed)
> 
> Can't we just return the number of pages directly from this function?

Hmm, we can. That would look better, of course. However, reclaimed_slab
can be 0 even if we reclaimed tons of dentries/inodes, simply because
they are freed by rcu. In this case, we can abort drop_slab beforehand.
Do you think it's OK?

Thanks,
Vladimir

> 
> > @@ -426,7 +434,7 @@ void drop_slab_node(int nid)
> >  		freed = 0;
> >  		do {
> >  			freed += shrink_slab(GFP_KERNEL, nid, memcg,
> > -					     1000, 1000);
> > +					     1000, 1000, &nr_reclaimed);
> >  		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
> >  	} while (freed > 10);
> 
> This is the only caller that cares about the return value, and it's a
> magic number that could probably be changed to comparing with a magic
> number of pages instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
