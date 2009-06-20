Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 034266B005A
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 21:34:26 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <ae2dd9a2-4e30-4f00-8ecc-9b0b75298971@default>
Date: Fri, 19 Jun 2009 18:35:20 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC PATCH 0/4] transcendent memory ("tmem") for Linux
In-Reply-To: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Apologies for the breach of netiquette with attachments.
Following up with inline patches in separate emails...

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Normal memory is directly addressable by the kernel,
of a known normally-fixed size, synchronously accessible,
and persistent (though not across a reboot).

What if there was a class of memory that is of unknown
and dynamically variable size, is addressable only indirectly
by the kernel, can be configured either as persistent or
as "ephemeral" (meaning it will be around for awhile, but
might disappear without warning), and is still fast enough
to be synchronously accessible?

We call this latter class "transcendent memory" and it
provides an interesting opportunity to more efficiently
utilize RAM in a virtualized environment.  However this
"memory but not really memory" may also have applications
in NON-virtualized environments, such as hotplug-memory
deletion, SSDs, and page cache compression.  Others have
suggested ideas such as allowing use of highmem memory
without a highmem kernel, or use of spare video memory.

Transcendent memory, or "tmem" for short, provides a
well-defined API to access this unusual class of memory.
The basic operations are page-copy-based and use a flexible
object-oriented addressing mechanism.  Tmem assumes
that some "privileged entity" is capable of executing
tmem requests and storing pages of data; this entity
is currently a hypervisor and operations are performed
via hypercalls, but the entity could be a kernel policy,
or perhaps a "memory node" in a cluster of blades connected
by a high-speed interconnect such as hypertransport or QPI.

Since tmem is not directly accessible and because page
copying is done to/from physical pageframes, it more suitable
for in-kernel memory needs than for userland applications.
However, there may be yet undiscovered userland possibilities.

With the tmem concept outlined vaguely and its broader
potential hinted, we will overview two existing examples
of how tmem can be used by the kernel.  These examples are
implemented in the attached (2.6.30-based) patches.

"Precache" can be thought of as a page-granularity victim
cache for clean pages that the kernel's pageframe replacement
algorithm (PFRA) would like to keep around, but can't since
there isn't enough memory.   So when the PFRA "evicts" a page,
it first puts it into the precache via a call to tmem.  And
any time a filesystem reads a page from disk, it first attempts
to get the page from precache.  If it's there, a disk access
is eliminated.  If not, the filesystem just goes to the disk
like normal.  Precache is "ephemeral" so whether a page is kept
in precache (between the "put" and the "get") is dependent on
a number of factors that are invisible to the kernel.

"Preswap" IS persistent, but for various reasons may not always
be available for use, again due to factors that may not be
visible to the kernel (but, briefly, if the kernel is being
"good" and has shared its resources nicely, then it will be
able to use preswap, else it will not).  Once a page is put,
a get on the page will always succeed.  So when the kernel
finds itself in a situation where it needs to swap out a page,
it first attempts to use preswap.  If the put works, a disk
write and (usually) a disk read are avoided.  If it doesn't,
the page is written to swap as usual.  Unlike precache, whether
a page is stored in preswap vs swap is recorded in kernel data
structures, so when a page needs to be fetched, the kernel does
a get if it is in preswap and reads from swap if it is not in
preswap.

Both precache and preswap may be optionally compressed,
trading off 2x space reduction vs 10x performance for access.
Precache also has a sharing feature, which allows different nodes
in a "virtual cluster" to share a local page cache.
(In the attached patch, precache is only implemented for
ext3 and shared precache is only implemented for ocfs2.)

Tmem has some similarity to IBM's Collaborative Memory Management,
but creates more of a partnership between the kernel and the
"privileged entity" and is not very invasive.  Tmem may be
applicable for KVM and containers; there is some disagreement on
the extent of its value. Tmem is highly complementary to ballooning
(aka page granularity hot plug) and memory deduplication (aka
transparent content-based page sharing) but still has value
when neither are present.

Performance is difficult to quantify because some benchmarks
respond very favorably to increases in memory and tmem may
do quite well on those, depending on how much tmem is available
which may vary widely and dynamically, depending on conditions
completely outside of the system being measured.  I'd appreciate
ideas on how best to provide useful metrics.

Tmem is now supported in Xen's unstable tree and in
Xen's 2.6.18-xen source tree.  Again, Xen is not necessarily
a requirement, but currently provides the only existing
implementation of tmem.

Lots more information about tmem can be found at:
http://oss.oracle.com/projects/tmem and there will be
a talk about it on the first day of Linux Symposium
next month.  Tmem is the result of a group effort,
including Chris Mason, Dave McCracken, Kurt Hackel
and Zhigang Wang, with helpful input from Jeremy
Fitzhardinge, Keir Fraser, Ian Pratt, Sunil Mushran,
and Joel Becker

Patches are as follows (organized for review, not for
sequential application):
tmeminf.patch=09infrastructure for tmem layer and API
precache.patch=09precache implementation (layered on tmem)
preswap.patch=09preswap implementation (layered on tmem)
tmemxen.patch=09interface code for tmem on top of Xen

Diffstat below, reorganized to show changed vs new files,
and core kernel vs xen.  (Also attached in case the
formatting gets messed up.)

Any feedback appreciated!

Thanks,
Dan Magenheimer


Changed core kernel files:
 fs/buffer.c                              |    5 +
 fs/ext3/super.c                          |    2=20
 fs/mpage.c                               |    8 ++
 fs/ocfs2/super.c                         |    2=20
 fs/super.c                               |    5 +
 include/linux/fs.h                       |    7 ++
 include/linux/swap.h                     |   57 +++++++++++++++++++++
 include/linux/sysctl.h                   |    1=20
 kernel/sysctl.c                          |   12 ++++
 mm/Kconfig                               |   27 +++++++++
 mm/Makefile                              |    2=20
 mm/filemap.c                             |   11 ++++
 mm/page_io.c                             |   12 ++++
 mm/swapfile.c                            |   41 ++++++++++++---
 mm/truncate.c                            |   10 +++
 15 files changed, 196 insertions(+), 6 deletions(-)

Newly added core kernel files:
 include/linux/tmem.h                     |   22 +
 mm/precache.c                            |  146 +++++++++++
 mm/preswap.c                             |  274 +++++++++++++++++++++
 3 files changed, 442 insertions(+)

Changed xen-specific files:
 arch/x86/include/asm/xen/hypercall.h     |    8 +++
 drivers/xen/Makefile                     |    1=20
 include/xen/interface/tmem.h             |   43 +++++++++++++++++++++
 include/xen/interface/xen.h              |   22 ++++++++++
 4 files changed, 74 insertions(+)

Newly added xen-specific files:
 drivers/xen/tmem.c                       |  106 +++++++++++++++++++++
 include/xen/interface/tmem.h             |   43 ++++++++
 2 files changed, 149 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
