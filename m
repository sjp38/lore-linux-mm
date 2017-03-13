Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6526B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:14:21 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u9so15921671wme.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:14:21 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Subject: [RFC PATCH 00/13] Introduce first class virtual address spaces
Date: Mon, 13 Mar 2017 15:14:02 -0700
Message-Id: <20170313221415.9375-1-till.smejkal@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

First class virtual address spaces (also called VAS) are a new functionality of
the Linux kernel allowing address spaces to exist independently of processes.
The general idea behind this feature is described in a paper at ASPLOS16 with
the title 'SpaceJMP: Programming with Multiple Virtual Address Spaces' [1].

This patchset extends the kernel memory management subsystem with a new
type of address spaces (called VAS) which can be created and destroyed
independently of processes by a user in the system. During its lifetime
such a VAS can be attached to processes by the user which allows a process
to have multiple address spaces and thereby multiple, potentially
different, views on the system's main memory. During its execution the
threads belonging to the process are able to switch freely between the
different attached VAS and the process' original AS enabling them to
utilize the different available views on the memory. These multiple virtual
address spaces per process and the possibility to switch between them
freely can be used in multiple interesting ways as also outlined in the
mentioned paper. Some of the many possible applications are for example to
compartmentalize a process for security reasons, to improve the performance
of data-centric applications and to introduce new application models [1].

In addition to the concept of first class virtual address spaces, this
patchset introduces yet another feature called VAS segments. VAS segments
are memory regions which have a fixed size and position in the virtual
address space and can be shared between multiple first class virtual
address spaces. Such shareable memory regions are especially useful for
in-memory pointer-based data structures or other pure in-memory data.

First class virtual address spaces have a significant advantage compared to
forking a process and using inter process communication mechanism, namely
that creating and switching between VAS is significant faster than creating
and switching between processes. As it can be seen in the following table,
measured on an Intel Xeon E5620 CPU with 2.40GHz, creating a VAS is about 7
times faster than forking and switching between VAS is up to 4 times faster
than switching between processes.

            |     VAS     |  processes  |
    -------------------------------------
    switch  |       468ns |      1944ns |
    create  |     20003ns |    150491ns |

Hence, first class virtual address spaces provide a fast mechanism for
applications to utilize multiple virtual address spaces in parallel with a
higher performance than splitting up the application into multiple
independent processes.

Both VAS and VAS segments have another significant advantage when combined
with non-volatile memory. Because of their independent life cycle from
processes and other kernel data structures, they can be used to save
special memory regions or even whole AS into non-volatile memory making it
possible to reuse them across multiple system reboots.

At the current state of the development, first class virtual address spaces
have one limitation, that we haven't been able to solve so far. The feature
allows, that different threads of the same process can execute in different
AS at the same time. This is possible, because the VAS-switch operation
only changes the active mm_struct for the task_struct of the calling
thread. However, when a thread switches into a first class virtual address
space, some parts of its original AS are duplicated into the new one to
allow the thread to continue its execution at its current state.
Accordingly, parts of the processes AS (e.g. the code section, data
section, heap section and stack sections) exist in multiple AS if the
process has a VAS attached to it. Changes to these shared memory regions
are synchronized between the address spaces whenever a thread switches
between two of them. Unfortunately, in some scenarios the kernel is not
able to properly synchronize all these shared memory regions because of
conflicting changes. One such example happens if there are two threads, one
executing in an attached first class virtual address space, the other in
the tasks original address space. If both threads make changes to the heap
section that cause expansion of the underlying vm_area_struct, the kernel
cannot correctly synchronize these changes, because that would cause parts
of the virtual address space to be overwritten with unrelated data. In the
current implementation such conflicts are only detected but not resolved
and result in an error code being returned by the kernel during the VAS
switch operation. Unfortunately, that means for the particular thread that
tried to make the switch, that it cannot do this anymore in the future and
accordingly has to be killed.

This code was developed during an internship at Hewlett Packard Enterprise.

[1] http://impact.crhc.illinois.edu/shared/Papers/ASPLOS16-SpaceJMP.pdf

