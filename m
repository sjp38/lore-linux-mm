Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: large page patch (fwd) (fwd) 
In-reply-to: Your message of Fri, 02 Aug 2002 18:26:29 PDT.
             <Pine.LNX.4.44.0208021757490.2210-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <11780.1028348797.1@us.ibm.com>
Date: Fri, 02 Aug 2002 21:26:37 -0700
Message-Id: <E17aqUv-000344-00@w-gerrit2>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrew Morton <akpm@zip.com.au>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Hubertus Franke <frankeh@watson.ibm.com>, wli@holomorpy.com, swj@cse.unsw.edu.au, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

In message <Pine.LNX.4.44.0208021757490.2210-100000@home.transmeta.com>, > : Li
nus Torvalds writes:
> 
> 
> On Fri, 2 Aug 2002, Andrew Morton wrote:
> >
> > Remind me again what's wrong with wrapping the Intel syscalls
> > inside malloc() and then maybe grafting a little hook into the shm code?
> 
> Indeed.
 
Do you really want all calls to malloc to allocate non-pageable
memory?  And I doubt that this memory will be pageable in time for
2.5.

> However, don't think "Intel syscalls", think instead "bring out the
> architecture-defined mapping features". In particular, the main objection
> I had to Ingo's patch (which, by the sound of it is fairly similar to the
> IBM patches which I haven't seen) was that it was much too Intel-centric.
 
The IBM patch (Simon Winwood's work) was first done for PPC64 and then
ported at my insistence to IA32 since we had an immediate need and
an opportunity to do some specific application porting work on IA32.
The patch was intended to be both architecture neutral and to support
multiple page sizes.  In the essense of hitting the Halloween deadline,
we believe that dropping back for the moment to IA32, pinned, mmap()/
madvise()/shm*() versions, possibly gated by a capability (or not, easily
debatable and I doubt that it matters too much) will get at least IBM
apps on IA32 through the lifetime on 2.6 and probably have the framework
in such that PPC64 can also easily fit in possibly pre-freeze, possibly
post-freeze with mostly arch-specific mods.

> I admit to being x86-centric when it comes to implementation (simply due
> to the fact that they are cheap and everywhere), but I try very hard to
> avoid making _design_ revolve around x86. In particular, while I'm not a
> big fan of the PPC hash tables (understatement of the year), I _do_ like
> the BAT mapping that PPC has.

We folks in the LTC have much the same interest.  In addition to the
obvious IA32/PPC32/PPC64/zSeries/IA64/AMD issues (keep in mind we probably
sell more servers with PPC than with IA32 ;-), we have software products
which run on nearly every platform and every distro in existence.  So,
we too try to qualify most of our work on its potential application to
multiple architectures.

> (Alternatively, if you aren't familiar with BAT registers, think
> software-filled extra TLB entries that are outside the normal fill policy
> and have large sizes. For some architectures it makes sense to do this at
> sw TLB fill time, for others that isn't very practical because the page
> table lookup is fixed in various ways.)
 
>From what I've heard from the Watson Research experts on PPC64, BAT
registers are actually a bad idea for this and AIX is slowly removing
its dependency on BAT registers.  I'd be interested in a read from
Anton or Paul Mackerras or even the Research folks involved in the
chip design.

And, we are doing everything possible to at least provide code to
demonstrate the solutions we are talking about.  It just may take
a few days to get it properly accelerated.  ;-)

gerrit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
