From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199908070745.AAA97113@google.engr.sgi.com>
Subject: Re: mmap doesn't "wrap?"
Date: Sat, 7 Aug 1999 00:45:37 -0700 (PDT)
In-Reply-To: <199908070311.XAA03580@skydive.ai.mit.edu> from "grg22@ai.mit.edu" at Aug 6, 99 11:11:58 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: grg22@ai.mit.edu
Cc: Linux-MM@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

> 
> It looks to me as though mmap will try to grab a region of memory whose
> address is greater than or equal to the suggested start address passed in
> the call.  I suppose it does this because it traverses the free list in
> ascending address order.  If it can't find enough memory above the
> requested address, then the mmap fails, claiming ENOMEM; and it does this
> even when you've got gigs of wide open address space below the suggested
> address.
> 
> One effect of this is that if you specify an address of 0 (saying "I don't
> care"), the mmap seems to start above 0x40000000 by default, and forever
> ignores the gigabyte of address space below that.  This seems undesirable,
> especially when your chunk of memory requested would fit below 0x4000000
> but can't fit above it (due to memory fragmentation, or because you've
> already used up the rest of it!).
> 
> I don't know if the right thing would be to change the behavior of
> get_unmapped_area() to "wrap" from the beginning of the free list when it
> can't find anything above the given address, or just add a failure clause
> into do_mmap() to try again starting from 0 (or something else?).  
> 
> 
> (Yes, I've patched my rlimits so I can access 3GB virtual and yes, I 
> commit the sin of addressing the 32-bit community only on this more 
> general mailing list: apologies to you lucky 64-bit folks.)
> 
> thx,
> grg
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/
> 


Look at my patch for get_unmapped_area() at

	http://reality.sgi.com/kanoj_engr/garea.html

This has been submitted to Linus previously, unfortunately, it has not
been accepted. The current get_unmapped_area() is not POSIX compliant 
according to my thinking.

Regarding TASK_UNMAPPED_BASE, you can browse

	http://reality.sgi.com/kanoj_engr/tuning.html

which has some pointers on how to use the 3Gb user space judiciously. 
Basically, you can tune TASK_UNMAPPED_BASE to 0x10000000, if your apps
are "well-behaved".

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
