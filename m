From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200007241610.JAA33950@google.engr.sgi.com>
Subject: Re: flush_icache_range
Date: Mon, 24 Jul 2000 09:10:30 -0700 (PDT)
In-Reply-To: <20000723203609.A903@bacchus.dhis.org> from "Ralf Baechle" at Jul 23, 2000 08:36:09 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ralf Baechle <ralf@oss.sgi.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

> 
> On Sat, Jul 22, 2000 at 06:07:08PM -0700, Kanoj Sarcar wrote:
> 
> > Can anyone point out the logic of continued existance of flush_icache_range
> > after the introduction of flush_icache_page()? I admit that 
> > flush_icache_range is still needed in the module loading code, but do we
> > need it anymore in the a.out loading code? That code should be incurring
> > page faults, which will do the flush_icache_page anyway. Seems like
> > double work to me to do flush_icache_range again after the loading has
> > been done.
> 
> binfmt_elf.c:load_aout_interp() uses file->f_op->read to read the interpreter
> from disk, so actually need to use something else to flush the cache.
> Similar for two of three cases in binfmt_aout.c.  For these the page
> fault won't sufficiently flush cashes.

Okay, got it. flush_icache_page() can flush the icache, then 
flush_icache_range() can writeback-invalidate the dcache (for the a.out
section loading code), and things should work. AFAICS, this would be
the most optimal way to do things (ie, you don't have to writeback-invalidate
dcache, and invalidate icache in flush_icache_range(), you can optimize
out the icache flush relying on flush_icache_page to do the work).

> 
> > This argument to delete the flush_icache_range calls from the a.out
> > loading code assumes that the f_op->read() code behaves sanely, ie does
> > not do unexpected things like touch the user address (thus allocating
> > the page, and doing the icache flush via the page fault handler much
> > earlier) before it starts reading the a.out sections in ...
> 
> There is another MIPS specific problem with this routine.  Originally
> introduced for kernel modules the various incarnations of flush_icache_range
> are not protected against access from userspace.  Unable to handle kernel
> paging request ahead ...

Could you elaborate? Use mips as an example. Note: for the a.out code,
there will be one thread, and for the module loading, userspace access 
to the vmalloced area is not possible.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
