Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 82A416B0022
	for <linux-mm@kvack.org>; Wed, 18 May 2011 13:21:14 -0400 (EDT)
Date: Wed, 18 May 2011 12:21:08 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/4] mm: slub: Do not wake kswapd for SLUBs speculative
 high-order allocations
In-Reply-To: <4DD36299.8000108@cs.helsinki.fi>
Message-ID: <alpine.DEB.2.00.1105181218520.12423@router.home>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de> <1305295404-12129-3-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1105161410090.4353@chino.kir.corp.google.com> <4DD36299.8000108@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, 18 May 2011, Pekka Enberg wrote:

> On 5/17/11 12:10 AM, David Rientjes wrote:
> > On Fri, 13 May 2011, Mel Gorman wrote:
> >
> > > To avoid locking and per-cpu overhead, SLUB optimisically uses
> > > high-order allocations and falls back to lower allocations if they
> > > fail.  However, by simply trying to allocate, kswapd is woken up to
> > > start reclaiming at that order. On a desktop system, two users report
> > > that the system is getting locked up with kswapd using large amounts
> > > of CPU.  Using SLAB instead of SLUB made this problem go away.
> > >
> > > This patch prevents kswapd being woken up for high-order allocations.
> > > Testing indicated that with this patch applied, the system was much
> > > harder to hang and even when it did, it eventually recovered.
> > >
> > > Signed-off-by: Mel Gorman<mgorman@suse.de>
> > Acked-by: David Rientjes<rientjes@google.com>
>
> Christoph? I think this patch is sane although the original rationale was to
> workaround kswapd problems.

I am mostly fine with it. The concerns that I have is if there is a
large series of high order allocs then at some point you would want
kswapd to be triggered instead of high order allocs constantly failing.

Can we have a "trigger once in a while" functionality?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
