Date: Fri, 2 Aug 2002 18:26:29 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: large page patch (fwd) (fwd)
In-Reply-To: <3D4B2535.2B1F5BF8@zip.com.au>
Message-ID: <Pine.LNX.4.44.0208021757490.2210-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Hubertus Franke <frankeh@watson.ibm.com>, wli@holomorpy.comgh@us.ibm.com, swj@cse.unsw.edu.au, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 2 Aug 2002, Andrew Morton wrote:
>
> Remind me again what's wrong with wrapping the Intel syscalls
> inside malloc() and then maybe grafting a little hook into the shm code?

Indeed.

However, don't think "Intel syscalls", think instead "bring out the
architecture-defined mapping features". In particular, the main objection
I had to Ingo's patch (which, by the sound of it is fairly similar to the
IBM patches which I haven't seen) was that it was much too Intel-centric.

I admit to being x86-centric when it comes to implementation (simply due
to the fact that they are cheap and everywhere), but I try very hard to
avoid making _design_ revolve around x86. In particular, while I'm not a
big fan of the PPC hash tables (understatement of the year), I _do_ like
the BAT mapping that PPC has.

(Alternatively, if you aren't familiar with BAT registers, think
software-filled extra TLB entries that are outside the normal fill policy
and have large sizes. For some architectures it makes sense to do this at
sw TLB fill time, for others that isn't very practical because the page
table lookup is fixed in various ways.)

This is sometimes also referred to as "superpages".

And I think people will find the "separate path" approach more palatable
if you think of it as an interface to BAT registers (with the "normal" VM
path being the interface to the regular page tables). And keeping very
much in mind that on some CPU's these two things really _are_ totally
separate (PPC being the best example).

The fact that on x86, which doesn't have a BAT array, we use the
PMD-spanning "large pages" instead, should be seen as the anomaly, not as
the design case.

This also hopefully explains why I consider anything that touches or cares
about page tables in generic VM code wrt the largepage support to be
fundamentally broken. If the largepage patch messes around with page
tables, it cannot be generic.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
