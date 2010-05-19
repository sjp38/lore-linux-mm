Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 92F096B0214
	for <linux-mm@kvack.org>; Wed, 19 May 2010 02:31:23 -0400 (EDT)
Date: Wed, 19 May 2010 16:31:16 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Unexpected splice "always copy" behavior observed
Message-ID: <20100519063116.GR2516@laptop>
References: <20100518153440.GB7748@Krystal>
 <1274197993.26328.755.camel@gandalf.stny.rr.com>
 <1274199039.26328.758.camel@gandalf.stny.rr.com>
 <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 18, 2010 at 09:25:05AM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 18 May 2010, Steven Rostedt wrote:
> > 
> > Hopefully we can find a way to avoid the copy to file. But the splice
> > code was created to avoid the copy to and from userspace, it did not
> > guarantee no copy within the kernel itself.
> 
> Well, we always _wanted_ to splice directly to a file, but it's just not 
> been done properly. It's not entirely trivial, since you need to worry 
> about preexisting pages and generally just do the right thing wrt the 
> filesystem.
> 
> And no, it should NOT use migration code. I suspect you could do something 
> fairly simple like:

I was thinking it could possibly reuse some of the migration code for
swapping filesystem state to the new page. But I agree it gets hairy and
is probably better to just insert new pages.

> 
>  - get the inode semaphore.
>  - check if the splice is a pure "extend size" operation for that page
>  - if so, just create the page cache entry and mark it dirty
>  - otherwise, fall back to copying.
> 
> because the "extend file" case is the easiest one, and is likely the only 
> one that matters in practice (if you are overwriting an existing file, 
> things get _way_ hairier, and why the hell would anybody expect that to be 
> fast anyway?)
> 
> But somebody needs to write the code..

We can possibly do an attempt to invalidate existing pagecache and
then try to install the new page. The filesystem still needs a look
over to ensure error handling will work properly, and that it does
not make incorrect assumptions about the contents of the page being
passed in.

This still isn't ideal because we drop the filesystem state (eg bufer
heads) on a page which, by definition, will need to be written out soon.
But something smarter could be added if it turns out to be important.

Big if, because I don't like adding complex code without having a
really good reason. I do like having the splice flag there, though.
The more the app can tell the kernel the better. Hopefully people use
it and we can get a better idea of whether these fancy optimisations
will be worth it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
