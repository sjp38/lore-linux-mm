Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 17FBD6B1A31
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:16:56 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id h68so68568972qke.3
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 02:16:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g5si7016743qka.50.2018.11.19.02.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 02:16:54 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 3/8] kexec: export PG_offline to VMCOREINFO
Date: Mon, 19 Nov 2018 11:16:11 +0100
Message-Id: <20181119101616.8901-4-david@redhat.com>
In-Reply-To: <20181119101616.8901-1-david@redhat.com>
References: <20181119101616.8901-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <dyoung@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Baoquan He <bhe@redhat.com>, Omar Sandoval <osandov@fb.com>, Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>, Lianbo Jiang <lijiang@redhat.com>, Borislav Petkov <bp@alien8.de>, Kazuhito Hagio <k-hagio@ab.jp.nec.com>

Right now, pages inflated as part of a balloon driver will be dumped
by dump tools like makedumpfile. While XEN is able to check in the
crash kernel whether a certain pfn is actuall backed by memory in the
hypervisor (see xen_oldmem_pfn_is_ram) and optimize this case, dumps of
other balloon inflated memory will essentially result in zero pages getting
allocated by the hypervisor and the dump getting filled with this data.

The allocation and reading of zero pages can directly be avoided if a
dumping tool could know which pages only contain stale information not to
be dumped.

We now have PG_offline which can be (and already is by virtio-balloon)
used for marking pages as logically offline. Follow up patches will
make use of this flag also in other balloon implementations.

Let's export PG_offline via PAGE_OFFLINE_MAPCOUNT_VALUE, so
makedumpfile can directly skip pages that are logically offline and the
content therefore stale.

Please note that this is also helpful for a problem we were seeing under
Hyper-V: Dumping logically offline memory (pages kept fake offline while
onlining a section via online_page_callback) would under some condicions
result in a kernel panic when dumping them.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Young <dyoung@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: Omar Sandoval <osandov@fb.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Lianbo Jiang <lijiang@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Kazuhito Hagio <k-hagio@ab.jp.nec.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 kernel/crash_core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/crash_core.c b/kernel/crash_core.c
index 933cb3e45b98..093c9f917ed0 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -464,6 +464,8 @@ static int __init crash_save_vmcoreinfo_init(void)
 	VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);
 #ifdef CONFIG_HUGETLB_PAGE
 	VMCOREINFO_NUMBER(HUGETLB_PAGE_DTOR);
+#define PAGE_OFFLINE_MAPCOUNT_VALUE	(~PG_offline)
+	VMCOREINFO_NUMBER(PAGE_OFFLINE_MAPCOUNT_VALUE);
 #endif
 
 	arch_crash_save_vmcoreinfo();
-- 
2.17.2
