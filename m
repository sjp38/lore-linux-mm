Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8A1096B021C
	for <linux-mm@kvack.org>; Wed, 19 May 2010 11:45:01 -0400 (EDT)
Date: Thu, 20 May 2010 01:44:31 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Unexpected splice "always copy" behavior observed
Message-ID: <20100519154431.GC2516@laptop>
References: <20100518153440.GB7748@Krystal>
 <1274197993.26328.755.camel@gandalf.stny.rr.com>
 <1274199039.26328.758.camel@gandalf.stny.rr.com>
 <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org>
 <20100519063116.GR2516@laptop>
 <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org>
 <20100519151726.GB2516@laptop>
 <alpine.LFD.2.00.1005190828050.23538@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005190828050.23538@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 19, 2010 at 08:30:10AM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 20 May 2010, Nick Piggin wrote:
> > 
> > Well I mean a full invalidate -- invalidate_mapping_pages -- so there is
> > literally no pagecache there at all.
> 
> Umm. That won't work. Think mapped pages. You can't handle them 
> atomically, so somebody will page-fault them in.
> 
> So you'd have to have a "invalidate_and_replace()" to do it atomically 
> while holding the mapping spinlock or something. 
> 
> And WHAT IS THE POINT? That will be about a million times slower than 
> just doing the effing copy in the first place!
> 
> Memory copies are _not_ slow. Not compared to taking locks and doing TLB 
> invalidates.

No I never thought it would be a good idea to try to avoid all races
or anything. Obviously some cases *cannot* be easily invalidated, if
there is a ref on the page or whatever, so the fallback code has to
be there anyway.

So you would just invalidate and try to insert your page. 99.something%
of the time it will work fine. If the insert fails, fall back to
copying.

And hey you *may* even want a heuristic that avoids trying to invalidate
if the page is mapped, due to cost of TLB flushing and faulting etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
