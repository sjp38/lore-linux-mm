Date: Fri, 6 Aug 1999 22:00:00 -0400
Message-Id: <199908070200.WAA03531@skydive.ai.mit.edu>
Subject: Re: getrusage
From: grg22@ai.mit.edu
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org, dca@torrent.com, grg22@ai.mit.edu
List-ID: <linux-mm.kvack.org>

On Tue, Aug 03, 1999 at 04:02:53PM +0200, dca@torrent.com wrote:
> 
> Here are the relevant entries from struct rusage:
> 
>   long ru_maxrss;     /* maximum resident set size */
>   long ru_ixrss;      /* integral shared memory size */
>   long ru_idrss;      /* integral unshared data size */
>   long ru_isrss;      /* integral unshared stack size */

If you do fix this, could you please make all these entries *unsigned*
longs?  We need to convert over to using the full 32 bits to allow for full
usage of the memory.  I believe negative values are disallowed for any of
these resource limits and usages, so this particular change shouldn't break
anything anywhere.

Currently linux tries to allow 3GB of virtual, but we're stuck at 2GB
because the resource limits are signed longs rather than unsigned.
There are several patches submitted to fix this.  Basically all the
longs in include/linux/resource.h should be unsigned; IMHO the definition
of INFINITY there should be ~0UL (the current definition, ~0UL>>1, is what
enforces the limit of max 2GB), but I think some differ in opinion here.

We should also get the libc people to correct the get/setrlimit and
getrusage library calls to support unsigned longs.  (What's the mailing
list for glibc?  I can't seem to locate one specifically for it.)

thanks,
grg.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
