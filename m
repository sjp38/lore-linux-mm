Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id C3B3C6B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 08:42:52 -0500 (EST)
Date: Wed, 9 Jan 2013 13:42:48 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130109134248.GE13304@suse.de>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
 <20130106120700.GA24671@dcvr.yhbt.net>
 <20130107122516.GC3885@suse.de>
 <20130107223850.GA21311@dcvr.yhbt.net>
 <20130108224313.GA13304@suse.de>
 <20130108232325.GA5948@dcvr.yhbt.net>
 <1357697647.18156.1217.camel@edumazet-glaptop>
 <1357698749.27446.6.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1357698749.27446.6.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Eric Wong <normalperson@yhbt.net>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Jan 08, 2013 at 06:32:29PM -0800, Eric Dumazet wrote:
> On Tue, 2013-01-08 at 18:14 -0800, Eric Dumazet wrote:
> > On Tue, 2013-01-08 at 23:23 +0000, Eric Wong wrote:
> > > Mel Gorman <mgorman@suse.de> wrote:
> > > > Please try the following patch. However, even if it works the benefit of
> > > > capture may be so marginal that partially reverting it and simplifying
> > > > compaction.c is the better decision.
> > > 
> > > I already got my VM stuck on this one.  I had two twosleepy instances,
> > > 2774 was the one that got stuck (also confirmed by watching top).
> > > 
> > > Btw, have you been able to reproduce this on your end?
> > > 
> > > I think the easiest reproduction on my 2-core VM is by running 2
> > > twosleepy processes and doing the following to dirty a lot of pages:
> > 
> > Given the persistent sk_stream_wait_memory() traces I suspect a plain
> > TCP bug, triggered by some extra wait somewhere.
> > 
> > Please mm guys don't spend too much time right now, I'll try to
> > reproduce the problem.
> > 
> > Don't be confused by sk_stream_wait_memory() name.
> > A thread is stuck here because TCP stack is failing to wake it.
> > 
> 
> Hmm, it seems sk_filter() can return -ENOMEM because skb has the
> pfmemalloc() set.
> 

The skb should not have pfmemalloc set in most cases, particularly after
cfd19c5a (mm: only set page->pfmemalloc when ALLOC_NO_WATERMARKS was used)
but the capture patch also failed to clear pfmemalloc properly so it could
be set in error.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
