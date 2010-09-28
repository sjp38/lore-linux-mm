Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0DD606B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 21:58:46 -0400 (EDT)
Received: by wyb36 with SMTP id 36so7310838wyb.14
        for <linux-mm@kvack.org>; Mon, 27 Sep 2010 18:58:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1285353469.3292.14042.camel@nimitz>
References: <AANLkTim1R7-FVwofw-otpGCcHqQHLDwaTYYWFS1ZhSoW@mail.gmail.com>
	<1285353469.3292.14042.camel@nimitz>
Date: Mon, 27 Sep 2010 18:58:44 -0700
Message-ID: <AANLkTikqXGvJUX1kR0XY-ug1m4O9KTS+E6Qv1Birt3mT@mail.gmail.com>
Subject: Re: Linux swapping with MySQL/InnoDB due to NUMA architecture
 imbalanced allocations?
From: Jeremy Cole <jeremy@jcole.us>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave,

Thanks for your response.  This is helpful.  And, my testing with
"numactl --interleave=3Dall" is going well, so far testing indicates
that it completely eliminates the swapping, without incurring a
measurable performance penalty for my workload.

> Your situation sounds pretty familiar. =A0It happens a lot when
> applications are moved over to a NUMA system for the first time. =A0Your
> interleaving solution is a decent one, although teaching the database
> about NUMA is a much better long-term approach.

That's exactly my thought.  I've read through the NUMA API
documentation, and it looks like it's not at all insurmountable to, at
the very least, ensure that the big cache allocations (InnoDB buffer
pool, MyISAM key buffer, etc.) are done interleaved, while leaving
most of the rest alone.  My biggest worry with using "numactl
--interleave=3Dall" is that all of the small buffers allocated for the
use of a single thread (for instance query text buffer, sorting
buffers, etc.) will get spread around.  I'm still working to
completely understand the implications of this on performance, but I
don't think it will be terribly bad -- much better than the current
swapping situation, certainly.

> As far as the decisions about running reclaim or swapping versus going
> to another node for an allocation, take a look at the
> "zone_reclaim_mode" bits in Documentation/sysctl/vm.txt . =A0It does a
> decent job of explaining what we do.

I had read about zone_reclaim_mode, and I've also been testing
different settings for it, but I don't think it actually completely
solves the situation here.  It seems to be primarily concerned with
allocations that *could* happen anywhere, whereas I think what we're
often seeing is that memory for whatever reason (which is not
completely obvious to me) *must* be allocated on Node X, but Node X
has no free memory and no caches to free.

Nonetheless, I have to admit that I don't completely understand the
documentation for zone_reclaim_mode in its current form.  Perhaps you
could answer a few questions?  I feel that the documentation could be
updated with some important answers, which are missing now:

1. What "zone reclaim" actually means.  My understanding is that "zone
reclaim" is the practice of freeing memory on a specific node where
memory was preferentially requested (due to NUMA memory allocation
policy, by default "local") in favor of satisfying the allocation
using free memory from wherever it is currently available.

2. It isn't terribly clear what the default (0) policy is, and it
could use an explanation.  Here's my take on it:

When zone_reclaim_mode =3D 0, programs requesting memory to be allocated
on a particular node will only receive memory on the requested node if
free memory is available.  If no free memory is available on the
requested node, but free memory is available on a different node, the
allocation will be made there unless policy forbids it.  If no free
memory is available on any node, then the normal cache freeing and
paging out policies will apply to make free memory available on any
node to satisfy the allocation. [Is there any preference for which
node caches are freed from in this case?]

Is this correct?

3. I found that the list of possible values' descriptions are a bit
too terse to be usable by me.  Here are some efforts to refine the
definitions:

  a. "1 =3D Zone reclaim on" -- This means that cache pages will be
freed to make free memory to satisfy the request only if they are not
dirty.

  b. "2 =3D Zone reclaim writes dirty pages out" -- This means that
dirty cache pages will be written out and then freed if no clean pages
are available to be freed.  This incurs additional cost due to disk
I/O.

  c. "4 =3D Zone reclaim swaps pages" -- This means that anonymous pages
may be swapped out to disk and then freed if no clean pages are
available to be freed and (if bit 2 is set) no dirty cache pages are
available to be written out and freed.  This incurs additional cost
due to swap I/O.

Do those refinements make sense and are they correct?

4. How is it determined that "pages from remote zones will cause a
measurable performance reduction"?  My understanding is that this is
based on whether the node distance, as reported by "numactl
--hardware" is > RECLAIM_DISTANCE (by default defined as 20).  In this
case zone_reclaim_mode will be set to 1 by default by the kernel,
meaning cache pages may be freed on the particular node to make free
memory in order to preferentially allocate for programs that request
on a particular node.

5. I cannot parse/understand this statement at all: "Allowing regular
swap effectively restricts allocations to the local node unless
explicitly overridden by memory policies or cpuset configurations." --
Could this be rephrased and/or explained?

Thanks, again, everyone.

Regards,

Jeremy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
