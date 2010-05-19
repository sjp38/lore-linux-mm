Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3529B6008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 11:33:28 -0400 (EDT)
Date: Wed, 19 May 2010 08:30:10 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Unexpected splice "always copy" behavior observed
In-Reply-To: <20100519151726.GB2516@laptop>
Message-ID: <alpine.LFD.2.00.1005190828050.23538@i5.linux-foundation.org>
References: <20100518153440.GB7748@Krystal> <1274197993.26328.755.camel@gandalf.stny.rr.com> <1274199039.26328.758.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org> <20100519063116.GR2516@laptop>
 <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org> <20100519151726.GB2516@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>



On Thu, 20 May 2010, Nick Piggin wrote:
> 
> Well I mean a full invalidate -- invalidate_mapping_pages -- so there is
> literally no pagecache there at all.

Umm. That won't work. Think mapped pages. You can't handle them 
atomically, so somebody will page-fault them in.

So you'd have to have a "invalidate_and_replace()" to do it atomically 
while holding the mapping spinlock or something. 

And WHAT IS THE POINT? That will be about a million times slower than 
just doing the effing copy in the first place!

Memory copies are _not_ slow. Not compared to taking locks and doing TLB 
invalidates.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
