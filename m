Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 95FD66B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 01:29:10 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so39057505pac.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 22:29:10 -0700 (PDT)
Received: from mail.sfc.wide.ad.jp (shonan.sfc.wide.ad.jp. [2001:200:0:8803::53])
        by mx.google.com with ESMTPS id bw4si25437714pbd.227.2015.05.12.22.29.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 22:29:08 -0700 (PDT)
From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Subject: [PATCH v5 00/10] an introduction of Linux library operating system (LibOS)
Date: Wed, 13 May 2015 07:28:31 +0200
Message-Id: <1431494921-24746-1-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1430103618-10832-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1430103618-10832-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

This is the 5th version of Linux LibOS patchset which reflects a
couple of comments received from people.

changes from v4:
- Patch 09/10 ("lib: libos build scripts and documentation")
1) lib: fix dependency detection of kernel/time/timeconst.h
   (commented by Richard Weinberger)
- Overall
2) rebased to Linux 4.1-rc3 (4cfceaf0c087f47033f5e61a801f4136d6fb68c6)

changes from v3:
- Patch 09/10 ("lib: libos build scripts and documentation")
1) Remove RFC (now it's a proposal)
2) build environment cleanup (commented by Paul Bolle)
- Overall
3) change based tree from arnd/asm-generic to torvalds/linux.git
   (commented by Richard Weinberger)
4) rebased to Linux 4.1-rc1 (b787f68c36d49bb1d9236f403813641efa74a031)
5) change the title of cover letter a bit

changes from v2:
- Patch 02/11 ("slab: add private memory allocator header for arch/lib")
1) add new allocator named SLIB (Library Allocator): Patch 04/11 is integrated
   to 02 (commented by Christoph Lameter)
- Overall
2) rewrite commit log messages

changes from v1:
- Patch 01/11 ("sysctl: make some functions unstatic to access by arch/lib"):
1) add prefix ctl_table_ to newly publiced functions (commented by Joe Perches)
- Patch 08/11 ("lib: other kernel glue layer code"):
2) significantly reduce glue codes (stubs) (commented by Richard Weinberger)
- Others
3) adapt to linux-4.0.0
4) detect make dependency by Kbuild .cmd files

patchset history
-----------------
[v4] : https://lkml.org/lkml/2015/4/26/279
[v3] : https://lkml.org/lkml/2015/4/19/63
[v2] : https://lkml.org/lkml/2015/4/17/140
[v1] : https://lkml.org/lkml/2015/3/24/254

This is an introduction of Linux library operating system (LibOS).

Our objective is to build the kernel network stack as a shared library
that can be linked to by userspace programs to provide network stack
personalization and testing facilities, and allow researchers to more
easily simulate complex network topologies of linux routers/hosts.

Although the architecture itself can virtualize various things, the
current design only focuses on the network stack. You can benefit
network stack feature such as TCP, UDP, SCTP, DCCP (IPv4 and IPv6),
Mobie IPv6, Multipath TCP (IPv4/IPv6, out-of-tree at the present
moment), and netlink with various userspace applications (quagga,
iproute2, iperf, wget, and thttpd).

== What is LibOS ? ==

The library exposes an entry point as API, which is lib_init(), in
order to connect userspace applications to the (userspace-version)
kernel network stack. The clock source, virtual struct net_device, and
scheduler are provided by caller while kernel resource like system
calls is provided by callee.

Once the LibOS is initialized via the API, userspace applications with
POSIX socket can use the system calls defined in LibOS by replacing
from the original socket-related symbols to the LibOS-specific
one. Then application can benefit the network stack of LibOS without
involving the host network stack.

Currently, there are two users of LibOS: Network Stack in Userspace
(NUSE) and ns-3 network simulatior with Direct Code Execution
(DCE). These codes are managed at an external repository(*1).


== How to use it ? ==

to build the library,
% make {defconfig,menuconfig} ARCH=lib

then, build it.
% make library ARCH=lib

You will see liblinux-$(KERNELVERSION).so in the top directory.

== More information ==

The crucial difference between UML (user-mode linux) and this approach
is that we allow multiple network stack instances to co-exist within a
single process with dlmopen(3) like linking for easy debugging.


These patches are also available on this branch:

git://github.com/libos-nuse/net-next-nuse.git for-linus-upstream-libos-v5


For further information, here is a slideset presented at the last
netdev0.1 conference.

