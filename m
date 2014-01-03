From: Dave Hansen <dave@sr71.net>
Subject: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
Date: Fri, 03 Jan 2014 10:01:47 -0800
Message-ID: <20140103180147.6566F7C1@viggo.jf.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org, Dave Hansen <dave@sr71.net>
List-Id: linux-mm.kvack.org

This is a minor update from the last version.  The most notable
thing is that I was able to demonstrate that maintaining the
cmpxchg16 optimization has _some_ value.

Otherwise, the code changes are just a few minor cleanups.

---

SLUB depends on a 16-byte cmpxchg for an optimization which
allows it to not disable interrupts in its fast path.  This
optimization has some small but measurable benefits:

	http://lkml.kernel.org/r/52B345A3.6090700@sr71.net

In order to get guaranteed 16-byte alignment (required by the
hardware on x86), 'struct page' is padded out from 56 to 64
bytes.

Those 8-bytes matter.  We've gone to great lengths to keep
'struct page' small in the past.  It's a shame that we bloat it
now just for alignment reasons when we have extra space.  Plus,
bloating such a commonly-touched structure *HAS* cache
footprint implications.

These patches attempt _internal_ alignment instead of external
alignment for slub.

I also got a bug report from some folks running a large database
benchmark.  Their old kernel uses slab and their new one uses
slub.  They were swapping and couldn't figure out why.  It turned
out to be the 2GB of RAM that the slub padding wastes on their
system.

On my box, that 2GB cost about $200 to populate back when we
bought it.  I want my $200 back.

This set takes me from 16909584K of reserved memory at boot
down to 14814472K, so almost *exactly* 2GB of savings!  It also
helps performance, presumably because it touches 14% fewer
struct page cachelines.  A 30GB dd to a ramfs file:

        dd if=/dev/zero of=bigfile bs=$((1<<30)) count=30

is sped up by about 4.4% in my testing.

I've run this through its paces and have not had stability issues
with it.  It definitely needs some more testing, but it's
definitely ready for a wider audience.

I also wrote up a document describing 'struct page's layout:

	http://tinyurl.com/n6kmedz
