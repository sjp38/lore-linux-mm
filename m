Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A0A6290023D
	for <linux-mm@kvack.org>; Sat, 25 Jun 2011 05:55:34 -0400 (EDT)
Received: by yia13 with SMTP id 13so1784343yia.14
        for <linux-mm@kvack.org>; Sat, 25 Jun 2011 02:55:31 -0700 (PDT)
MIME-Version: 1.0
Reply-To: M.K.Edwards@gmail.com
In-Reply-To: <BANLkTinUCZrd-JuMc3TkaF4f1VBmOu9nxQ@mail.gmail.com>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
	<4E017539.30505@gmail.com>
	<001d01cc30a9$ebe5e460$c3b1ad20$%szyprowski@samsung.com>
	<4E01AD7B.3070806@gmail.com>
	<002701cc30be$ab296cc0$017c4640$%szyprowski@samsung.com>
	<4E02119F.4000901@codeaurora.org>
	<4E033AFF.4020603@gmail.com>
	<BANLkTikzTwNvaaUSk26qzONemogBAGuBRg@mail.gmail.com>
	<BANLkTimi2FAmcb7ZWnjRqb-Cb8acXWsCTw@mail.gmail.com>
	<BANLkTinUCZrd-JuMc3TkaF4f1VBmOu9nxQ@mail.gmail.com>
Date: Sat, 25 Jun 2011 02:55:28 -0700
Message-ID: <BANLkTi=y6PGMdHq0uT9QJ7aej3nU6cKW2g@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH/RFC 0/8] ARM: DMA-mapping framework redesign
From: "Michael K. Edwards" <m.k.edwards@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Morton <jonathan.morton@movial.com>
Cc: Subash Patel <subashrp@gmail.com>, Jordan Crouse <jcrouse@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arch@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Thanks, Jonathan!  I agree with you that it is fundamentally a
hardware design defect that on-chip devices like GPUs and video
capture/encode/decode/display blocks do not participate in the cache
coherency protocol, and thus the buffers passed to, from, and among
them all have to be mapped uncacheable.  Not, unfortunately, something
likely to change soon, with one or two possible exceptions that I've
heard rumors about ...

With regard to the use of NEON for data moves, I have appended a
snippet of a conversation from the BeagleBoard list that veered off
into a related direction.  (My response is lightly edited, since I
made some stupid errors in the original.)  While this is somewhat
off-topic from Marek's patch set, I think it's relevant to the
question of whether "user-allocated" buffers are an important design
consideration for his otherwise DMA-centric API.  (And more to the
point, buffers allocated suitably for one or more on-chip devices, and
also mapped as uncacheable to userland.)

Perhaps you could correct misapprehensions and fill in gaps?  And
comment on what's likely to be different on other ARMv7-A
implementations?  And then I'll confine myself to review of Marek's
patches, on this thread anyway.  ;-)



On Jun 24, 4:50 am, Siarhei Siamashka <siarhei.siamas...@gmail.com> wrote:
> 2011/6/24 M=E5ns Rullg=E5rd <m...@mansr.com>:
>
> > "Edwards, Michael" <m.k.edwa...@gmail.com> writes:
> >> and do have dedicated lanes to memory for the NEON unit
>
> > No core released to date, including the A15, has dedicated memory lanes
> > for NEON.  All the Cortex-A* cores have a common load/store unit for al=
l
> > types of instructions.  Some can do multiple concurrent accesses, but
> > that's orthogonal to this discussion.
>
> Probably he wanted to say that NEON unit from Cortex-A8 can load/store
> 128 bits of data per cycle when accessing L1 cache *memory*, while
> ordinary ARM load/store instructions can't handle more than 64 bits
> per cycle there. This makes sense in the context of this discussion
> because loading data to NEON/VFP registers directly without dragging
> it through ARM registers is not a bad idea.

