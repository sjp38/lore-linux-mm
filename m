Received: from deliverator.sgi.com (deliverator.sgi.com [204.94.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA26736
	for <Linux-MM@kvack.org>; Wed, 19 May 1999 13:38:47 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905191737.KAA85790@google.engr.sgi.com>
Subject: Re: Assumed Failure rates in Various o.s's ?
Date: Wed, 19 May 1999 10:37:42 -0700 (PDT)
In-Reply-To: <199905191428.QAA1295681@beryllium.daimi.au.dk> from "Erik Corry" at May 19, 99 04:28:53 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Erik Corry <corry@daimi.au.dk>
Cc: ak-uu@muc.de, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> It's rather a pity noone has ported it to the 386 then.
> You raised the problem yourself in the post leading up
> to http://x35.deja.com/=dnc/[ST_rn=ps]/getdoc.xp?AN=467741389
> and as far as I know this was never resolved.

Unfortunately, I couldn't quite trace back to the roots of this
thread, so I am guessing at what the problem is by looking at the
replies to the original post. Maybe one of you guys can explain 
why my proposed fix down below will not work ...

> 
> Perhaps something could be done about this.  Like rechecking
> when a blocked thread wakes up again in the middle of a 
> copy_from_fs.
> 
> > appropiate implementations of the *_user functions/macros. Actually Linux
> > versions upto 2.0 used exactly such a "software MMU" scheme for user space
> > address from the kernel. A similar way has been done recently by some guy 
> > of SGI to support upto 3.8GB of physical memory. In his patch kernel and 
> > user space have separated page tables, this means that kernel has to check
> > page tables by hand when it access user space. It all works by just changing
> > some architecture specific files and macros in asm/uaccess.h - generic Linux 
> > code is not touched.
> 
> > See http://www.linux.sgi.com/intel/bigmem/

Remember, this patch has not been fully tested, and I have only tested 
it on i686 (that's where big memory is interesting anyways). It should
have the same bugs that Linux has, plus some more (which I am hoping
sharp reviewers like you will be able to point out)

> 
> Did this stuff work around the scenario in the link above?
> He doesn't mention a workaround, and because SMP is possible
> it seems like it would need some kind of locking to prevent
> mmaps/munmaps while a copy_to_fs is taking place.  I didn't
> look at the patch.
> 
> -- 
> Erik Corry erik@arbat.com     Ceterum censeo, Microsoftem esse delendam!
> 

I think my patch might actually help your situation, given that the
*software* is checking the pte bits and making decisions about writability,
rather than relying on broken *hardware* which ignores the pte writability
bit.

Now for a proposal: I don't see a down(mm->mmap_sem) being done
in the code path leading up to calls to __verify_write. Am I missing
it? If a down(mm->mmap_sem) were added around __verify_write, you could
quit worrying about simultaneous munmaps while an user access function 
was executing. 

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
