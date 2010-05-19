Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8B8E16008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 11:57:34 -0400 (EDT)
Date: Wed, 19 May 2010 11:57:32 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: Unexpected splice "always copy" behavior observed
Message-ID: <20100519155732.GB2039@Krystal>
References: <20100518153440.GB7748@Krystal> <1274197993.26328.755.camel@gandalf.stny.rr.com> <1274199039.26328.758.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org> <20100519063116.GR2516@laptop> <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org> <1274280968.26328.774.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org> <E1OElGh-0005wc-I8@pomaz-ex.szeredi.hu> <1274283942.26328.783.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1274283942.26328.783.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Linus Torvalds <torvalds@linux-foundation.org>, npiggin@suse.de, peterz@infradead.org, fweisbec@gmail.com, tardyp@gmail.com, mingo@elte.hu, acme@redhat.com, tzanussi@gmail.com, paulus@samba.org, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, tj@kernel.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

* Steven Rostedt (rostedt@goodmis.org) wrote:
> On Wed, 2010-05-19 at 17:33 +0200, Miklos Szeredi wrote:
> > On Wed, 19 May 2010, Linus Torvalds wrote:
> > > Btw, since you apparently have a real case - is the "splice to file" 
> > > always just an append? IOW, if I'm not right in assuming that the only 
> > > sane thing people would reasonable care about is "append to a file", then 
> > > holler now.
> > 
> > Virtual machines might reasonably need this for splicing to a disk
> > image.
> 
> This comes down to balancing speed and complexity. Perhaps a copy is
> fine in this case.
> 
> I'm concerned about high speed tracing, where we are always just taking
> pages from the trace ring buffer and appending them to a file or sending
> them off to the network. The slower this is, the more likely you will
> lose events.
> 
> If the "move only on append to file" is easy to implement, I would
> really like to see that happen. The speed of splicing a disk image for a
> virtual machine only impacts the patience of the user. The speed of
> splicing tracing output, impacts how much you can trace without losing
> events.

I'm with Steven here. I only care about appending full pages at the end of a
file. If possible, I'd also like to steal back the pages after waiting for the
writeback I/O to complete so we can put them back in the ring buffer without
stressing the page cache and the page allocator needlessly.

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