That's close to what I meant.  The load/store path *to main memory* is
indeed shared.  But within the cache hierarchy, at least on the
Cortex-A8, ARM and NEON take separate paths.  And that's a good thing,
because the ARM stalls on an L1 miss, and it would be rather bad if it
had to wait for a big NEON transfer to complete before it could fill
from L2.  Moreover, the only way to get "streaming" performance
(back-to-back AXI burst transactions) on uncacheable regions is by
using the NEON.  That's almost impossible to determine from the TRM,
but it's there:
http://infocenter.arm.com/help/topic/com.arm.doc.ddi0344k/ch09s04s03.html
.  Compare against the LDM/STM section of
http://infocenter.arm.com/help/topic/com.arm.doc.ddi0344k/ch09s01s02.html
.

On the A8, the NEON bypasses the L1 cache, and has a dedicated lane
(probably the wrong word, sorry) into the L2 cache -- or for
uncacheable mappings, *past* the L2 per se to its AXI scheduler.  See
http://infocenter.arm.com/help/index.jsp?topic=3D/com.arm.doc.ddi0344k/ch08=
s02s02.html
.  In addition, NEON load/store operations can be issued in parallel
with integer code, and there can be as many as 12 NEON reads
outstanding in L2 -- vs. the maximum of 4 total cache line refills and
evictions.  So if you are moving data around without doing non-SIMD
operations on it, and without branching based on its contents, you can
do so without polluting L1 cache, or contending with L1 misses that
hit in L2.

There will be some contention between NEON-side loads and ARM-side L2
misses, but even that is negligible if you issue a preload early
enough (which you should do anyway for fetches that you suspect will
miss L2, because the compiler schedules loads based on the assumption
of an L1 hit; an L1 miss stalls the ARM side until it's satisfied).
Preloads do not have any effect if you miss in TLB, and they don't
force premature evictions from L1 cache (they only load as far as L2).
 And the contention on the write side is negligible thanks to the
write allocation mechanism, except insofar as you may approach
saturation of the AXI interface due to the total rate of L2
evictions/linefills and cache-bypassing traffic -- in which case,
congratulations!  Your code is well tuned and operates at the maximum
rate that the path to main memory permits.

If you are fetching data from an uncacheable region, using the NEON to
trampoline into a cacheable region should be a *huge* win.  Remember,
an L1 miss stalls the ARM side, and the only way to get data into L1
is to fetch and miss.  If you want it to hit in L2, you have to use
the NEON to put it there, by fetching up to 128 bytes at a go from the
uncacheable region (e. g., VLDM r1,{d16-d31}) and storing it to a
cacheable buffer (i. e., only as far as L2, since you write it again
and again without an eviction).  You want to limit fetches from the
ARM side to cacheable regions; otherwise every LDM is a round-trip to
AXI.

The store story is similar.  You want the equivalent of the x86's
magic "fill buffers" -- which avoid the read-modify-write penalty when
writing whole cache lines' worth of data through uncacheable
write-combining mappings, but only if you use cache-bypassing SSE2
writes.  To get it, you need to write from the ARM to cacheable
memory, then load that data to NEON registers and store from there.
That pushes up to two whole cache lines' worth of data at a time down
to the L2 controller, which queues the write without blocking the
NEON.  (This is the only way to get an AXI burst longer than 4 128-bit
transactions without using the preload engine.)

One more nice thing about doing your bulk data transfers this way,
instead of monkeying with some DMA unit (which you probably can't do
in userland anyway), is that there are no explicit cache operations to
deal with.  You don't have to worry about data stalling in L1, because
the NEON loads do peek data *from* L1 even though they don't load data
*to* L1.  (Not unless you turn on the L1NEON bit in the Auxiliary
Control Register, which you don't want to do unless you have no L2
cache, in which case you have a whole different set of problems.)

The Cortex-A9 is a whole different animal, with out-of-order issue on
the ARM side and two automatic prefetch mechanisms (based on detection
of miss patterns at L1 and, in MPCore only, at L2).  It also has a far
less detailed TRM, so I can't begin to analyze its memory hierarchy.
Given that the L2 cache has been hived off to an external unit, and
the penalty for transfers between the ARM and NEON units has been
greatly decreased, I would guess that the NEON goes through the L1
just like the ARM.  That changes the game a little -- the NEON
transfers to/from cacheable memory can now cause eviction of the ARM's
working set from L1 -- but in practice that's probably a wash.  The
basic premise (that you want to do your noncacheable transactions in
big bursts, feasible only from the NEON side) still holds.

> >> -- the compiler can tighten up the execution of rather a lot of code
> >> by trampolining structure fetches and stores through the NEON.
>
> > Do you have any numbers to back this up?  I don't see how going through
> > NEON registers would be faster than direct LDM/STM on any core.
>
> My understanding is that it's exactly the other way around. Using
> hardfp allows to avoid going through ARM registers for floating point
> data, which otherwise might be needed for the sole purpose of
> fulfilling ABI requirements in some cases. You are going a bit
> overboard trying to argue with absolutely everything what Edwards has
> posted :)

