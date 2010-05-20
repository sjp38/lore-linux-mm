Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 09C6660032A
	for <linux-mm@kvack.org>; Thu, 20 May 2010 10:22:12 -0400 (EDT)
Date: Thu, 20 May 2010 07:18:21 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Unexpected splice "always copy" behavior observed
In-Reply-To: <20100520015605.GA28411@Krystal>
Message-ID: <alpine.LFD.2.00.1005200715460.23538@i5.linux-foundation.org>
References: <1274280968.26328.774.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org> <E1OElGh-0005wc-I8@pomaz-ex.szeredi.hu> <1274283942.26328.783.camel@gandalf.stny.rr.com> <20100519155732.GB2039@Krystal>
 <20100519162729.GE2516@laptop> <20100519191439.GA2845@Krystal> <alpine.LFD.2.00.1005191220370.23538@i5.linux-foundation.org> <20100519214905.GA22486@Krystal> <alpine.LFD.2.00.1005191659100.23538@i5.linux-foundation.org> <20100520015605.GA28411@Krystal>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Nick Piggin <npiggin@suse.de>, Steven Rostedt <rostedt@goodmis.org>, Miklos Szeredi <miklos@szeredi.hu>, peterz@infradead.org, fweisbec@gmail.com, tardyp@gmail.com, mingo@elte.hu, acme@redhat.com, tzanussi@gmail.com, paulus@samba.org, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, tj@kernel.org, jens.axboe@oracle.com, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org
List-ID: <linux-mm.kvack.org>



On Wed, 19 May 2010, Mathieu Desnoyers wrote:
> 
>        Programs  can  use  posix_fadvise()  to announce an intention to access
>        file data in a specific pattern in the future, thus allowing the kernel
>        to perform appropriate optimizations.

It's true for some of them. The random-vs-linear behavior is a flag for 
the future, for example (relevant for prefetching).

In fact, it's technically true even for DONTNEED. It's true that we won't 
need the pages in the future! So we throw the pages away. But that means 
that we throw the _current_ pages away.

If we actually touch pages later, than that obviously invalidates the fact 
that we said 'DONTNEED' - we clearly needed them.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
