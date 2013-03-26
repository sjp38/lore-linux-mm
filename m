Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 10B996B00EC
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 11:56:42 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so3102164pde.17
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 08:56:41 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v3, part4 00/39] Simplify mem_init() implementations and kill num_physpages
Date: Tue, 26 Mar 2013 23:54:19 +0800
Message-Id: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Hi all,
	Sorry for my mistake that my previous patch series has been screwed up.
So I regenerate a third version and also set up a git tree at:
	git://github.com/jiangliu/linux.git mem_init
	Any help to review and test are welcomed!

The original goal of this patchset is to fix the bug reported by
https://bugzilla.kernel.org/show_bug.cgi?id=53501
Now it has also been expanded to reduce common code used by memory
initializion.

This is the last part, previous three patch sets could be accessed at:
http://marc.info/?l=linux-mm&m=136289696323825&w=2
http://marc.info/?l=linux-mm&m=136290291524901&w=2
http://marc.info/?l=linux-mm&m=136345342831592&w=2

This patchset applies to
https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.8

Patch 1-7: 
	1) add comments for global variables exported by vmlinux.lds
	2) normalize global variables exported by vmlinux.lds
Patch 8:
	Introduce helper functions mem_init_print_info() and
	get_num_physpages()
Patch 9:
	Avoid using num_physpages at runtime
Patch 10-38:
	1) Simplify mem_init() by using mem_init_print_info()
	2) Prepare fore kill global variable num_physpages
Patch 39:
	Kill global variable num_physpages

With all patches applied, mem_init(), free_initmem(), free_initrd_mem()
could be as simple as below. This patch series has reduced about 1.2K
lines of code in total.

#ifndef CONFIG_DISCONTIGMEM
void __init
mem_init(void)
{
	max_mapnr = max_low_pfn;
	free_all_bootmem();
	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);

	mem_init_print_info(NULL);
}
#endif /* CONFIG_DISCONTIGMEM */

void
free_initmem(void)
{
	free_initmem_default(-1);
}

#ifdef CONFIG_BLK_DEV_INITRD
void
free_initrd_mem(unsigned long start, unsigned long end)
{
	free_reserved_area(start, end, -1, "initrd");
}
#endif

Due to hardware resource limitations, I have only tested this on x86_64.
And the messages reported are:
Previous log message:
Memory: 7745676k/8910848k available (6934k kernel code, 836024k absent, 329148k reserved, 6343k data, 1012k init)
Current log message:
Memory: 7744624K/8074824K available (6969K kernel code, 1011K data, 2828K rodata, 1016K init, 9640K bss, 330200K reserved)

Any help to review or test these patch series are welcomed!

Regards!
Gerry

