Received: from Cantor.suse.de (Cantor.suse.de [194.112.123.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA28842
	for <linux-mm@kvack.org>; Fri, 20 Nov 1998 07:11:18 -0500
Message-ID: <19981120130948.20965@boole.suse.de>
Date: Fri, 20 Nov 1998 13:09:48 +0100
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: Linux-2.1.129..
References: <19981119223434.00625@boole.suse.de> <Pine.LNX.3.96.981119225103.18633A-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.96.981119225103.18633A-100000@mirkwood.dummy.home>; from Rik van Riel on Thu, Nov 19, 1998 at 10:58:30PM +0100
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linus Torvalds <torvalds@transmeta.com>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 19, 1998 at 10:58:30PM +0100, Rik van Riel wrote:
> On Thu, 19 Nov 1998, Dr. Werner Fink wrote:
> 
> > Yes on a 512MB system it's a great win ... on a 64 system I see
> > something like a ``swapping weasel'' under high load.
> > 
> > It seems that page ageing or something *similar* would be nice
> > for a factor 512/64 >= 2  ... under high load and not enough
> > memory it's maybe better if we could get the processes in turn
> > into work instead of useless swapping (this was a side effect
> > of page ageing due to the implicit slow down).
> 
> It was certainly a huge win when page aging was implemented,
> but we mainly felt that because there used to be an obscure
> bug in vmscan.c, causing the kernel to always start scanning
> at the start of the process' address space.
> 
> Now that bug is fixed, it might just be better to switch
> to a multi-queue system. A full implementation of that
> will have to wait until 2.3, but we can easily do an
> el-cheapo simulation of it by simply not freeing swap
> cached pages on the first pass of shrink_mmap().

Hmmm ... we need something real for 2.2 ... so,
let's analyse the problem

     If the average time slice of the processes is eaten up by
     swapping page back *and* if these pages are spapped out
     during to the next time slice the system becomes unusable
     (freeing swap cached pages on the first pass of shrink_mmap()
      does force this behaviour at high stress).

Therefore we need something like a page ageing which does not
mean that the old scheme is required.

     Pages which are swapped in need a higher life time in
     physical memory.  If a page can be shared this life
     time could be a bigger one.
     If a process counts such pages up to a limit his pages
     should not get a higher life for the next few cycles.

This simple scheme should be implementable in a easy way,
shouldn't it?  The appropiate places are

      ipc/shm.c::shm_swap_in()
      mm/page_alloc.c::swap_in()

and the old place of the old age_page():

      mm/vmscan.c::try_to_swap_out()

together with some unused variables out of

      include/linux/sched.h::task_struct (e.g. dec_flt)
      include/linux/sched.h::struct page (e.g. unused :-)

nothing more is needed due to the better swap cache of
2.1.129 in comparision to 2.0.36.


          Werner

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
