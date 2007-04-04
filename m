In-reply-to: <1175684461.6483.64.camel@twins> (message from Peter Zijlstra on
	Wed, 04 Apr 2007 13:01:01 +0200)
Subject: Re: [PATCH 6/6] mm: per device dirty threshold
References: <20070403144047.073283598@taijtu.programming.kicks-ass.net>
	 <20070403144224.709586192@taijtu.programming.kicks-ass.net>
	 <E1HZ1so-0005q8-00@dorka.pomaz.szeredi.hu> <1175681794.6483.43.camel@twins>
	 <E1HZ2kU-0005xx-00@dorka.pomaz.szeredi.hu> <1175684461.6483.64.camel@twins>
Message-Id: <E1HZ3Q9-00062G-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 04 Apr 2007 13:12:57 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

> > > so it could be that: scale / cycle > 1
> > > by a very small amount; however:
> > 
> > No, I'm worried about the case when scale is too small.  If the
> > per-bdi threshold becomes smaller than stat_threshold, then things
> > won't work, because dirty+writeback will never go below the threshold,
> > possibly resulting in the deadlock we are trying to avoid.
> 
> /me goes refresh the deadlock details..
> 
> A writes to B; A exceeds the dirty limit but writeout is blocked by B
> because the dirty limit is exceeded, right?
> 
> This cannot happen when we decouple the BDI dirty thresholds, even when
> a threshold is 0.
> 
> A write to B; A exceeds A's limit and writes to B, B has limit of 0, the
> 1 dirty page gets written out (we gain ratio) and life goes on.
> 
> Right?

If the limit is zero, then we need the per-bdi dirty+write to go to
zero, otherwise balance_dirty_pages() loops.  But the per-bdi
writeback counter is not necessarily updated after the writeback,
because the per-bdi per-CPU counter may not trip the update of the
per-bdi counter.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
