From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199908170650.XAA95856@google.engr.sgi.com>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
Date: Mon, 16 Aug 1999 23:50:42 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9908162339360.1048-100000@penguin.transmeta.com> from "Linus Torvalds" at Aug 16, 99 11:41:50 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: andrea@suse.de, alan@lxorguk.ukuu.org.uk, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> 
> On Mon, 16 Aug 1999, Kanoj Sarcar wrote:
> > 
> > As I pointed out before, I don't think rawio is the only case which
> > breaks.
> > 
> > I will give you one example of the type of cases that I am talking about.
> > In drivers/char/bttv.c, VIDIOCSFBUF ioctl seems to be setting the "vidadr"
> > to a kernel virtual address from the physical address present in the 
> > user's pte. This will not work for bigmem pages.
> 
> This is exactly why I have always been adamant that people should NOT do
> direct IO and try to walk the page tables. But people have ignored me, and
> quite frankly, those drivers should just be broken. The painful part is
> finding out which of them do it, but once done they should just be broken
> wrt bigmem, no questions asked.
> 
> 		Linus
> 

The *only* way to prevent this really is to make code like this uncompilable.
That is, prevent definitions like pte_page, PAGE_OFFSET, __va, __pa etc
from being in header files; rather make the driver/fs code invoke specific
routines that do virt-to-phys etc translations. Granted, this might be a
little costlier, but in most cases, this extra cost will be in driver code
that is not performance sensistive anyway. There really should be some
ddi/dki that drivers have to follow. 

Btw, my vote goes for finding and fixing all such driver code, instead 
of just breaking them for bigmem machines.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
