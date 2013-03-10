Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id BF7476B0005
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:29:20 -0500 (EST)
Received: by mail-da0-f43.google.com with SMTP id u36so475752dak.2
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:29:19 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 00/29] Use helper functions to simplify memory intialization code
Date: Sun, 10 Mar 2013 14:26:43 +0800
Message-Id: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, Anatolij Gustschin <agust@denx.de>, Aurelien Jacquiot <a-jacquiot@ti.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Chen Liqin <liqin.chen@sunplusct.com>, Chris Metcalf <cmetcalf@tilera.com>, Chris Zankel <chris@zankel.net>, David Howells <dhowells@redhat.com>, "David S. Miller" <davem@davemloft.net>, Eric Biederman <ebiederm@xmission.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Heiko Carstens <heiko.carstens@de.ibm.com>, Helge Deller <deller@gmx.de>, James Hogan <james.hogan@imgtec.com>, Hirokazu Takata <takata@linux-m32r.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jonas Bonn <jonas@southpole.se>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Lennox Wu <lennox.wu@gmail.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Simek <monstr@monstr.eu>, Michel Lespinasse <walken@google.com>, Mikael Starvik <starvik@axis.com>, Mike Frysinger <vapier@gentoo.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, Ralf Baechle <ralf@linux-mips.org>, Richard Henderson <rth@twiddle.net>, Rik van Riel <riel@redhat.com>, Russell King <linux@arm.linux.org.uk>, Rusty Russell <rusty@rustcorp.com.au>, Sam Ravnborg <sam@ravnborg.org>, Tang Chen <tangchen@cn.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, x86@kernel.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Vineet Gupta <vgupta@synopsys.com>, linux-snps-arc@vger.kernel.org, virtualization@lists.linux-foundation.org

The original goal of this patchset is to fix the bug reported by
https://bugzilla.kernel.org/show_bug.cgi?id=53501
Now it has also been expanded to reduce common code used by memory
initializion.

This is the first part, which applies to v3.9-rc1.

It introduces following common helper functions to simplify
free_initmem() and free_initrd_mem() on different architectures:
adjust_managed_page_count():
	will be used to adjust totalram_pages, totalhigh_pages,
	zone->managed_pages when reserving/unresering a page.
__free_reserved_page():
	free a reserved page into the buddy system without adjusting
	page statistics info
free_reserved_page():
	free a reserved page into the buddy system and adjust page
	statistics info
mark_page_reserved():
	mark a page as reserved and adjust page statistics info
free_reserved_area():
	free a continous ranges of pages by calling free_reserved_page()
free_initmem_default():
	default method to free __init pages.

We have only tested these patchset on x86 platforms, and have done basic
compliation tests using cross-compilers from ftp.kernel.org. That means
some code may not pass compilation on some architectures. So any help
to test this patchset are welcomed!

There are several other parts still under development:
Part2: introduce free_highmem_page() to simplify freeing highmem pages
Part3: refine code to manage totalram_pages, totalhigh_pages and
	zone->managed_pages
Part4: introduce helper functions to simplify mem_init() and remove the
	global variable num_physpages.

Jiang Liu (29):
  mm: introduce common help functions to deal with reserved/managed
    pages
  mm/alpha: use common help functions to free reserved pages
  mm/ARM: use common help functions to free reserved pages
  mm/avr32: use common help functions to free reserved pages
  mm/blackfin: use common help functions to free reserved pages
  mm/c6x: use common help functions to free reserved pages
  mm/cris: use common help functions to free reserved pages
  mm/FRV: use common help functions to free reserved pages
  mm/h8300: use common help functions to free reserved pages
  mm/IA64: use common help functions to free reserved pages
  mm/m32r: use common help functions to free reserved pages
  mm/m68k: use common help functions to free reserved pages
  mm/microblaze: use common help functions to free reserved pages
  mm/MIPS: use common help functions to free reserved pages
  mm/mn10300: use common help functions to free reserved pages
  mm/openrisc: use common help functions to free reserved pages
  mm/parisc: use common help functions to free reserved pages
  mm/ppc: use common help functions to free reserved pages
  mm/s390: use common help functions to free reserved pages
  mm/score: use common help functions to free reserved pages
  mm/SH: use common help functions to free reserved pages
  mm/SPARC: use common help functions to free reserved pages
  mm/um: use common help functions to free reserved pages
  mm/unicore32: use common help functions to free reserved pages
  mm/x86: use common help functions to free reserved pages
  mm/xtensa: use common help functions to free reserved pages
  mm/arc: use common help functions to free reserved pages
  mm/metag: use common help functions to free reserved pages
  mm,kexec: use common help functions to free reserved pages

 arch/alpha/kernel/sys_nautilus.c             |    5 ++-
 arch/alpha/mm/init.c                         |   24 ++-----------
 arch/alpha/mm/numa.c                         |    3 +-
 arch/arc/mm/init.c                           |   23 ++----------
 arch/arm/mm/init.c                           |   48 +++++++++-----------------
 arch/arm64/mm/init.c                         |   26 ++------------
 arch/avr32/mm/init.c                         |   24 ++-----------
 arch/blackfin/mm/init.c                      |   22 ++----------
 arch/c6x/mm/init.c                           |   30 ++--------------
 arch/cris/mm/init.c                          |   16 ++-------
 arch/frv/mm/init.c                           |   34 +++---------------
 arch/h8300/mm/init.c                         |   30 ++--------------
 arch/ia64/mm/init.c                          |   23 +++---------
 arch/m32r/mm/init.c                          |   26 ++------------
 arch/m68k/mm/init.c                          |   24 ++-----------
 arch/metag/mm/init.c                         |   21 ++---------
 arch/microblaze/include/asm/setup.h          |    1 -
 arch/microblaze/mm/init.c                    |   28 ++-------------
 arch/mips/mm/init.c                          |   31 +++++------------
 arch/mips/sgi-ip27/ip27-memory.c             |    4 +--
 arch/mn10300/mm/init.c                       |   23 ++----------
 arch/openrisc/mm/init.c                      |   27 ++-------------
 arch/parisc/mm/init.c                        |   23 ++----------
 arch/powerpc/kernel/crash_dump.c             |    5 +--
 arch/powerpc/kernel/fadump.c                 |    5 +--
 arch/powerpc/kernel/kvm.c                    |    7 +---
 arch/powerpc/mm/mem.c                        |   29 ++--------------
 arch/powerpc/platforms/512x/mpc512x_shared.c |    5 +--
 arch/s390/mm/init.c                          |   35 ++++---------------
 arch/score/mm/init.c                         |   33 +++---------------
 arch/sh/mm/init.c                            |   26 ++------------
 arch/sparc/kernel/leon_smp.c                 |   15 ++------
 arch/sparc/mm/init_32.c                      |   37 ++------------------
 arch/sparc/mm/init_64.c                      |   26 +++-----------
 arch/um/kernel/mem.c                         |   10 +-----
 arch/unicore32/mm/init.c                     |   28 ++-------------
 arch/x86/mm/init.c                           |    5 +--
 arch/x86/mm/init_64.c                        |    5 ++-
 arch/xtensa/mm/init.c                        |   21 ++---------
 include/linux/mm.h                           |   48 ++++++++++++++++++++++++++
 kernel/kexec.c                               |    8 ++---
 mm/page_alloc.c                              |   20 +++++++++++
 42 files changed, 184 insertions(+), 700 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
