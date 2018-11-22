Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9A326B2AF0
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:06:40 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w185so8935842qka.9
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:06:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q10si25935081qvh.99.2018.11.22.02.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 02:06:39 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 0/8] mm/kdump: allow to exclude pages that are logically offline
Date: Thu, 22 Nov 2018 11:06:19 +0100
Message-Id: <20181122100627.5189-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, David Hildenbrand <david@redhat.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Baoquan He <bhe@redhat.com>, Borislav Petkov <bp@alien8.de>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Christian Hansen <chansen3@cisco.com>, Dave Young <dyoung@redhat.com>, David Rientjes <rientjes@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haiyang Zhang <haiyangz@microsoft.com>, Jonathan Corbet <corbet@lwn.net>, Juergen Gross <jgross@suse.com>, Julien Freche <jfreche@vmware.com>, Kairui Song <kasong@redhat.com>, Kazuhito Hagio <k-hagio@ab.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <len.brown@intel.com>, Lianbo Jiang <lijiang@redhat.com>, Matthew Wilcox <willy@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Miles Chen <miles.chen@mediatek.com>, Nadav Amit <namit@vmware.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Omar Sandoval <osandov@fb.com>, Pankaj gupta <pagupta@redhat.com>, Pavel Machek <pavel@ucw.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Vitaly Kuznetsov <vkuznets@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Xavier Deguillard <xdeguillard@vmware.com>

Right now, pages inflated as part of a balloon driver will be dumped
by dump tools like makedumpfile. While XEN is able to check in the
crash kernel whether a certain pfn is actually backed by memory in the
hypervisor (see xen_oldmem_pfn_is_ram) and optimize this case, dumps of
virtio-balloon, hv-balloon and VMWare balloon inflated memory will
essentially result in zero pages getting allocated by the hypervisor and
the dump getting filled with this data.

The allocation and reading of zero pages can directly be avoided if a
dumping tool could know which pages only contain stale information not to
be dumped.

Also for XEN, calling into the kernel and asking the hypervisor if a
pfn is backed can be avoided if the duming tool would skip such pages
right from the beginning.

Dumping tools have no idea whether a given page is part of a balloon driver
and shall not be dumped. Esp. PG_reserved cannot be used for that purpose
as all memory allocated during early boot is also PG_reserved, see
discussion at [1]. So some other way of indication is required and a new
page flag is frowned upon.

We have PG_balloon (MAPCOUNT value), which is essentially unused now. I
suggest renaming it to something more generic (PG_offline) to mark pages as
logically offline. This flag can than e.g. also be used by virtio-mem in
the future to mark subsections as offline. Or by other code that wants to
put pages logically offline (e.g. later maybe poisoned pages that shall
no longer be used).

This series converts PG_balloon to PG_offline, allows dumping tools to
query the value to detect such pages and marks pages in the hv-balloon
and XEN balloon properly as PG_offline. Note that virtio-balloon already
set pages to PG_balloon (and now PG_offline).

Please note that this is also helpful for a problem we were seeing under
Hyper-V: Dumping logically offline memory (pages kept fake offline while
onlining a section via online_page_callback) would under some condicions
result in a kernel panic when dumping them.

As I don't have access to neither XEN nor Hyper-V nor VMWare installations,
this was only tested with the virtio-balloon and pages were properly
skipped when dumping. I'll also attach the makedumpfile patch to this
series.

[1] https://lkml.org/lkml/2018/7/20/566

v1 -> v2:
- "kexec: export PG_offline to VMCOREINFO"
-- Add description why it is exported as a macro
- "vmw_balloon: mark inflated pages PG_offline"
-- Use helper function + adapt comments
- "PM / Hibernate: exclude all PageOffline() pages"
-- Perform the check separate from swsusp checks.
- Added RBs/ACKs


David Hildenbrand (8):
  mm: balloon: update comment about isolation/migration/compaction
  mm: convert PG_balloon to PG_offline
  kexec: export PG_offline to VMCOREINFO
  xen/balloon: mark inflated pages PG_offline
  hv_balloon: mark inflated pages PG_offline
  vmw_balloon: mark inflated pages PG_offline
  PM / Hibernate: use pfn_to_online_page()
  PM / Hibernate: exclude all PageOffline() pages

 Documentation/admin-guide/mm/pagemap.rst |  9 ++++---
 drivers/hv/hv_balloon.c                  | 14 ++++++++--
 drivers/misc/vmw_balloon.c               | 32 ++++++++++++++++++++++
 drivers/xen/balloon.c                    |  3 +++
 fs/proc/page.c                           |  4 +--
 include/linux/balloon_compaction.h       | 34 +++++++++---------------
 include/linux/page-flags.h               | 11 +++++---
 include/uapi/linux/kernel-page-flags.h   |  2 +-
 kernel/crash_core.c                      |  2 ++
 kernel/power/snapshot.c                  | 17 +++++++-----
 tools/vm/page-types.c                    |  2 +-
 11 files changed, 90 insertions(+), 40 deletions(-)

-- 
2.17.2
