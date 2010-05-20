Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 851C26008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 21:56:09 -0400 (EDT)
Date: Wed, 19 May 2010 21:56:05 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: Unexpected splice "always copy" behavior observed
Message-ID: <20100520015605.GA28411@Krystal>
References: <1274280968.26328.774.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org> <E1OElGh-0005wc-I8@pomaz-ex.szeredi.hu> <1274283942.26328.783.camel@gandalf.stny.rr.com> <20100519155732.GB2039@Krystal> <20100519162729.GE2516@laptop> <20100519191439.GA2845@Krystal> <alpine.LFD.2.00.1005191220370.23538@i5.linux-foundation.org> <20100519214905.GA22486@Krystal> <alpine.LFD.2.00.1005191659100.23538@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005191659100.23538@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Steven Rostedt <rostedt@goodmis.org>, Miklos Szeredi <miklos@szeredi.hu>, peterz@infradead.org, fweisbec@gmail.com, tardyp@gmail.com, mingo@elte.hu, acme@redhat.com, tzanussi@gmail.com, paulus@samba.org, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, tj@kernel.org, jens.axboe@oracle.com, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Linus Torvalds (torvalds@linux-foundation.org) wrote:
> 
> 
> On Wed, 19 May 2010, Mathieu Desnoyers wrote:
> > 
> > A faced a small counter-intuitive fadvise behavior though.
> > 
> >   posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED);
> > 
> > only seems to affect the parts of a file that already exist.
> 
> POSIX_FADV_DONTNEED does not have _any_ long-term behavior. So when you do 
> a 
> 
> 	posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED);
> 
> it only affects the pages that are there right now, it has no effect on 
> any future actions.

Hrm, someone should tell the author of posix_fadvise(2) about the benefit of
some clarifications (I'm CCing the manpage maintainer)

Quoting man posix_fadvise, annotated:


       Programs  can  use  posix_fadvise()  to announce an intention to access
       file data in a specific pattern in the future, thus allowing the kernel
       to perform appropriate optimizations.

This only talks about future accesses, not past. From what I understand, you are
saying that in the writeback case it's better to think of posix_fadvise() as
applying to pages that have been written in the past too.


       The  advice  applies to a (not necessarily existent) region starting at
       offset and extending for len bytes (or until the end of the file if len
       is 0) within the file referred to by fd.  The advice is not binding; it
       merely constitutes an expectation on behalf of the application.
 
This could be enhanced by saying that it applies up to the current file size if
0 is specified, and does not extend as the file grows. The formulation as it is
currently stated is a bit misleading.

> > So after each splice() that appends to the file, I have to call fadvise 
> > again. I would have expected the "0" len parameter to tell the kernel to 
> > apply the hint to the whole file, even parts that will be added in the 
> > future.
> 
> It's not a hint about future at all. It's a "throw current pages away".
> 
> I would also suggest against doing that kind of thing in a streaming write 
> situation. The behavior for dirty page writeback is _not_ welldefined, and 
> if you do POSIX_FADV_DONTNEED, I would suggest you do it as part of that 
> writeback logic, ie you do it only on ranges that you have just waited on.
> 
> IOW, in my example, you'd couple the
> 
> 	sync_file_range(fd, (index-1)*BUFSIZE, BUFSIZE, SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER);
> 
> with a
> 
> 	posix_fadvise(fd, (index-1)*BUFSIZE, BUFSIZE, POSIX_FADV_DONTNEED);
> 
> afterwards to throw out the pages that you just waited for.

OK, so it's better to do the writeback as part of sync_file_range rather than
relying on the dirty page writeback to do it for us. I guess the I/O scheduler
will have more room to ensure that writes are contiguous.

Thanks for the feedback,

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
