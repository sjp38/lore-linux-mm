Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E91BF6B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 10:17:06 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so48184817pac.3
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:17:06 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id as7si9060935pac.16.2015.09.03.07.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 07:17:05 -0700 (PDT)
Received: by pacwi10 with SMTP id wi10so48184397pac.3
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:17:05 -0700 (PDT)
From: Hajime Tazaki <thehajime@gmail.com>
Subject: [PATCH v6 00/10] an introduction of Linux library operating system (LibOS)
Date: Thu,  3 Sep 2015 23:16:22 +0900
Message-Id: <1441289792-64064-1-git-send-email-thehajime@gmail.com>
In-Reply-To: <1431494921-24746-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1431494921-24746-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <thehajime@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

Although I've been kept quiet, I'm preparing this 6th version of Linux
LibOS patchset.

During the time, I've observed the growth of our branch and seen two
good news regarding the maintenance overhead and benefit of libos patches.

* news 1

To answer the following suggestion raised by Richard Weinberger, I've
observed the maintenance burden (manual modification, follow stub
function signature, etc) which we were worried about.

> I'd suggest the following:
> Maintain LibOS in your git tree and follow Linus' tree.
> Make sure that all kernel releases build and work.
> 
> This way you can experiment with automation and other
> stuff. If it works well you can ask for mainline inclusion
> after a few kernel releases.
> 
> Your git history will show how much maintenance burden
> LibOS has and how much with every merge window breaks and
> needs manual fixup.


here is the list of commits which I updated stub functions since
around 4.0 release. As I mentioned, each of stub functions updates are
mostly happened during merge window and those are 2 to 5. We may see
similar numbers in coming the 4.3 version.

4.1-4.2
- 2000c14 lib: fix the signature of vfs_caches_init() (4.2-rc6)
- 576b8d7 lib: fix new proc behavior for emulated proc files (4.2-rc1)
- b72596c lib: fix workqueue stub for new header (4.2-rc1)
- 06289a2 merge conflicts (MAINTAINERS) (4.2-rc1)
- 12c0b79 lib: fix new signature of struct timer_list (4.2-rc0)
4.0-4.1
- acbf6ed lib: fix __ktime_divns() to latest update (4.1-rc7)
- 0fe9ba4 lib: merge fix from net-next around 4.0.0-next (4.1-rc0)
- 070691d lib: fix new sock_sendmsg() API (4.1-rc0)
3.19-4.0
- 609d8c7 lib: adapt linux-4.0.0-rc7
- 796347a lib: adapt linux-4.0.0-rc5

the full list of commit history can be found below, which also
includes other commits of libos enhancements.

https://github.com/libos-nuse/net-next-nuse/commits/master?author=thehajime

Considering the number of commits in Linus tree since v4.0 to now
(4.2+) is around 29K, I think the number of stubs update (in libos) is
not that big matter.

I believe saying something with the-number-of-commits makes almost
zero sense, but will help to smell something a bit.

I would like to hear your honest opinions.


* news 2
on the other hand, I also have a good news which libos has detected a
couple of regressions in net-next tree.

- [net-next,v2] ipv6: Do not iterate over all interfaces when finding source address on specific interface. (v4.2-rc0)
 patchwork:
 http://patchwork.ozlabs.org/patch/493675/
 detected by:
 http://ns-3-dce.cloud.wide.ad.jp/jenkins/job/daily-net-next-sim/958/

- [v3] ipv6: Fix protocol resubmission (v4.1-rc7)
 patchwork:
 http://patchwork.ozlabs.org/patch/482645/
 detected by:
 http://ns-3-dce.cloud.wide.ad.jp/jenkins/job/umip-net-next/716/

- [net-next] ipv6: Check RTF_LOCAL on rt->rt6i_flags instead of rt->dst.flags
 patchwork:
 http://patchwork.ozlabs.org/patch/467447/
 detected by:
 http://ns-3-dce.cloud.wide.ad.jp/jenkins/job/daily-net-next-sim/878/

- [net-next] xfrm6: Fix a offset value for network header in _decode_session6 (v3.19-rc7?)
 patchwork:
 http://patchwork.ozlabs.org/patch/436351/

