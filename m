Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA946008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 15:34:36 -0400 (EDT)
Date: Wed, 19 May 2010 12:31:25 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Unexpected splice "always copy" behavior observed
In-Reply-To: <20100519191439.GA2845@Krystal>
Message-ID: <alpine.LFD.2.00.1005191220370.23538@i5.linux-foundation.org>
References: <1274199039.26328.758.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org> <20100519063116.GR2516@laptop> <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org> <1274280968.26328.774.camel@gandalf.stny.rr.com>
 <alpine.LFD.2.00.1005190758070.23538@i5.linux-foundation.org> <E1OElGh-0005wc-I8@pomaz-ex.szeredi.hu> <1274283942.26328.783.camel@gandalf.stny.rr.com> <20100519155732.GB2039@Krystal> <20100519162729.GE2516@laptop> <20100519191439.GA2845@Krystal>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Nick Piggin <npiggin@suse.de>, Steven Rostedt <rostedt@goodmis.org>, Miklos Szeredi <miklos@szeredi.hu>, peterz@infradead.org, fweisbec@gmail.com, tardyp@gmail.com, mingo@elte.hu, acme@redhat.com, tzanussi@gmail.com, paulus@samba.org, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, tj@kernel.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>



On Wed, 19 May 2010, Mathieu Desnoyers wrote:
> 
> Good point. This discard flag might do the trick and let us keep things simple.
> The major concern here is to keep the page cache disturbance relatively low.
> Which of new page allocation or stealing back the page has the lowest overhead
> would have to be determined with benchmarks.

We could probably make it easier somehow to do the writeback and discard 
thing, but I have had _very_ good experiences with even a rather trivial 
file writer that basically used (iirc) 8MB windows, and the logic was very 
trivial:

 - before writing a new 8M window, do "start writeback" 
   (SYNC_FILE_RANGE_WRITE) on the previous window, and do 
   a wait (SYNC_FILE_RANGE_WAIT_AFTER) on the window before that.

in fact, in its simplest form, you can do it like this (this is from my 
"overwrite disk images" program that I use on old disks):

	for (index = 0; index < max_index ;index++) {
		if (write(fd, buffer, BUFSIZE) != BUFSIZE)
			break;
		/* This won't block, but will start writeout asynchronously */
		sync_file_range(fd, index*BUFSIZE, BUFSIZE, SYNC_FILE_RANGE_WRITE);
		/* This does a blocking write-and-wait on any old ranges */
		if (index)
			sync_file_range(fd, (index-1)*BUFSIZE, BUFSIZE, SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER);
	}

and even if you don't actually do a discard (maybe we should add a 
SYNC_FILE_RANGE_DISCARD bit, right now you'd need to do a separate 
fadvise(FADV_DONTNEED) to throw it out) the system behavior is pretty 
nice, because the heavy writer gets good IO performance _and_ leaves only 
easy-to-free pages around after itself.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
