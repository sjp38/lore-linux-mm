From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200006212141.OAA54650@google.engr.sgi.com>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Date: Wed, 21 Jun 2000 14:41:16 -0700 (PDT)
In-Reply-To: <20000621213507Z131177-21003+34@kanga.kvack.org> from "Timur Tabi" at Jun 21, 2000 04:28:43 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> ** Reply to message from Kanoj Sarcar <kanoj@google.engr.sgi.com> on Wed, 21
> Jun 2000 14:10:17 -0700 (PDT)
> 
> 
> > Okay, I will shut up since I will have to pull out old notes and books
> > to convince you, but basically, here's a simple example. Say a L2 cache 
> > line is 128 bytes, and each array element is 16 bytes, giving 8 array 
> > elements per cache line. Say you decide to eliminate the last element,
> > maybe because it is not used. So, in that space, two global integers/
> > spinlocks etc are packed in after the deletion. Further assume these
> > two integers are frequently updated. Looking at an SMP system that uses
> > the exlusive write cache update protocol, the cache line will probably
> > bounce between the different L2 caches, which is quite bad, assuming 
> > that the original 8 element array was readonly, and was probably 
> > coresident in all the caches.
> 
> Fascinating.  I really appreciate your taking the time to explain this to me.  
> 
> So I suppose the best way to optimize this is to make sure that "NR_GFPINDEX *
> sizeof(zonelist_t)" is a multiple of the cache line size?
>

Which is hard to do with all the various architectures with varying
cache line sizes out there. The asm header files can conveniently use
__attribute__((aligned(128))) etc, but I think the generic header files
use something like __attribute__((__aligned__(SMP_CACHE_BYTES))).
Note that SMP_CACHE_BYTES is equated to the >> L1 << cache size for
most architectures, which probably has a different effect than 
aligning on L2 cache lines.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
