Date: Mon, 16 Aug 1999 23:29:48 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <Pine.LNX.4.10.9908162358590.9951-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9908162324001.1048-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 17 Aug 1999, Andrea Arcangeli wrote:
>
> This incremental (against bigmem-2.3.13-L) patch will fix the ptrace and
> /proc/*/mem read/writes to other process VM inside the kernel.

Andrea, you really need to clean these things up.

The bigmem patches look fine _except_ for the fact that they have these 

	#ifdef CONFIG_BIGMEM

turds all over the place. That's NOT how to do it.

Instead, you should unconditionally always do

	#include <linux/bigmem.h>

which in turn does something like this:

	#ifdef CONFIG_BIGMEM

	  #include <asm/bigmem.h>

	#else

	  #define kmap(page)	page_address(page)
	  #define kunmap(page)	do { } while (0)

	#endif

and then there is not a _single_ #ifdef inside any actual code.

Remember: if you have to have #ifdef's in actual functional code, you're
doing something wrong. I don't see why you can't just abstract the thing
away with zero performance degradation for the non-bigmem case by just
making the mapping function the existing identity function.

I'd like you to do the above cleanup, and then the bigmem patches look
like they could easily be integrated into the current 2.3.x series. But
with #ifdef's it won't.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