Not just for floating point data, but for SIMD integer data as well,
or really anything you want -- as long as you frame it as a
"Homogeneous Aggregate of containerized vectors".  That's an extra 64
bytes of structure that you can pass in, and let the callee decide
whether and when to spill a copy to a cache-line-aligned buffer (so
that it can then fetch the lot to the ARM L1 -- which might as well be
registers, as far as memory latency is concerned -- in one L1 miss).
Or you can do actual float/SIMD operations with the data, and return a
healthy chunk in registers, without ever touching memory.  (To be
precise, per the AAPCS, you can pass in one 64-byte chunk as a
"Homogeneous Aggregate with a Base Type of 128-bit containerized
vectors with four Elements", and return a similar chunk in the same
registers, with either the same or different contents.)

The point is not really to have "more registers"; the integer
"registers" are just names anyway, and the L1 cache is almost as
close.  Nor is it to pass floating point values to and from public
function calls cheaply; that's worth almost nothing on system scale.
Even in code that uses no floating point or SIMD whatever, there are
potentially big gains from:

  * preserving an additional 64 bytes of VFP/NEON state across
functions that don't need big operands or return values, if you are
willing to alter their function signatures to do so (at zero run-time
cost, if you're systematic about it); or alternately:

  * postponing the transfer of up to 64 bytes of operands from the
VFP/NEON bank to the integer side, allowing more time for pending NEON
operations (especially structure loads) to complete;

  * omitting the transfer from NEON to ARM entirely, if the operands
turn out to be unneeded (or simply written elsewhere in memory without
needing to be touched by the ARM);

  * returning up to 64 bytes of results in the VFP/NEON register bank,
possibly from an address that missed in L2, without stalling to wait
for a pending load to complete;

  * and, if you really do have to move those operands to the ARM,
doing so explicitly and efficiently (by spilling the whole block to a
cache-line-aligned buffer in L2, fetching it back into L1 with a
single load, and filling the delay with some other useful work)
instead of in the worst way possible (by transferring them from VFP to
ARM registers, 4 bytes at a time, before entering the function).

> As for NEON vs. LDM/STM. There are indeed no reasons why for example
> NEON memcpy should be faster than LDM/STM for the large memory buffers
> which do not fit caches. But still this is the case for OMAP3, along
> with some of other memory performance related WTF questions.

I hope I've clarified this a bit above.  But don't take my word for
it; these techniques are almost exactly the same as those described in
Intel's cheat sheet at
http://software.intel.com/en-us/articles/copying-accelerated-video-decode-f=
rame-buffers/
, except that there is no need for the equivalent of "fill buffers" /
"write combining buffers" because VLDM/VSTM can move 128 bytes at a
time.  (It's probable that the right micro-optimization is to work in
64-byte chunks and pipeline more deeply; I haven't benchmarked yet.)

> >> If, that is, it can schedule them appropriately to account for
> >> latencies to and from memory as well as the (reduced but non-zero)
> >> latency of VFP<->ARM transfers.
>
> > The out of order issue on A9 and later makes most such tricks unnecessa=
ry.
>
> VFP/NEON unit from A9 is still in-order.

True but mostly irrelevant.  If your code is at all tight, and your
working set doesn't fit into L2 cache, all the mere arithmetic
pipelines should be stalled most of the time.  The name of the game is
to race as quickly as possible from one fetch from an uncacheable /
unpredictable address to the next that depends on it, and to get as
high an interleave among such fetch chains as possible.  If your
working set isn't larger than L2 cache, why bother thinking about
performance at all?  Your algorithm could be O(n^3) and coded by
banana slugs, and it would still get the job done.

Cheers,
- Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