http://www.slideshare.net/hajimetazaki/library-operating-system-for-linux-netdev01

I would appreciate any kind of your feedback regarding to upstream
this feature.

*1 https://github.com/libos-nuse/linux-libos-tools


Hajime Tazaki (10):
  sysctl: make some functions unstatic to access by arch/lib
  slab: add SLIB (Library memory allocator) for  arch/lib
  lib: public headers and API implementations for userspace programs
  lib: time handling (kernel glue code)
  lib: context and scheduling functions (kernel glue code) for libos
  lib: sysctl handling (kernel glue code)
  lib: other kernel glue layer code
  lib: auxiliary files for auto-generated asm-generic files of libos
  lib: libos build scripts and documentation
  lib: tools used for test scripts

 Documentation/virtual/libos-howto.txt | 144 ++++++++
 MAINTAINERS                           |   9 +
 arch/lib/.gitignore                   |   3 +
 arch/lib/Kconfig                      | 124 +++++++
 arch/lib/Makefile                     | 224 ++++++++++++
 arch/lib/Makefile.print               |  45 +++
 arch/lib/capability.c                 |  25 ++
 arch/lib/defconfig                    | 653 ++++++++++++++++++++++++++++++++++
 arch/lib/filemap.c                    |  32 ++
 arch/lib/fs.c                         |  70 ++++
 arch/lib/generate-linker-script.py    |  50 +++
 arch/lib/glue.c                       | 289 +++++++++++++++
 arch/lib/hrtimer.c                    | 122 +++++++
 arch/lib/include/asm/Kbuild           |  57 +++
 arch/lib/include/asm/atomic.h         |  59 +++
 arch/lib/include/asm/barrier.h        |   8 +
 arch/lib/include/asm/bitsperlong.h    |  16 +
 arch/lib/include/asm/current.h        |   7 +
 arch/lib/include/asm/elf.h            |  10 +
 arch/lib/include/asm/hardirq.h        |   8 +
 arch/lib/include/asm/page.h           |  14 +
 arch/lib/include/asm/pgtable.h        |  30 ++
 arch/lib/include/asm/processor.h      |  19 +
 arch/lib/include/asm/ptrace.h         |   4 +
 arch/lib/include/asm/segment.h        |   6 +
 arch/lib/include/asm/sembuf.h         |   4 +
 arch/lib/include/asm/shmbuf.h         |   4 +
 arch/lib/include/asm/shmparam.h       |   4 +
 arch/lib/include/asm/sigcontext.h     |   6 +
 arch/lib/include/asm/stat.h           |   4 +
 arch/lib/include/asm/statfs.h         |   4 +
 arch/lib/include/asm/swab.h           |   7 +
 arch/lib/include/asm/thread_info.h    |  36 ++
 arch/lib/include/asm/uaccess.h        |  14 +
 arch/lib/include/asm/unistd.h         |   4 +
 arch/lib/include/sim-assert.h         |  23 ++
 arch/lib/include/sim-init.h           | 134 +++++++
 arch/lib/include/sim-printf.h         |  13 +
 arch/lib/include/sim-types.h          |  53 +++
 arch/lib/include/sim.h                |  51 +++
 arch/lib/include/uapi/asm/byteorder.h |   6 +
 arch/lib/lib-device.c                 | 187 ++++++++++
 arch/lib/lib-socket.c                 | 410 +++++++++++++++++++++
 arch/lib/lib.c                        | 294 +++++++++++++++
 arch/lib/lib.h                        |  21 ++
 arch/lib/modules.c                    |  36 ++
 arch/lib/pid.c                        |  29 ++
 arch/lib/print.c                      |  56 +++
 arch/lib/proc.c                       |  34 ++
 arch/lib/random.c                     |  53 +++
 arch/lib/sched.c                      | 406 +++++++++++++++++++++
 arch/lib/softirq.c                    | 108 ++++++
 arch/lib/sysctl.c                     | 270 ++++++++++++++
 arch/lib/sysfs.c                      |  83 +++++
 arch/lib/tasklet-hrtimer.c            |  57 +++
 arch/lib/tasklet.c                    |  76 ++++
 arch/lib/time.c                       | 144 ++++++++
 arch/lib/timer.c                      | 238 +++++++++++++
 arch/lib/vmscan.c                     |  26 ++
 arch/lib/workqueue.c                  | 242 +++++++++++++
 fs/proc/proc_sysctl.c                 |  36 +-
 include/linux/slab.h                  |   6 +-
 include/linux/slib_def.h              |  21 ++
 mm/Makefile                           |   1 +
 mm/slab.h                             |   4 +
 mm/slib.c                             | 205 +++++++++++
 tools/testing/libos/.gitignore        |   6 +
 tools/testing/libos/Makefile          |  38 ++
 tools/testing/libos/README            |  15 +
 tools/testing/libos/bisect.sh         |  10 +
 tools/testing/libos/dce-test.sh       |  23 ++
 tools/testing/libos/nuse-test.sh      |  57 +++
 72 files changed, 5569 insertions(+), 18 deletions(-)
 create mode 100644 Documentation/virtual/libos-howto.txt
 create mode 100644 arch/lib/.gitignore
 create mode 100644 arch/lib/Kconfig
 create mode 100644 arch/lib/Makefile
 create mode 100644 arch/lib/Makefile.print
 create mode 100644 arch/lib/capability.c
 create mode 100644 arch/lib/defconfig
 create mode 100644 arch/lib/filemap.c
 create mode 100644 arch/lib/fs.c
 create mode 100755 arch/lib/generate-linker-script.py
 create mode 100644 arch/lib/glue.c
 create mode 100644 arch/lib/hrtimer.c
 create mode 100644 arch/lib/include/asm/Kbuild
 create mode 100644 arch/lib/include/asm/atomic.h
 create mode 100644 arch/lib/include/asm/barrier.h
 create mode 100644 arch/lib/include/asm/bitsperlong.h
 create mode 100644 arch/lib/include/asm/current.h
 create mode 100644 arch/lib/include/asm/elf.h
 create mode 100644 arch/lib/include/asm/hardirq.h
 create mode 100644 arch/lib/include/asm/page.h
 create mode 100644 arch/lib/include/asm/pgtable.h
 create mode 100644 arch/lib/include/asm/processor.h
 create mode 100644 arch/lib/include/asm/ptrace.h
 create mode 100644 arch/lib/include/asm/segment.h
 create mode 100644 arch/lib/include/asm/sembuf.h
 create mode 100644 arch/lib/include/asm/shmbuf.h
 create mode 100644 arch/lib/include/asm/shmparam.h
 create mode 100644 arch/lib/include/asm/sigcontext.h
 create mode 100644 arch/lib/include/asm/stat.h
 create mode 100644 arch/lib/include/asm/statfs.h
 create mode 100644 arch/lib/include/asm/swab.h
 create mode 100644 arch/lib/include/asm/thread_info.h
 create mode 100644 arch/lib/include/asm/uaccess.h
 create mode 100644 arch/lib/include/asm/unistd.h
 create mode 100644 arch/lib/include/sim-assert.h
 create mode 100644 arch/lib/include/sim-init.h
 create mode 100644 arch/lib/include/sim-printf.h
 create mode 100644 arch/lib/include/sim-types.h
 create mode 100644 arch/lib/include/sim.h
 create mode 100644 arch/lib/include/uapi/asm/byteorder.h
 create mode 100644 arch/lib/lib-device.c
 create mode 100644 arch/lib/lib-socket.c
 create mode 100644 arch/lib/lib.c
 create mode 100644 arch/lib/lib.h
 create mode 100644 arch/lib/modules.c
 create mode 100644 arch/lib/pid.c
 create mode 100644 arch/lib/print.c
 create mode 100644 arch/lib/proc.c
 create mode 100644 arch/lib/random.c
 create mode 100644 arch/lib/sched.c
 create mode 100644 arch/lib/softirq.c
 create mode 100644 arch/lib/sysctl.c
 create mode 100644 arch/lib/sysfs.c
 create mode 100644 arch/lib/tasklet-hrtimer.c
 create mode 100644 arch/lib/tasklet.c
 create mode 100644 arch/lib/time.c
 create mode 100644 arch/lib/timer.c
 create mode 100644 arch/lib/vmscan.c
 create mode 100644 arch/lib/workqueue.c
 create mode 100644 include/linux/slib_def.h
 create mode 100644 mm/slib.c
 create mode 100644 tools/testing/libos/.gitignore
 create mode 100644 tools/testing/libos/Makefile
 create mode 100644 tools/testing/libos/README
 create mode 100755 tools/testing/libos/bisect.sh
 create mode 100755 tools/testing/libos/dce-test.sh
 create mode 100755 tools/testing/libos/nuse-test.sh

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
