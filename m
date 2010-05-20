Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C52FF60032A
	for <linux-mm@kvack.org>; Thu, 20 May 2010 13:52:45 -0400 (EDT)
Date: Thu, 20 May 2010 10:49:46 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH] fuse: support splice() reading from fuse device
In-Reply-To: <E1OF3kc-00084X-Hi@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.2.00.1005201043321.23538@i5.linux-foundation.org>
References: <E1OF3kc-00084X-Hi@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jens.axboe@oracle.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>



On Thu, 20 May 2010, Miklos Szeredi wrote:
> 
> With Jens' pipe growing patch and additional fuse patches it was
> possible to achieve a 20GBytes/s write throghput on my laptop in a
> "null" filesystem (no page cache, data goes to /dev/null).

Btw, I don't think that is a very interesting benchmark.

The reason I say that is that many man years ago I played with doing 
zero-copy pipe read/write system calls (no splice, just automatic "follow 
the page tables, mark things read-only etc" things). It was considered 
sexy to do things like that during the mid-90's - there were all the crazy 
ukernel people with Mach etc doing magic things with moving pages around.

It got me a couple of gigabytes per second back then (when memcpy() speeds 
were in the tens of megabytes) on benchmarks like lmbench that just wrote 
the same buffer over and over again without ever touching the data.

It was totally worthless on _any_ real load. In fact, it made things 
worse. I never found a single case where it helped.

So please don't ever benchmark things that don't make sense, and then use 
the numbers as any kind of reason to do anything. It's worse than 
worthless. It actually adds negative value to show "look ma, no hands" for 
things that nobody does. It makes people think it's a good idea, and 
optimizes the wrong thing entirely.

Are there actual real loads that get improved? I don't care if it means 
that the improvement goes from three orders of magnitude to just a couple 
of percent. The "couple of percent on actual loads" is a lot more 
important than "many orders of magnitude on a made-up benchmark".

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