Jiang Liu (39):
  vmlinux.lds: add comments for global variables and clean up useless
    declarations
  avr32: normalize global variables exported by vmlinux.lds
  c6x: normalize global variables exported by vmlinux.lds
  h8300: normalize global variables exported by vmlinux.lds
  score: normalize global variables exported by vmlinux.lds
  tile: normalize global variables exported by vmlinux.lds
  UML: normalize global variables exported by vmlinux.lds
  mm: introduce helper function mem_init_print_info() to simplify
    mem_init()
  mm: use totalram_pages instead of num_physpages at runtime
  mm/alpha: prepare for removing num_physpages and simplify mem_init()
  mm/ARM: prepare for removing num_physpages and simplify mem_init()
  mm/ARM64: prepare for removing num_physpages and simplify mem_init()
  mm/AVR32: prepare for removing num_physpages and simplify mem_init()
  mm/blackfin: prepare for removing num_physpages and simplify
    mem_init()
  mm/c6x: prepare for removing num_physpages and simplify mem_init()
  mm/cris: prepare for removing num_physpages and simplify mem_init()
  mm/frv: prepare for removing num_physpages and simplify mem_init()
  mm/h8300: prepare for removing num_physpages and simplify mem_init()
  mm/hexagon: prepare for removing num_physpages and simplify
    mem_init()
  mm/IA64: prepare for removing num_physpages and simplify mem_init()
  mm/m32r: prepare for removing num_physpages and simplify mem_init()
  mm/m68k: prepare for removing num_physpages and simplify mem_init()
  mm/microblaze: prepare for removing num_physpages and simplify
    mem_init()
  mm/MIPS: prepare for removing num_physpages and simplify mem_init()
  mm/mn10300: prepare for removing num_physpages and simplify
    mem_init()
  mm/openrisc: prepare for removing num_physpages and simplify
    mem_init()
  mm/PARISC: prepare for removing num_physpages and simplify mem_init()
  mm/ppc: prepare for removing num_physpages and simplify mem_init()
  mm/s390: prepare for removing num_physpages and simplify mem_init()
  mm/score: prepare for removing num_physpages and simplify mem_init()
  mm/SH: prepare for removing num_physpages and simplify mem_init()
  mm/SPARC: prepare for removing num_physpages and simplify mem_init()
  mm/tile: prepare for removing num_physpages and simplify mem_init()
  mm/um: prepare for removing num_physpages and simplify mem_init()
  mm/unicore32: prepare for removing num_physpages and simplify
    mem_init()
  mm/x86: prepare for removing num_physpages and simplify mem_init()
  mm/xtensa: prepare for removing num_physpages and simplify mem_init()
  mm/hotplug: prepare for removing num_physpages
  mm: kill global variable num_physpages

 arch/alpha/mm/init.c              |   32 ++-------------------
 arch/alpha/mm/numa.c              |   34 ++++------------------
 arch/arm/mm/init.c                |   47 ++----------------------------
 arch/arm64/mm/init.c              |   48 ++-----------------------------
 arch/avr32/kernel/setup.c         |    2 +-
 arch/avr32/kernel/vmlinux.lds.S   |    4 +--
 arch/avr32/mm/init.c              |   29 +++----------------
 arch/blackfin/mm/init.c           |   38 ++++---------------------
 arch/c6x/kernel/vmlinux.lds.S     |    4 +--
 arch/c6x/mm/init.c                |   11 +------
 arch/cris/mm/init.c               |   33 ++-------------------
 arch/frv/kernel/setup.c           |   14 ++++-----
 arch/frv/mm/init.c                |   49 +++++++++----------------------
 arch/h8300/boot/compressed/misc.c |    1 -
 arch/h8300/kernel/vmlinux.lds.S   |    2 ++
 arch/h8300/mm/init.c              |   34 ++++++----------------
 arch/hexagon/mm/init.c            |    3 +-
 arch/ia64/mm/contig.c             |   11 -------
 arch/ia64/mm/discontig.c          |    3 --
 arch/ia64/mm/init.c               |   27 +-----------------
 arch/m32r/mm/discontig.c          |    6 +---
 arch/m32r/mm/init.c               |   49 ++++---------------------------
 arch/m68k/mm/init.c               |   31 ++------------------
 arch/microblaze/mm/init.c         |   51 ++++-----------------------------
 arch/mips/mm/init.c               |   57 ++++++++++++-------------------------
 arch/mips/pci/pci-lantiq.c        |    2 +-
 arch/mips/sgi-ip27/ip27-memory.c  |   21 ++------------
 arch/mn10300/mm/init.c            |   26 ++---------------
 arch/openrisc/mm/init.c           |   44 +++-------------------------
 arch/parisc/mm/init.c             |   46 ++----------------------------
 arch/powerpc/mm/mem.c             |   56 ++++++++----------------------------
 arch/s390/mm/init.c               |   17 ++---------
 arch/score/kernel/vmlinux.lds.S   |    1 +
 arch/score/mm/init.c              |   26 ++---------------
 arch/sh/mm/init.c                 |   25 +++-------------
 arch/sparc/kernel/leon_smp.c      |    3 --
 arch/sparc/mm/init_32.c           |   33 ++-------------------
 arch/sparc/mm/init_64.c           |   27 ++----------------
 arch/tile/include/asm/sections.h  |    2 +-
 arch/tile/kernel/setup.c          |   20 ++++++-------
 arch/tile/kernel/vmlinux.lds.S    |    4 ++-
 arch/tile/mm/init.c               |   17 ++---------
 arch/um/include/asm/common.lds.S  |    1 -
 arch/um/kernel/dyn.lds.S          |    6 ++--
 arch/um/kernel/mem.c              |    4 +--
 arch/um/kernel/uml.lds.S          |    7 +++--
 arch/unicore32/mm/init.c          |   49 ++-----------------------------
 arch/x86/kernel/cpu/amd.c         |    2 +-
 arch/x86/kernel/setup.c           |    2 --
 arch/x86/mm/init_32.c             |   30 ++-----------------
 arch/x86/mm/init_64.c             |   20 +------------
 arch/x86/mm/numa_32.c             |    2 --
 arch/xtensa/mm/init.c             |   27 ++----------------
 fs/fuse/inode.c                   |    2 +-
 include/asm-generic/sections.h    |   21 +++++++++++++-
 include/linux/mm.h                |   13 ++++++++-
 kernel/power/snapshot.c           |    4 +--
 mm/memory.c                       |    2 --
 mm/memory_hotplug.c               |    4 ---
 mm/nommu.c                        |    2 --
 mm/page_alloc.c                   |   52 +++++++++++++++++++++++++++++++++
 net/ipv4/inet_fragment.c          |    2 +-
 62 files changed, 256 insertions(+), 986 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
