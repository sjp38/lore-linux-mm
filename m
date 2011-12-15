Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id C67826B004D
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 14:26:00 -0500 (EST)
Date: Thu, 15 Dec 2011 11:25:59 -0800
From: Eugene Surovegin <ebs@ebshome.net>
Subject: [PATCH] percpu: fix per_cpu_ptr_to_phys() handling of
 non-page-aligned addresses.
Message-ID: <20111215192559.GA28283@gate.ebshome.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: ptesarik@suse.cz, xiyou.wangcong@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, vgoyal@redhat.com

per_cpu_ptr_to_phys() incorrectly rounds up its result for non-kmalloc case
to the page boundary, which is bogus for any non-page-aligned address.

This fixes the only in-tree user of this function - sysfs handler for
per-cpu 'crash_notes' physical address. The manifestation of this bug is
missing 'CORE' ELF notes in kdump.

Signed-off-by: Eugene Surovegin <ebs@ebshome.net>
---
 mm/percpu.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 3bb810a..716eb4a 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1023,9 +1023,11 @@ phys_addr_t per_cpu_ptr_to_phys(void *addr)
 		if (!is_vmalloc_addr(addr))
 			return __pa(addr);
 		else
-			return page_to_phys(vmalloc_to_page(addr));
+			return page_to_phys(vmalloc_to_page(addr)) +
+			       offset_in_page(addr);
 	} else
-		return page_to_phys(pcpu_addr_to_page(addr));
+		return page_to_phys(pcpu_addr_to_page(addr)) +
+		       offset_in_page(addr);
 }
 
 /**
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
