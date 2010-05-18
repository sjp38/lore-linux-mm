Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA2F6B01D0
	for <linux-mm@kvack.org>; Tue, 18 May 2010 12:28:23 -0400 (EDT)
Date: Tue, 18 May 2010 09:25:05 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Unexpected splice "always copy" behavior observed
In-Reply-To: <1274199039.26328.758.camel@gandalf.stny.rr.com>
Message-ID: <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org>
References: <20100518153440.GB7748@Krystal>  <1274197993.26328.755.camel@gandalf.stny.rr.com> <1274199039.26328.758.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>



On Tue, 18 May 2010, Steven Rostedt wrote:
> 
> Hopefully we can find a way to avoid the copy to file. But the splice
> code was created to avoid the copy to and from userspace, it did not
> guarantee no copy within the kernel itself.

Well, we always _wanted_ to splice directly to a file, but it's just not 
been done properly. It's not entirely trivial, since you need to worry 
about preexisting pages and generally just do the right thing wrt the 
filesystem.

And no, it should NOT use migration code. I suspect you could do something 
fairly simple like:

 - get the inode semaphore.
 - check if the splice is a pure "extend size" operation for that page
 - if so, just create the page cache entry and mark it dirty
 - otherwise, fall back to copying.

because the "extend file" case is the easiest one, and is likely the only 
one that matters in practice (if you are overwriting an existing file, 
things get _way_ hairier, and why the hell would anybody expect that to be 
fast anyway?)

But somebody needs to write the code..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
