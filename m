Date: Tue, 9 Nov 1999 11:26:28 +0200
From: "Arkadi E. Shishlov" <arkadi@it.lv>
Subject: Re: IO mappings; verify_area() on SMP
Message-ID: <19991109112628.A559@it.lv>
References: <19991108134325.A589@it.lv> <199911081925.LAA28960@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199911081925.LAA28960@google.engr.sgi.com>; from Kanoj Sarcar on Mon, Nov 08, 1999 at 11:25:11AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  Thank you for fast response. Now I know, how to deal with memory io.

On Mon, Nov 08, 1999 at 11:25:11AM -0800, Kanoj Sarcar wrote:
> > 
> >   Second question is about verify_area() safety. Many drivers contain
> >   following sequence:
> > 
> >   if ((ret = verify_area(VERIFY_WRITE, buffer, count)))
> > 	    return r;
> >   ...
> >   copy_to_user(buffer, driver_data_buf, count);
> > 
> >   Even protected by cli()/sti() pairs, why multithreaded program on
> >   SMP machine can't unmap this verified buffer between calls to
> >   verify_area() and copy_to_user()? Of course it can't be true, but
> >   maybe somebody can write two-three words about reason that prevent
> >   this situation.
> 
> In most cases, the address spaces' mmap_sem is held, which prevents
> unmap's from happening until the caller of verify_area/copy_to_user
> releases it. This is if copy_to_user takes a page fault. If there
> is no page fault, the caller probably holds the kernel_lock 
> monitor, which excludes anyone else from doing a lot of things 
> inside the kernel, including unmaps.

  Hmm... Your explanation is somewhat different from Andi Kleen wrote.
  I don't see use of mmap_sem in conjunction with drivers (only char/mem).
  If I mistaken - sorry, I will dig into kernel and investigate this.


arkadi.
-- 
Just arms curvature radius.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
