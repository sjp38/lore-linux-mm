Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ED47A6008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 12:01:37 -0400 (EDT)
Date: Wed, 19 May 2010 12:01:35 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: Unexpected splice "always copy" behavior observed
Message-ID: <20100519160135.GC2039@Krystal>
References: <1274197993.26328.755.camel@gandalf.stny.rr.com> <1274199039.26328.758.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org> <20100519063116.GR2516@laptop> <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org> <1274280968.26328.774.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org> <E1OElGh-0005wc-I8@pomaz-ex.szeredi.hu> <1274283942.26328.783.camel@gandalf.stny.rr.com> <20100519155505.GD2516@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100519155505.GD2516@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Steven Rostedt <rostedt@goodmis.org>, Miklos Szeredi <miklos@szeredi.hu>, Linus Torvalds <torvalds@linux-foundation.org>, peterz@infradead.org, fweisbec@gmail.com, tardyp@gmail.com, mingo@elte.hu, acme@redhat.com, tzanussi@gmail.com, paulus@samba.org, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, tj@kernel.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

* Nick Piggin (npiggin@suse.de) wrote:
> On Wed, May 19, 2010 at 11:45:42AM -0400, Steven Rostedt wrote:
> > On Wed, 2010-05-19 at 17:33 +0200, Miklos Szeredi wrote:
> > > On Wed, 19 May 2010, Linus Torvalds wrote:
> > > > Btw, since you apparently have a real case - is the "splice to file" 
> > > > always just an append? IOW, if I'm not right in assuming that the only 
> > > > sane thing people would reasonable care about is "append to a file", then 
> > > > holler now.
> > > 
> > > Virtual machines might reasonably need this for splicing to a disk
> > > image.
> > 
> > This comes down to balancing speed and complexity. Perhaps a copy is
> > fine in this case.
> > 
> > I'm concerned about high speed tracing, where we are always just taking
> > pages from the trace ring buffer and appending them to a file or sending
> > them off to the network. The slower this is, the more likely you will
> > lose events.
> > 
> > If the "move only on append to file" is easy to implement, I would
> > really like to see that happen. The speed of splicing a disk image for a
> > virtual machine only impacts the patience of the user. The speed of
> > splicing tracing output, impacts how much you can trace without losing
> > events.
> 
> It's not "easy" to implement :) What's your ring buffer look like?
> Is it a normal user address which the kernel does copy_to_user()ish
> things into? Or a mmapped special driver?
> 
> If the latter, it get's even harder again. But either way if the
> source pages just have to be regenerated anyway (eg. via page fault
> on next access), then it might not even be worthwhile to do the
> splice move.

Steven and I use pages to which we write directly by using the page address from
the linear memory mapping returned by page_address(). These pages have no other
mapping. They are moved to the pipe, and then from the pipe to a file (or to the
network). It's possibly the simplest scenario you could think of for splice().

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
