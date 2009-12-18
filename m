Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA706B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 19:37:31 -0500 (EST)
MIME-Version: 1.0
Message-ID: <23e2d3ad-2611-4422-9349-50e4d3d8377f@default>
Date: Thu, 17 Dec 2009 16:36:58 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Tmem [PATCH 0/5] (Take 3): Transcendent memory
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: dan.magenheimer@oracle.com, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, linux-mm@kvack.org, Rusty@rcsinet15.oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, chris.mason@oracle.com, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

Tmem [PATCH 0/5] (Take 3): Transcendent memory
Transcendent memory

Changes since RFC "Take 2" posting (7 July 2009) reviewed at
http://lwn.net/Articles/340080/

1) Refreshed to 2.6.32
2) Support added for btrfs and ext4
3) "Precache" and "preswap" renamed to "cleancache" and "frontswap"
   in response to feedback that "pre" is overloaded and too generic.
4) Most important usage statistics now provided via sysfs, under
   /sys/vm/tmem/cleancache and /sys/vm/tmem/frontswap.
5) Shared pools security issue resolved by external administrative
   tools; shared pool support and ocfs2 support added back again.
6) Some performance measurement done (on a linux-compile workload)
   and presented at OLS; in short, showed savings of ~300 IO/sec
   at an approximate cost of 0.1%-0.2% of one CPU.
And FYI, tmem support is now released as a technology preview in Oracle's
Xen-based Oracle VM 2.2 product and will be released with Xen 4.0
early in 2010.  Both of these provide full save/restore/live migration
support for tmem-enabled VMs and a small set of console-oriented
management tools to view detailed tmem usage across all domains
that use tmem.

(Transcendent memory documentation follows below diffstats.)

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Changed core kernel files:
 fs/btrfs/extent_io.c                     |    9 +++
 fs/btrfs/super.c                         |    2=20
 fs/buffer.c                              |    5 ++
 fs/ext3/super.c                          |    2=20
 fs/ext4/super.c                          |    2=20
 fs/mpage.c                               |    8 +++
 fs/ocfs2/super.c                         |    2=20
 fs/super.c                               |    6 ++
 include/linux/fs.h                       |    7 ++
 include/linux/swap.h                     |   51 +++++++++++++++++++++
 include/linux/sysctl.h                   |    1=20
 kernel/sysctl.c                          |   11 ++++
 mm/Kconfig                               |   26 ++++++++++
 mm/Makefile                              |    3 +
 mm/filemap.c                             |   11 ++++
 mm/page_io.c                             |   12 ++++
 mm/swapfile.c                            |   43 +++++++++++++++--
 mm/truncate.c                            |   10 ++++
 18 files changed, 204 insertions(+), 7 deletions(-)

Newly added core kernel files:
 Documentation/transcendent-memory.txt    |  176 +++++++++++
 include/linux/tmem.h                     |   88 +++++
 mm/cleancache.c                          |  184 ++++++++++++
 mm/frontswap.c                           |  319 +++++++++++++++++++++
 4 files changed, 767 insertions(+)

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

"Cleancache" can be thought of as a page-granularity victim cache for clean
pages that the kernel's pageframe replacement algorithm (PFRA) would like
to keep around, but can't since there isn't enough memory.   So when the
PFRA "evicts" a page, it first puts it into the cleancache via a call to
tmem.  And any time a filesystem reads a page from disk, it first attempts
to get the page from cleancache.  If it's there, a disk access is eliminate=
d.
If not, the filesystem just goes to the disk like normal.  Cleancache is
"ephemeral" so whether a page is kept in cleancache (between the "put" and
the "get") is dependent on a number of factors that are invisible to
the kernel.

"Frontswap" is so named because it can be thought of as the opposite of
a "backing store". Frontswap IS persistent, but for various reasons may not
always be available for use, again due to factors that may not be visible t=
o
the kernel. (But, briefly, if the kernel is being "good" and has shared its
resources nicely, then it will be able to use frontswap, else it will not.)
Once a page is put, a get on the page will always succeed.  So when the
kernel finds itself in a situation where it needs to swap out a page, it
first attempts to use frontswap.  If the put works, a disk write and
(usually) a disk read are avoided.  If it doesn't, the page is written
to swap as usual.  Unlike cleancache, whether a page is stored in frontswap
vs swap is recorded in kernel data structures, so when a page needs to
be fetched, the kernel does a get if it is in frontswap and reads from
swap if it is not in frontswap.

Both cleancache and frontswap may be optionally compressed, trading off 2x
space reduction vs 10x performance for access.  Cleancache also has a
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

Tmem is supported starting in Xen 4.0 and is in Xen's Linux 2.6.18-xen
source tree.  It is also released as a technology preview in Oracle's
Xen-based virtualization product, Oracle VM 2.2.  Again, Xen is not
necessarily a requirement, but currently provides the only existing
implementation of tmem.

Lots more information about tmem can be found at:
  http://oss.oracle.com/projects/tmem
and there was a talk about it on the first day of Linux Symposium in
July 2009; an updated talk is planned at linux.conf.au in January 2010.
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

The specific tmem functions are called in Linux through a set of
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
