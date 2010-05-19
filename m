Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5C7376008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 12:36:46 -0400 (EDT)
Subject: Re: Unexpected splice "always copy" behavior observed
From: Steven Rostedt <rostedt@goodmis.org>
Reply-To: rostedt@goodmis.org
In-Reply-To: <20100519155505.GD2516@laptop>
References: <20100518153440.GB7748@Krystal>
	 <1274197993.26328.755.camel@gandalf.stny.rr.com>
	 <1274199039.26328.758.camel@gandalf.stny.rr.com>
	 <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org>
	 <20100519063116.GR2516@laptop>
	 <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org>
	 <1274280968.26328.774.camel@gandalf.stny.rr.com>
	 <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org>
	 <E1OElGh-0005wc-I8@pomaz-ex.szeredi.hu>
	 <1274283942.26328.783.camel@gandalf.stny.rr.com>
	 <20100519155505.GD2516@laptop>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Wed, 19 May 2010 12:36:42 -0400
Message-ID: <1274287002.26328.808.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Linus Torvalds <torvalds@linux-foundation.org>, mathieu.desnoyers@efficios.com, peterz@infradead.org, fweisbec@gmail.com, tardyp@gmail.com, mingo@elte.hu, acme@redhat.com, tzanussi@gmail.com, paulus@samba.org, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, tj@kernel.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Thu, 2010-05-20 at 01:55 +1000, Nick Piggin wrote:
> On Wed, May 19, 2010 at 11:45:42AM -0400, Steven Rostedt wrote:

> > If the "move only on append to file" is easy to implement, I would
> > really like to see that happen. The speed of splicing a disk image for a
> > virtual machine only impacts the patience of the user. The speed of
> > splicing tracing output, impacts how much you can trace without losing
> > events.
> 
> It's not "easy" to implement :) What's your ring buffer look like?
> Is it a normal user address which the kernel does copy_to_user()ish
> things into? Or a mmapped special driver?

Neither ;-)

> 
> If the latter, it get's even harder again. But either way if the
> source pages just have to be regenerated anyway (eg. via page fault
> on next access), then it might not even be worthwhile to do the
> splice move.

The ring buffer is written to by kernel events. To read it, the user can
either do a sys_read() and that is copied, or use splice. I do not
support mmap(), and if we were to do that, it would then not support
splice(). We have been talking about implementing both but with flags on
allocation of the ring buffer. You can either support mmap() or splice()
but not both with one instance of the ring buffer.

-- Steve





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
