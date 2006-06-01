From: Andi Kleen <ak@suse.de>
Subject: Re: ECC error correction - page isolation
Date: Fri, 2 Jun 2006 01:46:33 +0200
References: <069061BE1B26524C85EC01E0F5CC3CC30163E1F1@rigel.headquarters.spacedev.com>
In-Reply-To: <069061BE1B26524C85EC01E0F5CC3CC30163E1F1@rigel.headquarters.spacedev.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606020146.33703.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brian Lindahl <Brian.Lindahl@spacedev.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 01 June 2006 20:06, Brian Lindahl wrote:
> We have a board that gives us access to ECC error counts and ECC error
> status (4 bits, each corresponding to a different error). A background
> process performs a scrub (read, rewrite) on individual raw memory pages to
> activate the ECC. When the error count changes (an error is detected), I'd
> like to be able to isolate the page, if unused. The pages are scrubbed as
> raw physical addresses (page numbers) via a ioctl command on /dev/mem. Is
> there a facility that will allow me to map this physical address range to a
> page entity in the kernel so that I can isolate it and mark it as unusable,
> or reboot if it's active? Is there a better way to do this (i.e. avoiding
> the mapping phase and interact directly with physical page entities in the
> kernel)? Where should I begin my journey into mm in the kernel? What
> structures, functions and globals should I be looking at?
>
> Going this deep in the kernel is pretty foreign to me, so any help would be
> appreciated. Thanks in advance!

I did a prototype for something like this years ago. It is relatively 
complicated. 

If you get machine checks in normal accesses you have to bootstrap
yourself. This means it has to be handed off to a thread to be able
to take locks safely. For a scrubber that can be ignored. Doing 
it from arbitary context requires some tricks.

Then you have to take a look at the struct page associated with
the address. If it's a rmap page (you'll need a 2.6 kernel) you
can walk the rmap chains to find the processes that have 
the page mapped. You can look at the PTEs and 
the page bits to see if it's dirty or not. For clean pages
the page can be just dropped. Otherwise you have
to kill the process (or send them a signal they could handle) 

There is no generic function to do the rmap walk right now, but it's not too 
hard. 

If it's kernel space there are several cases:
- Free page (count == 0). Easy: ignore it.
- Reserved - e.g. page itself or kernel code - panic
- Slab (slab bit set) - panic
- Page table (cannot be detected right now, but you could
change your architecture to set special bits) - handle like 
process error
- buffer cache: toss or IO/error if it was dirty 
- Probably more cases

Most can be figured out by looking at the various bits in struct page

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
