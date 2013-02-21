Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id D11776B0011
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 12:26:40 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id hz10so4880390pad.7
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 09:26:40 -0800 (PST)
Message-ID: <512658AA.5060806@gmail.com>
Date: Fri, 22 Feb 2013 01:26:02 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: let /proc/meminfo report physical memory installed
 as "MemTotal"
References: <alpine.DEB.2.02.1302191326150.6322@chino.kir.corp.google.com> <1361381245-14664-1-git-send-email-jiang.liu@huawei.com> <20130220144917.7d289ef0.akpm@linux-foundation.org>
In-Reply-To: <20130220144917.7d289ef0.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, sworddragon2@aol.com, Jiang Liu <jiang.liu@huawei.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On 02/21/2013 06:49 AM, Andrew Morton wrote:
> On Thu, 21 Feb 2013 01:27:25 +0800
> Jiang Liu <liuj97@gmail.com> wrote:
> 
>> As reported by https://bugzilla.kernel.org/show_bug.cgi?id=53501,
>> "MemTotal" from /proc/meminfo means memory pages managed by the buddy
>> system (managed_pages), but "MemTotal" from /sys/.../node/nodex/meminfo
>> means phsical pages present (present_pages) within the NUMA node.
>> There's a difference between managed_pages and present_pages due to
>> bootmem allocator and reserved pages.
>>
>> So change /proc/meminfo to report physical memory installed as
>> "MemTotal", which is
>> MemTotal = sum(pgdat->present_pages)
> 
> Documentation/filesystems/proc.txt says
> 
>     MemTotal: Total usable ram (i.e. physical ram minus a few reserved
>               bits and the kernel binary code)
> 
> And arguably, that is more useful than "total physical memory".
> 
> Presumably the per-node MemTotals are including kernel memory and
> reserved memory.  Maybe they should be fixed instead (sounds hard).
Hi Andrew,
	It's really hard, but I think it deserve it because have reduced
about 460 lines of code when fixing this bug. So how about following
patchset?
	The first 27 patches introduces some help functions to simplify
free_initmem() and free_initrd_mem() for most arches.
	The 28th patch increases zone->managed_pages when freeing reserved
pages.
	The 29th patch change /sys/.../nodex/meminfo to report "available
pages within the node" as MemTatoal.
	Regards!
	Gerry

Jiang Liu (29):
  mm: introduce free_reserved_mem/page() to reduce duplicated code
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
  mm,kexec: use common help functions to free reserved pages
  mm: increase zone->managed_pages when freeing reserved pages
  mm: report available pages as "MemTotal" for each NUMA node

 arch/alpha/kernel/sys_nautilus.c             |    5 ++-
 arch/alpha/mm/init.c                         |   21 ++----------
 arch/arm/mm/init.c                           |   43 ++++++++++--------------
 arch/arm64/mm/init.c                         |   26 ++-------------
 arch/avr32/mm/init.c                         |   24 ++------------
 arch/blackfin/mm/init.c                      |   20 ++----------
 arch/c6x/mm/init.c                           |   30 ++---------------
 arch/cris/mm/init.c                          |   12 +------
 arch/frv/mm/init.c                           |   26 ++-------------
 arch/h8300/mm/init.c                         |   28 ++--------------
 arch/ia64/mm/init.c                          |   23 +++----------
 arch/m32r/mm/init.c                          |   21 ++----------
 arch/m68k/mm/init.c                          |   24 ++------------
 arch/microblaze/include/asm/setup.h          |    1 -
 arch/microblaze/mm/init.c                    |   28 ++--------------
 arch/mips/mm/init.c                          |   13 ++------
 arch/mn10300/mm/init.c                       |   23 ++-----------
 arch/openrisc/mm/init.c                      |   23 ++-----------
 arch/parisc/mm/init.c                        |   23 ++-----------
 arch/powerpc/kernel/crash_dump.c             |    5 +--
 arch/powerpc/kernel/fadump.c                 |    5 +--
 arch/powerpc/kernel/kvm.c                    |    7 +---
 arch/powerpc/mm/mem.c                        |   29 ++---------------
 arch/powerpc/platforms/512x/mpc512x_shared.c |    5 +--
 arch/s390/mm/init.c                          |   23 ++-----------
 arch/score/mm/init.c                         |   25 ++------------
 arch/sh/mm/init.c                            |   22 ++-----------
 arch/sparc/kernel/leon_smp.c                 |   15 ++-------
 arch/sparc/mm/init_32.c                      |   40 ++++-------------------
 arch/sparc/mm/init_64.c                      |   20 ++----------
 arch/tile/mm/init.c                          |    1 +
 arch/um/kernel/mem.c                         |   10 +-----
 arch/unicore32/mm/init.c                     |   26 ++-------------
 arch/x86/mm/init.c                           |    5 +--
 arch/xtensa/mm/init.c                        |   21 ++----------
 include/linux/mm.h                           |   45 ++++++++++++++++++++++++++
 kernel/kexec.c                               |    8 ++---
 mm/page_alloc.c                              |    8 ++++-
 38 files changed, 139 insertions(+), 595 deletions(-)


> 
> Or maybe we just leave everything as-is and document it carefully.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