some of detected bugs with other tests like kbuild test robot are not
included: above bugs purely require real and (sometimes) complex
setup, which DCE (libos) eases with the virtualized environment.



changes from v5:
- Patch 09/10 ("lib: libos build scripts and documentation")
1) introduce symbol namespace for the symbols in Linux libos to avoid conflicts
- Patch 04/10 ("lib: time handling (kernel glue code)")
2) lib: un-stub timekeeping code and reuse timekeeping.c and co.
- Overall
3) rebased to Linux 4.2+ (revision 1e1a4e8f439113b7820bc7150569f685e1cc2b43)

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
[v5] : https://lkml.org/lkml/2015/5/13/25
[v4] : https://lkml.org/lkml/2015/4/26/279
[v3] : https://lkml.org/lkml/2015/4/19/63
[v2] : https://lkml.org/lkml/2015/4/17/140
[v1] : https://lkml.org/lkml/2015/3/24/254

This is an introduction of Linux library operating system (LibOS).

Our objective is to build the kernel network stack as a shared library
that can be linked to by userspace programs to provide network stack
personality and testing facilities, and allow researchers to more
easily simulate complex network topologies of linux routers/hosts.

Although the architecture itself can virtualize various things, the
current design only focuses on the network stack. You can benefit
network stack feature such as TCP, UDP, SCTP, DCCP (IPv4 and IPv6),
Mobie IPv6, Multipath TCP (IPv4/IPv6, out-of-tree at the present
moment), and netlink with various userspace applications (quagga,
iproute2, iperf, wget, and thttpd).

== What is LibOS ? ==

The library exposes an entry point as an API, which is lib_init(), in
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

git://github.com/libos-nuse/net-next-nuse.git for-linus-upstream-libos-v6


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
 arch/lib/Makefile                     | 235 ++++++++++++
 arch/lib/Makefile.print               |  45 +++
 arch/lib/capability.c                 |  25 ++
 arch/lib/defconfig                    | 655 ++++++++++++++++++++++++++++++++++
 arch/lib/filemap.c                    |  32 ++
 arch/lib/fs.c                         |  70 ++++
 arch/lib/generate-linker-script.py    |  50 +++
 arch/lib/glue.c                       | 284 +++++++++++++++
 arch/lib/hrtimer.c                    | 117 ++++++
 arch/lib/include/asm/Kbuild           |  57 +++
 arch/lib/include/asm/atomic.h         |  62 ++++
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
 arch/lib/lib-socket.c                 | 370 +++++++++++++++++++
 arch/lib/lib.c                        | 296 +++++++++++++++
 arch/lib/lib.h                        |  21 ++
 arch/lib/modules.c                    |  36 ++
 arch/lib/pid.c                        |  29 ++
 arch/lib/print.c                      |  56 +++
 arch/lib/proc.c                       |  36 ++
 arch/lib/random.c                     |  54 +++
 arch/lib/sched.c                      | 406 +++++++++++++++++++++
 arch/lib/softirq.c                    | 108 ++++++
 arch/lib/sysctl.c                     | 270 ++++++++++++++
 arch/lib/sysfs.c                      |  83 +++++
 arch/lib/tasklet-hrtimer.c            |  57 +++
 arch/lib/tasklet.c                    |  76 ++++
 arch/lib/time.c                       | 116 ++++++
 arch/lib/timer.c                      | 299 ++++++++++++++++
 arch/lib/vmscan.c                     |  26 ++
 arch/lib/workqueue.c                  | 238 ++++++++++++
 fs/proc/proc_sysctl.c                 |  36 +-
 include/linux/slab.h                  |   6 +-
 include/linux/slib_def.h              |  21 ++
 mm/Makefile                           |   1 +
 mm/slab.h                             |   4 +
 mm/slib.c                             | 209 +++++++++++
 tools/testing/libos/.gitignore        |   6 +
 tools/testing/libos/Makefile          |  38 ++
 tools/testing/libos/README            |  15 +
 tools/testing/libos/bisect.sh         |  10 +
 tools/testing/libos/dce-test.sh       |  23 ++
 tools/testing/libos/nuse-test.sh      |  57 +++
 72 files changed, 5573 insertions(+), 18 deletions(-)
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
