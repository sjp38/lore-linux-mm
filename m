Date: Sun, 07 Jul 2002 09:13:28 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <1084287443.1026033208@[10.10.2.3]>
In-Reply-To: <3D28042E.B93A318C@zip.com.au>
References: <3D28042E.B93A318C@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> You mean just tune up the existing code, basically.
> 
> There's certainly plenty of opportunity to do that.
> 
> Probably the biggest offenders are generic_file_read/write.  In
> generic_file_write() we're already faulting in the user page(s)
> beforehand (somewhat racily, btw).  We could formalise that into
> a pin_user_page_range() or whatever and use an atomic kmap
> in there.

That was basically what Andrea and I were discussing at OLS - his
concern (IIRC) was that the pinning operation would slow things
down (exactly the concern you mention later on).

> Martin, what sort of workload were you seeing the problems with?

I think I was just playing with kernel compile again, but I can
get our performance group to gather some real numbers for a variety
of benchmarks. With kernel compile there were only two large-scale
callers, but I don't remember what they were off the top of my head.
I'll give you some initial figures tommorow.

> I'm just not too sure about the pin_user_page() thing.  How
> expensive is a page table walk in there likely to be?

It looks like the code does try to recover from a page fault right
now ... but it just falls over and says the write failed. Is there
some way we could just make it abort the copy to user, and restart
the copy sequence in the (unlikely) case of a page fault?

If we're going to play around with that sort of thing (or indeed
do what the current code does), should this all be wrapped in a
"copy_to/from_high_user" function or something similar? Cleaner,
easier to change later, and less places for people to screw up.

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
