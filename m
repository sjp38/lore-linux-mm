Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id E76EF6B0038
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 22:05:57 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id c1so4065748igq.15
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 19:05:57 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id mv1si10321255icc.47.2014.07.30.19.05.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 19:05:57 -0700 (PDT)
Received: by mail-ie0-f170.google.com with SMTP id rl12so2782286iec.29
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 19:05:57 -0700 (PDT)
Date: Wed, 30 Jul 2014 19:05:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch for-3.16] kexec: fix build error when hugetlbfs is disabled
In-Reply-To: <alpine.DEB.2.02.1407301901250.12482@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1407301905110.12482@chino.kir.corp.google.com>
References: <53d98399.wRC4T5IRh+/QWqVO%fengguang.wu@intel.com> <alpine.DEB.2.02.1407301727300.12181@chino.kir.corp.google.com> <CAOesGMgFeg_HNJMfxSzso1e48L+nFPCMqXZAAYKhV02Z29jQBg@mail.gmail.com>
 <alpine.DEB.2.02.1407301901250.12482@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Olof Johansson <olof@lixom.net>, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, kbuild test robot <fengguang.wu@intel.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

free_huge_page() is undefined without CONFIG_HUGETLBFS and there's no need
to filter PageHuge() page is such a configuration either, so avoid exporting the
symbol to fix a build error:

   In file included from kernel/kexec.c:14:0:
   kernel/kexec.c: In function 'crash_save_vmcoreinfo_init':
   kernel/kexec.c:1623:20: error: 'free_huge_page' undeclared (first use in this function)
     VMCOREINFO_SYMBOL(free_huge_page);
                       ^

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Acked-by: Olof Johansson <olof@lixom.net>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 kernel/kexec.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/kexec.c b/kernel/kexec.c
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -1620,7 +1620,9 @@ static int __init crash_save_vmcoreinfo_init(void)
 #endif
 	VMCOREINFO_NUMBER(PG_head_mask);
 	VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);
+#ifdef CONFIG_HUGETLBFS
 	VMCOREINFO_SYMBOL(free_huge_page);
+#endif
 
 	arch_crash_save_vmcoreinfo();
 	update_vmcoreinfo_note();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
