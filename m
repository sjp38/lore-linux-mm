Received: from deliverator.sgi.com (deliverator.sgi.com [204.94.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA27799
	for <Linux-MM@kvack.org>; Mon, 17 May 1999 02:16:53 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905170616.XAA97025@google.engr.sgi.com>
Subject: Re: [PATCH] kanoj-mm2.0-2.2.9 unneccesary page force in by munlock
Date: Sun, 16 May 1999 23:16:26 -0700 (PDT)
In-Reply-To: <Pine.LNX.3.95.990516214528.4550B-100000@penguin.transmeta.com> from "Linus Torvalds" at May 16, 99 09:48:03 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> On Sun, 16 May 1999, Kanoj Sarcar wrote:
> >
> > While looking at the code for munlock() in mm/mlock.c, I found
> > that munlock() unneccesarily executes a code path that forces
> > page fault in over the entire range. The following patch fixes 
> > this problem:
> 
> Well, it shouldn't force a page-fault, as the code is only executed if the
> lockedness changes - and if it is a unlock then it will have been locked
> before, so all the pages will have been present, and as such we wouldn't
> actually need to fault them in.

Hmm, my logic was a little bit different. Note that you can call munlock()
on a range even when a previous mlock() has not been done on the range (I
think that's not an munlock error in POSIX). In 2.2.9, this would end up
faulting in the pages, which doesn't need to happen ... (haven't really
thought whether "root" can erroneously force memory deadlocks this way)

> 
> I agree that it is certainly unnecessary, though, and pollutes TLB's etc
> for no good reason.
> 
> How about this diff instead, avoiding the if-then-else setup?
> 
> 		Linus
> 
> -----
> --- v2.3.2/linux/mm/mlock.c	Fri Nov 20 11:43:19 1998
> +++ linux/mm/mlock.c	Sun May 16 21:45:23 1999
> @@ -115,10 +115,11 @@
>  	if (!retval) {
>  		/* keep track of amount of locked VM */
>  		pages = (end - start) >> PAGE_SHIFT;
> -		if (!(newflags & VM_LOCKED))
> +		if (newflags & VM_LOCKED) {
>  			pages = -pages;
> -		vma->vm_mm->locked_vm += pages;
> -		make_pages_present(start, end);
> +			make_pages_present(start, end);
> +		}
> +		vma->vm_mm->locked_vm -= pages;
>  	}
>  	return retval;
>  }
> 

I can't see any difference with my proposed fix, so if you are happy
with this one, I am too :-)  Note that in both our solutions, an "if"
check is happening, I am not sure if you are trying to remove the 
"else" code to reduce icache pollution. Also note that mlocks far 
outnumber munlocks (since apps depend on the final exit to release
all the locked memory), which in your solution translates to more
negate operations (pages = -pages).

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
