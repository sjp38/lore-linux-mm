Date: Sun, 7 Jul 2002 11:31:39 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
In-Reply-To: <3D28042E.B93A318C@zip.com.au>
Message-ID: <Pine.LNX.4.44.0207071128170.3271-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "Martin J. Bligh" <fletch@aracnet.com>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Sun, 7 Jul 2002, Andrew Morton wrote:
>
> Probably the biggest offenders are generic_file_read/write.  In
> generic_file_write() we're already faulting in the user page(s)
> beforehand (somewhat racily, btw).  We could formalise that into
> a pin_user_page_range() or whatever and use an atomic kmap
> in there.

I'd really prefer not to. We're talking of a difference between one
single-cycle instruction (the address should be in the TLB 99% of all
times), and a long slow TLB walk with various locks etc.

Anyway, it couldn't be an atomic kmap in file_send_actor anyway, since the
write itself may need to block for other reasons (ie socket buffer full
etc). THAT is the one that can get misused - the others are not a big
deal, I think.

So kmap_atomic definitely doesn't work there.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
