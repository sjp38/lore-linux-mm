Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 06BC86B021A
	for <linux-mm@kvack.org>; Wed, 19 May 2010 15:14:42 -0400 (EDT)
Date: Wed, 19 May 2010 15:14:39 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: Unexpected splice "always copy" behavior observed
Message-ID: <20100519191439.GA2845@Krystal>
References: <1274199039.26328.758.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org> <20100519063116.GR2516@laptop> <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org> <1274280968.26328.774.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org> <E1OElGh-0005wc-I8@pomaz-ex.szeredi.hu> <1274283942.26328.783.camel@gandalf.stny.rr.com> <20100519155732.GB2039@Krystal> <20100519162729.GE2516@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100519162729.GE2516@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Steven Rostedt <rostedt@goodmis.org>, Miklos Szeredi <miklos@szeredi.hu>, Linus Torvalds <torvalds@linux-foundation.org>, peterz@infradead.org, fweisbec@gmail.com, tardyp@gmail.com, mingo@elte.hu, acme@redhat.com, tzanussi@gmail.com, paulus@samba.org, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, tj@kernel.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

* Nick Piggin (npiggin@suse.de) wrote:
> On Wed, May 19, 2010 at 11:57:32AM -0400, Mathieu Desnoyers wrote:
> > * Steven Rostedt (rostedt@goodmis.org) wrote:
> > > On Wed, 2010-05-19 at 17:33 +0200, Miklos Szeredi wrote:
> > > > On Wed, 19 May 2010, Linus Torvalds wrote:
> > > > > Btw, since you apparently have a real case - is the "splice to file" 
> > > > > always just an append? IOW, if I'm not right in assuming that the only 
> > > > > sane thing people would reasonable care about is "append to a file", then 
> > > > > holler now.
> > > > 
> > > > Virtual machines might reasonably need this for splicing to a disk
> > > > image.
> > > 
> > > This comes down to balancing speed and complexity. Perhaps a copy is
> > > fine in this case.
> > > 
> > > I'm concerned about high speed tracing, where we are always just taking
> > > pages from the trace ring buffer and appending them to a file or sending
> > > them off to the network. The slower this is, the more likely you will
> > > lose events.
> > > 
> > > If the "move only on append to file" is easy to implement, I would
> > > really like to see that happen. The speed of splicing a disk image for a
> > > virtual machine only impacts the patience of the user. The speed of
> > > splicing tracing output, impacts how much you can trace without losing
> > > events.
> > 
> > I'm with Steven here. I only care about appending full pages at the end of a
> > file. If possible, I'd also like to steal back the pages after waiting for the
> > writeback I/O to complete so we can put them back in the ring buffer without
> > stressing the page cache and the page allocator needlessly.
> 
> Got to think about complexity and how much is really worth trying to
> speed up strange cases. The page allocator is the generic "pipe" in
> the kernel to move pages between subsystems when they become unused :)
> 
> The page cache can be directed to be written out and discarded with
> fadvise and such.

Good point. This discard flag might do the trick and let us keep things simple.
The major concern here is to keep the page cache disturbance relatively low.
Which of new page allocation or stealing back the page has the lowest overhead
would have to be determined with benchmarks.

So I would tend to simply use this discard fadvise with new page allocation for
now.

> 
> You might also consider using direct IO.

Maybe. I'm unsure about what it implies in the splice() context though.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