Till Smejkal (13):
  mm: Add mm_struct argument to 'mmap_region'
  mm: Add mm_struct argument to 'do_mmap' and 'do_mmap_pgoff'
  mm: Rename 'unmap_region' and add mm_struct argument
  mm: Add mm_struct argument to 'get_unmapped_area' and
    'vm_unmapped_area'
  mm: Add mm_struct argument to 'mm_populate' and '__mm_populate'
  mm/mmap: Export 'vma_link' and 'find_vma_links' to mm subsystem
  kernel/fork: Split and export 'mm_alloc' and 'mm_init'
  kernel/fork: Define explicitly which mm_struct to duplicate during
    fork
  mm/memory: Add function to one-to-one duplicate page ranges
  mm: Introduce first class virtual address spaces
  mm/vas: Introduce VAS segments - shareable address space regions
  mm/vas: Add lazy-attach support for first class virtual address spaces
  fs/proc: Add procfs support for first class virtual address spaces

 MAINTAINERS                                  |   10 +
 arch/alpha/kernel/osf_sys.c                  |   19 +-
 arch/arc/mm/mmap.c                           |    8 +-
 arch/arm/kernel/process.c                    |    2 +-
 arch/arm/mach-rpc/ecard.c                    |    2 +-
 arch/arm/mm/mmap.c                           |   19 +-
 arch/arm64/kernel/vdso.c                     |    2 +-
 arch/blackfin/include/asm/pgtable.h          |    3 +-
 arch/blackfin/kernel/sys_bfin.c              |    5 +-
 arch/frv/mm/elf-fdpic.c                      |   11 +-
 arch/hexagon/kernel/vdso.c                   |    2 +-
 arch/ia64/kernel/perfmon.c                   |    3 +-
 arch/ia64/kernel/sys_ia64.c                  |    6 +-
 arch/ia64/mm/hugetlbpage.c                   |    7 +-
 arch/metag/mm/hugetlbpage.c                  |   11 +-
 arch/mips/kernel/vdso.c                      |    4 +-
 arch/mips/mm/mmap.c                          |   27 +-
 arch/parisc/kernel/sys_parisc.c              |   19 +-
 arch/parisc/mm/hugetlbpage.c                 |    7 +-
 arch/powerpc/include/asm/book3s/64/hugetlb.h |    6 +-
 arch/powerpc/include/asm/page_64.h           |    3 +-
 arch/powerpc/kernel/vdso.c                   |    2 +-
 arch/powerpc/mm/hugetlbpage-radix.c          |    9 +-
 arch/powerpc/mm/hugetlbpage.c                |    9 +-
 arch/powerpc/mm/mmap.c                       |   17 +-
 arch/powerpc/mm/slice.c                      |   25 +-
 arch/s390/kernel/vdso.c                      |    3 +-
 arch/s390/mm/mmap.c                          |   42 +-
 arch/sh/kernel/vsyscall/vsyscall.c           |    2 +-
 arch/sh/mm/mmap.c                            |   19 +-
 arch/sparc/include/asm/pgtable_64.h          |    4 +-
 arch/sparc/kernel/sys_sparc_32.c             |    6 +-
 arch/sparc/kernel/sys_sparc_64.c             |   31 +-
 arch/sparc/mm/hugetlbpage.c                  |   26 +-
 arch/tile/kernel/vdso.c                      |    2 +-
 arch/tile/mm/elf.c                           |    2 +-
 arch/tile/mm/hugetlbpage.c                   |   26 +-
 arch/x86/entry/syscalls/syscall_32.tbl       |   16 +
 arch/x86/entry/syscalls/syscall_64.tbl       |   16 +
 arch/x86/entry/vdso/vma.c                    |    2 +-
 arch/x86/kernel/sys_x86_64.c                 |   19 +-
 arch/x86/mm/hugetlbpage.c                    |   26 +-
 arch/x86/mm/mpx.c                            |    6 +-
 arch/xtensa/kernel/syscall.c                 |    7 +-
 drivers/char/mem.c                           |   15 +-
 drivers/dax/dax.c                            |   10 +-
 drivers/media/usb/uvc/uvc_v4l2.c             |    6 +-
 drivers/media/v4l2-core/v4l2-dev.c           |    8 +-
 drivers/media/v4l2-core/videobuf2-v4l2.c     |    5 +-
 drivers/mtd/mtdchar.c                        |    3 +-
 drivers/usb/gadget/function/uvc_v4l2.c       |    3 +-
 fs/aio.c                                     |    4 +-
 fs/exec.c                                    |    5 +-
 fs/hugetlbfs/inode.c                         |    8 +-
 fs/proc/base.c                               |  528 ++++
 fs/proc/inode.c                              |   11 +-
 fs/proc/internal.h                           |    1 +
 fs/ramfs/file-mmu.c                          |    5 +-
 fs/ramfs/file-nommu.c                        |   10 +-
 fs/romfs/mmap-nommu.c                        |    3 +-
 include/linux/fs.h                           |    2 +-
 include/linux/huge_mm.h                      |   12 +-
 include/linux/hugetlb.h                      |   10 +-
 include/linux/mm.h                           |   53 +-
 include/linux/mm_types.h                     |   16 +-
 include/linux/sched.h                        |   34 +-
 include/linux/shmem_fs.h                     |    5 +-
 include/linux/syscalls.h                     |   21 +
 include/linux/vas.h                          |  322 +++
 include/linux/vas_types.h                    |  173 ++
 include/media/v4l2-dev.h                     |    3 +-
 include/media/videobuf2-v4l2.h               |    5 +-
 include/uapi/asm-generic/unistd.h            |   34 +-
 include/uapi/linux/Kbuild                    |    1 +
 include/uapi/linux/vas.h                     |   28 +
 init/main.c                                  |    2 +
 ipc/shm.c                                    |   22 +-
 kernel/events/uprobes.c                      |    2 +-
 kernel/exit.c                                |    2 +
 kernel/fork.c                                |   99 +-
 kernel/sys_ni.c                              |   18 +
 mm/Kconfig                                   |   47 +
 mm/Makefile                                  |    1 +
 mm/gup.c                                     |    4 +-
 mm/huge_memory.c                             |   83 +-
 mm/hugetlb.c                                 |  205 +-
 mm/internal.h                                |   19 +
 mm/memory.c                                  |  469 +++-
 mm/mlock.c                                   |   21 +-
 mm/mmap.c                                    |  124 +-
 mm/mremap.c                                  |   13 +-
 mm/nommu.c                                   |   17 +-
 mm/shmem.c                                   |   14 +-
 mm/util.c                                    |    4 +-
 mm/vas.c                                     | 3466 ++++++++++++++++++++++++++
 sound/core/pcm_native.c                      |    3 +-
 96 files changed, 5927 insertions(+), 545 deletions(-)
 create mode 100644 include/linux/vas.h
 create mode 100644 include/linux/vas_types.h
 create mode 100644 include/uapi/linux/vas.h
 create mode 100644 mm/vas.c

-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
