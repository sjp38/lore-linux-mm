Date: Tue, 21 Mar 2000 15:08:34 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000321150834.A5291@pcep-jamie.cern.ch>
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org> <20000321022053.A4271@pcep-jamie.cern.ch> <14550.56676.35208.422139@liveoak.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <14550.56676.35208.422139@liveoak.engr.sgi.com>; from William J. Earl on Mon, Mar 20, 2000 at 06:24:36PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "William J. Earl" <wje@cthulhu.engr.sgi.com>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William J. Earl wrote:
>      I have been asked by some application people to have free() use
> MADV_DONTNEED or the equivalent in selected cases, specifically when
> the memory allocated is large, in order to free up the physical and
> virtual (swap space) memory for other uses.  If the application uses
> very large chunks of memory, giving it back entirely is a win.  The
> application could be recoded to do its own mmap() of /dev/zero and
> munmap(), but would prefer that this behavior be automatic.  Of course,
> MADV_DONTNEED does not apply in the case of mmap()/munmap() of /dev/zero,
> but it is not implausible to give up virtual memory.  Note that
> I am not claiming one should do anything of the sort for small
> allocations.

Take a look at Glibc's malloc/free, which is the only one we care about
for Linux.  Glibc's malloc uses mmap() of /dev/zero for large
allocations automatically.  You can change the threshold if you like.

However, assuming this was not the case, even your application would
benefit more from MADV_FREE than MADV_DONTNEED.  MADV_DONTNEED forces a
non-trivial minimum recycling cost, whereas MADV_FREE allows the cost to
be balanced between the kernel and the application, according to the
current paging situation.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
