Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5C46008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 20:07:21 -0400 (EDT)
Date: Wed, 19 May 2010 17:04:07 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Unexpected splice "always copy" behavior observed
In-Reply-To: <20100519214905.GA22486@Krystal>
Message-ID: <alpine.LFD.2.00.1005191659100.23538@i5.linux-foundation.org>
References: <20100519063116.GR2516@laptop> <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org> <1274280968.26328.774.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org> <E1OElGh-0005wc-I8@pomaz-ex.szeredi.hu>
 <1274283942.26328.783.camel@gandalf.stny.rr.com> <20100519155732.GB2039@Krystal> <20100519162729.GE2516@laptop> <20100519191439.GA2845@Krystal> <alpine.LFD.2.00.1005191220370.23538@i5.linux-foundation.org> <20100519214905.GA22486@Krystal>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Nick Piggin <npiggin@suse.de>, Steven Rostedt <rostedt@goodmis.org>, Miklos Szeredi <miklos@szeredi.hu>, peterz@infradead.org, fweisbec@gmail.com, tardyp@gmail.com, mingo@elte.hu, acme@redhat.com, tzanussi@gmail.com, paulus@samba.org, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, tj@kernel.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>



On Wed, 19 May 2010, Mathieu Desnoyers wrote:
> 
> A faced a small counter-intuitive fadvise behavior though.
> 
>   posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED);
> 
> only seems to affect the parts of a file that already exist.

POSIX_FADV_DONTNEED does not have _any_ long-term behavior. So when you do 
a 

	posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED);

it only affects the pages that are there right now, it has no effect on 
any future actions.

> So after each splice() that appends to the file, I have to call fadvise 
> again. I would have expected the "0" len parameter to tell the kernel to 
> apply the hint to the whole file, even parts that will be added in the 
> future.

It's not a hint about future at all. It's a "throw current pages away".

I would also suggest against doing that kind of thing in a streaming write 
situation. The behavior for dirty page writeback is _not_ welldefined, and 
if you do POSIX_FADV_DONTNEED, I would suggest you do it as part of that 
writeback logic, ie you do it only on ranges that you have just waited on.

IOW, in my example, you'd couple the

	sync_file_range(fd, (index-1)*BUFSIZE, BUFSIZE, SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER);

with a

	posix_fadvise(fd, (index-1)*BUFSIZE, BUFSIZE, POSIX_FADV_DONTNEED);

afterwards to throw out the pages that you just waited for.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
