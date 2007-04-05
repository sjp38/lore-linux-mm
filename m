Date: Wed, 4 Apr 2007 17:27:31 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] no ZERO_PAGE?
In-Reply-To: <6701.1175724355@turing-police.cc.vt.edu>
Message-ID: <Pine.LNX.4.64.0704041724280.6730@woody.linux-foundation.org>
References: <20070329075805.GA6852@wotan.suse.de>
 <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
 <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de>
            <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
 <6701.1175724355@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Andrea Arcangeli <andrea@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Wed, 4 Apr 2007, Valdis.Kletnieks@vt.edu wrote:
> 
> I'd not be surprised if there's sparse-matrix code out there that wants to
> malloc a *huge* array (like a 1025x1025 array of numbers) that then only
> actually *writes* to several hundred locations, and relies on the fact that
> all the untouched pages read back all-zeros.

Good point. In fact, it doesn't need to be a malloc() - I remember people 
doing this with Fortran programs and just having an absolutely incredibly 
big BSS (with traditional Fortran, dymic memory allocations are just not 
done).

> Of course, said code is probably buggy because it doesn't zero the whole 
> thing because you don't usually know if some other function already 
> scribbled on that heap page.

Sure you do. If glibc used mmap() or brk(), it *knows* the new data is 
zero. So if you use calloc(), for example, it's entirely possible that 
a good libc wouldn't waste time zeroing it.

The same is true of BSS. You never clear the BSS with a memset, you just 
know it starts out zeroed.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
