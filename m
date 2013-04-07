Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 102466B0005
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 21:34:26 -0400 (EDT)
Received: by mail-ia0-f176.google.com with SMTP id i1so4191875iaa.35
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 18:34:26 -0700 (PDT)
Message-ID: <5160CD19.8070705@gmail.com>
Date: Sun, 07 Apr 2013 09:34:17 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4, part3 00/15] accurately calculate memory statisitic
 information
References: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Jiang,
On 04/06/2013 09:54 PM, Jiang Liu wrote:
> The original goal of this patchset is to fix the bug reported by
> https://bugzilla.kernel.org/show_bug.cgi?id=53501
> Now it has also been expanded to reduce common code used by memory
> initializion.
>
> This is the third part, previous two patch sets could be accessed at:
> http://marc.info/?l=linux-mm&m=136289696323825&w=2
> http://marc.info/?l=linux-mm&m=136290291524901&w=2
>
> This patchset applies to
> git://git.cmpxchg.org/linux-mmotm.git fc374c1f9d7bdcfb851b15b86e58ac5e1f645e32
> which is based on mmotm-2013-03-26-15-09.
>
> V2->V4:
> 1) rebase to git://git.cmpxchg.org/linux-mmotm.git
> 2) fix some build warnings and other minor bugs of previous patches
>
> We have only tested these patchset on x86 platforms, and have done basic
> compliation tests using cross-compilers from ftp.kernel.org. That means
> some code may not pass compilation on some architectures. So any help
> to test this patchset are welcomed!
>
> Patch 1-7:
> 	Bugfixes and more work for part1 and part2
> Patch 8-9:
> 	Fix typo and minor bugs in mm core
> Patch 10-14:
> 	Enhance the way to manage totalram_pages, totalhigh_pages and
> 	zone->managed_pages.
> Patch 15:
> 	Report available pages within the node as "MemTotal" for sysfs
> 	interface /sys/.../node/nodex/meminfo
>
> Jiang Liu (15):
>    mm: fix build warnings caused by free_reserved_area()
>    mm: enhance free_reserved_area() to support poisoning memory with
>      zero
>    mm/ARM64: kill poison_init_mem()
>    mm/x86: use free_reserved_area() to simplify code
>    mm/tile: use common help functions to free reserved pages
>    mm, powertv: use free_reserved_area() to simplify code
>    mm, acornfb: use free_reserved_area() to simplify code
>    mm: fix some trivial typos in comments
>    mm: use managed_pages to calculate default zonelist order
>    mm: accurately calculate zone->managed_pages for highmem zones
>    mm: use a dedicated lock to protect totalram_pages and
>      zone->managed_pages
>    mm: make __free_pages_bootmem() only available at boot time
>    mm: correctly update zone->mamaged_pages
>    mm: concentrate modification of totalram_pages into the mm core
>    mm: report available pages as "MemTotal" for each NUMA node

What I interested in is how you test different platform? I don't think 
you can have all the physical platform.

>
>   arch/alpha/kernel/sys_nautilus.c      |    2 +-
>   arch/alpha/mm/init.c                  |    6 ++--
>   arch/alpha/mm/numa.c                  |    2 +-
>   arch/arc/mm/init.c                    |    2 +-
>   arch/arm/mm/init.c                    |   13 ++++----
>   arch/arm64/mm/init.c                  |   15 ++-------
>   arch/avr32/mm/init.c                  |    6 ++--
>   arch/blackfin/mm/init.c               |    6 ++--
>   arch/c6x/mm/init.c                    |    6 ++--
>   arch/cris/mm/init.c                   |    4 +--
>   arch/frv/mm/init.c                    |    6 ++--
>   arch/h8300/mm/init.c                  |    6 ++--
>   arch/hexagon/mm/init.c                |    3 +-
>   arch/ia64/mm/init.c                   |    4 +--
>   arch/m32r/mm/init.c                   |    6 ++--
>   arch/m68k/mm/init.c                   |    8 ++---
>   arch/metag/mm/init.c                  |   11 ++++---
>   arch/microblaze/mm/init.c             |    6 ++--
>   arch/mips/mm/init.c                   |    2 +-
>   arch/mips/powertv/asic/asic_devices.c |   13 ++------
>   arch/mips/sgi-ip27/ip27-memory.c      |    2 +-
>   arch/mn10300/mm/init.c                |    2 +-
>   arch/openrisc/mm/init.c               |    6 ++--
>   arch/parisc/mm/init.c                 |    8 ++---
>   arch/powerpc/kernel/kvm.c             |    2 +-
>   arch/powerpc/mm/mem.c                 |    7 ++---
>   arch/s390/mm/init.c                   |    4 +--
>   arch/score/mm/init.c                  |    2 +-
>   arch/sh/mm/init.c                     |    6 ++--
>   arch/sparc/mm/init_32.c               |    3 +-
>   arch/sparc/mm/init_64.c               |    2 +-
>   arch/tile/mm/init.c                   |    9 ++----
>   arch/um/kernel/mem.c                  |    4 +--
>   arch/unicore32/mm/init.c              |    6 ++--
>   arch/x86/mm/highmem_32.c              |    6 ++++
>   arch/x86/mm/init.c                    |   14 ++-------
>   arch/x86/mm/init_32.c                 |    2 +-
>   arch/x86/mm/init_64.c                 |   25 +++------------
>   arch/xtensa/mm/init.c                 |    6 ++--
>   drivers/video/acornfb.c               |   28 ++---------------
>   drivers/virtio/virtio_balloon.c       |    8 +++--
>   drivers/xen/balloon.c                 |   23 +++-----------
>   include/linux/bootmem.h               |    1 +
>   include/linux/mm.h                    |   17 +++++-----
>   include/linux/mmzone.h                |   14 ++++++---
>   mm/bootmem.c                          |   41 +++++++++++++++---------
>   mm/hugetlb.c                          |    2 +-
>   mm/memory_hotplug.c                   |   33 ++++----------------
>   mm/nobootmem.c                        |   35 ++++++++++++---------
>   mm/page_alloc.c                       |   55 +++++++++++++++++++++------------
>   50 files changed, 222 insertions(+), 278 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
