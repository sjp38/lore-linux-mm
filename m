Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECF76B005A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:16:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <482d25af-01eb-4c2a-9b1d-bdaf4020ce88@default>
Date: Tue, 7 Jul 2009 09:17:11 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Tmem [PATCH 0/4] (Take 2): Transcendent memory
Transcendent memory - Take 2
Changes since take 1:
1) Patches can be applied serially; function names in diff (Rik van Riel)
2) Descriptions and diffstats for individual patches (Rik van Riel)
3) Restructure of tmem_ops to be more Linux-like (Jeremy Fitzhardinge)
4) Drop shared pools until security implications are understood (Pavel
   Machek and Jeremy Fitzhardinge)
5) Documentation/transcendent-memory.txt added including API description
   (see also below for API description).

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Normal memory is directly addressable by the kernel, of a known
normally-fixed size, synchronously accessible, and persistent (though
not across a reboot).

What if there was a class of memory that is of unknown and dynamically
variable size, is addressable only indirectly by the kernel, can be
configured either as persistent or as "ephemeral" (meaning it will be
around for awhile, but might disappear without warning), and is still
fast enough to be synchronously accessible?

We call this latter class "transcendent memory" and it provides an
interesting opportunity to more efficiently utilize RAM in a virtualized
environment.  However this "memory but not really memory" may also have
applications in NON-virtualized environments, such as hotplug-memory
deletion, SSDs, and page cache compression.  Others have suggested ideas
such as allowing use of highmem memory without a highmem kernel, or use
of spare video memory.

Transcendent memory, or "tmem" for short, provides a well-defined API to
access this unusual class of memory.  (A summary of the API is provided
below.)  The basic operations are page-copy-based and use a flexible
object-oriented addressing mechanism.  Tmem assumes that some "privileged
entity" is capable of executing tmem requests and storing pages of data;
this entity is currently a hypervisor and operations are performed via
hypercalls, but the entity could be a kernel policy, or perhaps a
"memory node" in a cluster of blades connected by a high-speed
interconnect such as hypertransport or QPI.

Since tmem is not directly accessible and because page copying is done
to/from physical pageframes, it more suitable for in-kernel memory needs
than for userland applications.  However, there may be yet undiscovered
userland possibilities.

With the tmem concept outlined vaguely and its broader potential hinted,
we will overview two existing examples of how tmem can be used by the
kernel.

"Precache" can be thought of as a page-granularity victim cache for clean
pages that the kernel's pageframe replacement algorithm (PFRA) would like
to keep around, but can't since there isn't enough memory.   So when the
PFRA "evicts" a page, it first puts it into the precache via a call to
tmem.  And any time a filesystem reads a page from disk, it first attempts
to get the page from precache.  If it's there, a disk access is eliminated.
If not, the filesystem just goes to the disk like normal.  Precache is
"ephemeral" so whether a page is kept in precache (between the "put" and
the "get") is dependent on a number of factors that are invisible to
the kernel.

"Preswap" IS persistent, but for various reasons may not always be
available for use, again due to factors that may not be visible to the
kernel (but, briefly, if the kernel is being "good" and has shared its
resources nicely, then it will be able to use preswap, else it will not).
Once a page is put, a get on the page will always succeed.  So when the
kernel finds itself in a situation where it needs to swap out a page, it
first attempts to use preswap.  If the put works, a disk write and
(usually) a disk read are avoided.  If it doesn't, the page is written
to swap as usual.  Unlike precache, whether a page is stored in preswap
vs swap is recorded in kernel data structures, so when a page needs to
be fetched, the kernel does a get if it is in preswap and reads from
swap if it is not in preswap.

Both precache and preswap may be optionally compressed, trading off 2x
space reduction vs 10x performance for access.  Precache also has a
sharing feature, which allows different nodes in a "virtual cluster"
to share a local page cache.

Tmem has some similarity to IBM's Collaborative Memory Management, but
creates more of a partnership between the kernel and the "privileged
entity" and is not very invasive.  Tmem may be applicable for KVM and
containers; there is some disagreement on the extent of its value.
Tmem is highly complementary to ballooning (aka page granularity hot
plug) and memory deduplication (aka transparent content-based page
sharing) but still has value when neither are present.

Performance is difficult to quantify because some benchmarks respond
very favorably to increases in memory and tmem may do quite well on
those, depending on how much tmem is available which may vary widely
and dynamically, depending on conditions completely outside of the
system being measured.  Ideas on how best to provide useful metrics
would be appreciated.

Tmem is now supported in Xen's unstable tree (targeted for the Xen 3.5
release) and in Xen's Linux 2.6.18-xen source tree.  Again, Xen is not
necessarily a requirement, but currently provides the only existing
implementation of tmem.

Lots more information about tmem can be found at:
http://oss.oracle.com/projects/tmem and there will be
a talk about it on the first day of Linux Symposium in July 2009.
Tmem is the result of a group effort, including Dan Magenheimer,
Chris Mason, Dave McCracken, Kurt Hackel and Zhigang Wang, with helpful
input from Jeremy Fitzhardinge, Keir Fraser, Ian Pratt, Sunil Mushran,
Joel Becker, and Jan Beulich.

THE TRANSCENDENT MEMORY API

