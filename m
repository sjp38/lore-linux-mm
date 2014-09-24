Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6A16B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 17:03:34 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id a1so6411945wgh.1
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 14:03:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id nf1si894185wic.82.2014.09.24.14.03.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 14:03:32 -0700 (PDT)
Date: Wed, 24 Sep 2014 17:03:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] mm: memcontrol: do not kill uncharge batching in
 free_pages_and_swap_cache
Message-ID: <20140924210322.GA11017@cmpxchg.org>
References: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
 <1411571338-8178-2-git-send-email-hannes@cmpxchg.org>
 <20140924124234.3fdb59d6cdf7e9c4d6260adb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140924124234.3fdb59d6cdf7e9c4d6260adb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 24, 2014 at 12:42:34PM -0700, Andrew Morton wrote:
> On Wed, 24 Sep 2014 11:08:56 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > +}
> > +/*
> > + * Batched page_cache_release(). Frees and uncharges all given pages
> > + * for which the reference count drops to 0.
> > + */
> > +void release_pages(struct page **pages, int nr, bool cold)
> > +{
> > +	LIST_HEAD(pages_to_free);
> >  
> > +	while (nr) {
> > +		int batch = min(nr, PAGEVEC_SIZE);
> > +
> > +		release_lru_pages(pages, batch, &pages_to_free);
> > +		pages += batch;
> > +		nr -= batch;
> > +	}
> 
> The use of PAGEVEC_SIZE here is pretty misleading - there are no
> pagevecs in sight.  SWAP_CLUSTER_MAX would be more appropriate.
> 
> 
> 
> afaict the only reason for this loop is to limit the hold duration for
> lru_lock.  And it does a suboptimal job of that because it treats all
> lru_locks as one: if release_lru_pages() were to hold zoneA's lru_lock
> for 8 pages and then were to drop that and hold zoneB's lru_lock for 8
> pages, the logic would then force release_lru_pages() to drop the lock
> and return to release_pages() even though it doesn't need to.
> 
> So I'm thinking it would be better to move the lock-busting logic into
> release_lru_pages() itself.  With a suitable comment, natch ;) Only
> bust the lock in the case where we really did hold a particular lru_lock
> for 16 consecutive pages.  Then s/release_lru_pages/release_pages/ and
> zap the old release_pages().

Yeah, that's better.

> Obviously it's not very important - presumably the common case is that
> the LRU contains lengthy sequences of pages from the same zone.  Maybe.

Even then, the end result is more concise and busts the lock where
it's actually taken, making the whole thing a bit more obvious:

---
