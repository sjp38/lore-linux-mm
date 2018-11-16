Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 062786B0AB6
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 13:23:37 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d196so53132390qkb.6
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 10:23:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w90si1517650qvw.209.2018.11.16.10.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 10:23:36 -0800 (PST)
Subject: Re: [PATCH RFC 0/6] mm/kdump: allow to exclude pages that are
 logically offline
References: <20181114211704.6381-1-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <a0b995a2-d78e-8413-f232-9a82b4d4f5b5@redhat.com>
Date: Fri, 16 Nov 2018 19:23:20 +0100
MIME-Version: 1.0
In-Reply-To: <20181114211704.6381-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Baoquan He <bhe@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Christian Hansen <chansen3@cisco.com>, Dave Young <dyoung@redhat.com>, David Rientjes <rientjes@google.com>, Haiyang Zhang <haiyangz@microsoft.com>, Jonathan Corbet <corbet@lwn.net>, Juergen Gross <jgross@suse.com>, Kairui Song <kasong@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <len.brown@intel.com>, Matthew Wilcox <willy@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Miles Chen <miles.chen@mediatek.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Omar Sandoval <osandov@fb.com>, Pavel Machek <pavel@ucw.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Vitaly Kuznetsov <vkuznets@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On 14.11.18 22:16, David Hildenbrand wrote:
> Right now, pages inflated as part of a balloon driver will be dumped
> by dump tools like makedumpfile. While XEN is able to check in the
> crash kernel whether a certain pfn is actuall backed by memory in the
> hypervisor (see xen_oldmem_pfn_is_ram) and optimize this case, dumps of
> virtio-balloon and hv-balloon inflated memory will essentially result in
> zero pages getting allocated by the hypervisor and the dump getting
> filled with this data.
> 
> The allocation and reading of zero pages can directly be avoided if a
> dumping tool could know which pages only contain stale information not to
> be dumped.
> 
> Also for XEN, calling into the kernel and asking the hypervisor if a
> pfn is backed can be avoided if the duming tool would skip such pages
> right from the beginning.
> 
> Dumping tools have no idea whether a given page is part of a balloon driver
> and shall not be dumped. Esp. PG_reserved cannot be used for that purpose
> as all memory allocated during early boot is also PG_reserved, see
> discussion at [1]. So some other way of indication is required and a new
> page flag is frowned upon.
> 
> We have PG_balloon (MAPCOUNT value), which is essentially unused now. I
> suggest renaming it to something more generic (PG_offline) to mark pages as
> logically offline. This flag can than e.g. also be used by virtio-mem in
> the future to mark subsections as offline. Or by other code that wants to
> put pages logically offline (e.g. later maybe poisoned pages that shall
> no longer be used).
> 
> This series converts PG_balloon to PG_offline, allows dumping tools to
> query the value to detect such pages and marks pages in the hv-balloon
> and XEN balloon properly as PG_offline. Note that virtio-balloon already
> set pages to PG_balloon (and now PG_offline).
> 
> Please note that this is also helpful for a problem we were seeing under
> Hyper-V: Dumping logically offline memory (pages kept fake offline while
> onlining a section via online_page_callback) would under some condicions
> result in a kernel panic when dumping them.
> 
> As I don't have access to neither XEN nor Hyper-V installation, this was
> not tested yet (and a makedumpfile change will be required to skip
> dumping these pages).
> 
> [1] https://lkml.org/lkml/2018/7/20/566
> 
> David Hildenbrand (6):
>   mm: balloon: update comment about isolation/migration/compaction
>   mm: convert PG_balloon to PG_offline
>   kexec: export PG_offline to VMCOREINFO
>   xen/balloon: mark inflated pages PG_offline
>   hv_balloon: mark inflated pages PG_offline
>   PM / Hibernate: exclude all PageOffline() pages
> 
>  Documentation/admin-guide/mm/pagemap.rst |  6 +++++
>  drivers/hv/hv_balloon.c                  | 14 ++++++++--
>  drivers/xen/balloon.c                    |  3 +++
>  fs/proc/page.c                           |  4 +--
>  include/linux/balloon_compaction.h       | 34 +++++++++---------------
>  include/linux/page-flags.h               | 11 +++++---
>  include/uapi/linux/kernel-page-flags.h   |  1 +
>  kernel/crash_core.c                      |  2 ++
>  kernel/power/snapshot.c                  |  5 +++-
>  tools/vm/page-types.c                    |  1 +
>  10 files changed, 51 insertions(+), 30 deletions(-)
> 

I just did a test with virtio-balloon (and a very simple makedumpfile
patch which I can supply on demand).

1. Guest with 8GB. Inflate balloon to 4GB via
 sudo virsh setmem f29 --size 4096M --live

2. Trigger a kernel panic in the guest
    echo 1 > /proc/sys/kernel/sysrq
    echo c > /proc/sysrq-trigger

Original pages  : 0x00000000001e1da8
  Excluded pages   : 0x00000000001c9221
    Pages filled with zero  : 0x00000000000050b0
    Non-private cache pages : 0x0000000000046547
    Private cache pages     : 0x0000000000002165
    User process data pages : 0x00000000000048cf
    Free pages              : 0x00000000000771f6
    Hwpoison pages          : 0x0000000000000000
    Offline pages           : 0x0000000000100000
  Remaining pages  : 0x0000000000018b87
  (The number of pages is reduced to 5%.)
Memory Hole     : 0x000000000009e258
--------------------------------------------------
Total pages     : 0x0000000000280000

(Offline patches matches the 4GB)

-- 

Thanks,

David / dhildenb