Transcendent memory is made up of a set of pools.  Each pool is made
up of a set of objects.  And each object contains a set of pages.
The combination of a 32-bit pool id, a 64-bit object id, and a 32-bit
page id, uniquely identify a page of tmem data, and this tuple is called
a "handle." Commonly, the three parts of a handle are used to address
a filesystem, a file within that filesystem, and a page within that file;
however an OS can use any values as long as they uniquely identify
a page of data.

When a tmem pool is created, it is given certain attributes: It can
be private or shared, and it can be persistent or ephemeral.  Each
combination of these attributes provides a different set of useful
functionality and also defines a slightly different set of semantics
for the various operations on the pool.  Other pool attributes include
the size of the page and a version number.

Once a pool is created, operations are performed on the pool.  Pages
are copied between the OS and tmem and are addressed using a handle.
Pages and/or objects may also be flushed from the pool.  When all
operations are completed, a pool can be destroyed.

The specific tmem functions are called in Linux through a set of=20
accessor functions:

int (*new_pool)(struct tmem_pool_uuid uuid, u32 flags);
int (*destroy_pool)(u32 pool_id);
int (*put_page)(u32 pool_id, u64 object, u32 index, unsigned long pfn);
int (*get_page)(u32 pool_id, u64 object, u32 index, unsigned long pfn);
int (*flush_page)(u32 pool_id, u64 object, u32 index);
int (*flush_object)(u32 pool_id, u64 object);

The new_pool accessor creates a new pool and returns a pool id
which is a non-negative 32-bit integer.  If the flags parameter
specifies that the pool is to be shared, the uuid is a 128-bit "shared
secret" else it is ignored.  The destroy_pool accessor destroys the pool.
(Note: shared pools are not supported until security implications
are better understood.)

The put_page accessor copies a page of data from the specified pageframe
and associates it with the specified handle.

The get_page accessor looks up a page of data in tmem associated with
the specified handle and, if found, copies it to the specified pageframe.

The flush_page accessor ensures that subsequent gets of a page with
the specified handle will fail.  The flush_object accessor ensures
that subsequent gets of any page matching the pool id and object
will fail.

There are many subtle but critical behaviors for get_page and put_page:
- Any put_page (with one notable exception) may be rejected and the client
  must be prepared to deal with that failure.  A put_page copies, NOT moves=
,
  data; that is the data exists in both places.  Linux is responsible for
  destroying or overwriting its own copy, or alternately managing any
  coherency between the copies.
- Every page successfully put to a persistent pool must be found by a
  subsequent get_page that specifies the same handle.  A page successfully
  put to an ephemeral pool has an indeterminate lifetime and even an
  immediately subsequent get_page may fail.
- A get_page to a private pool is destructive, that is it behaves as if
  the get_page were atomically followed by a flush_page.  A get_page
  to a shared pool is non-destructive.  A flush_page behaves just like
  a get_page to a private pool except the data is thrown away.
- Put-put-get coherency is guaranteed.  For example, after the sequence:
        put_page(ABC,D1);
        put_page(ABC,D2);
        get_page(ABC,E)
  E may never contain the data from D1.  However, even for a persistent
  pool, the get_page may fail if the second put_page indicates failure.
- Get-get coherency is guaranteed.  For example, in the sequence:
        put_page(ABC,D);
        get_page(ABC,E1);
        get_page(ABC,E2)
  if the first get_page fails, the second must also fail.
- A tmem implementation provides no serialization guarantees (e.g. to
  an SMP Linux).  So if different Linux threads are putting and flushing
  the same page, the results are indeterminate.
  guaranteed and must be synchronized by Linux.

Changed core kernel files:
 fs/buffer.c                              |    5 +
 fs/ext3/super.c                          |    2=20
 fs/mpage.c                               |    8 ++
 fs/super.c                               |    5 +
 include/linux/fs.h                       |    7 ++
 include/linux/swap.h                     |   57 +++++++++++++++++++++
 include/linux/sysctl.h                   |    1=20
 kernel/sysctl.c                          |   12 ++++
 mm/Kconfig                               |   26 +++++++++
 mm/Makefile                              |    3 +
 mm/filemap.c                             |   11 ++++
 mm/page_io.c                             |   12 ++++
 mm/swapfile.c                            |   46 ++++++++++++++--
 mm/truncate.c                            |   10 +++
 14 files changed, 199 insertions(+), 6 deletions(-)

Newly added core kernel files:
 Documentation/transcendent-memory.txt    |  175 +++++++++++++
 include/linux/tmem.h                     |   88 ++++++
 mm/precache.c                            |  134 ++++++++++
 mm/preswap.c                             |  273 +++++++++++++++++++++
 4 files changed, 670 insertions(+)

Changed xen-specific files:
 arch/x86/include/asm/xen/hypercall.h     |    8 +++
 drivers/xen/Makefile                     |    1=20
 include/xen/interface/tmem.h             |   43 +++++++++++++++++++++
 include/xen/interface/xen.h              |   22 ++++++++++
 4 files changed, 74 insertions(+)

Newly added xen-specific files:
 drivers/xen/tmem.c                       |   97 +++++++++++++++++++++
 include/xen/interface/tmem.h             |   43 +++++++++
 2 files changed, 140 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
