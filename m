Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id D86516B004D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 03:04:25 -0500 (EST)
From: Petr Tesarik <ptesarik@suse.cz>
Subject: [PATCH] Do not round per_cpu_ptr_to_phys to page boundary
Date: Fri, 16 Dec 2011 09:04:23 +0100
References: <201112140033.58951.ptesarik@suse.cz> <201112151139.32224.ptesarik@suse.cz> <CAOS58YP8o9xQvZJtpEJobChhJ+pSDQ9PqDwaXFS_h+JFd65jOw@mail.gmail.com>
In-Reply-To: <CAOS58YP8o9xQvZJtpEJobChhJ+pSDQ9PqDwaXFS_h+JFd65jOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201112160904.23252.ptesarik@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Vivek Goyal <vgoyal@redhat.com>, surovegin@google.com, gthelen@google.com

The phys_addr_t per_cpu_ptr_to_phys() function ignores the offset within a 
page, whenever not using a simple translation using __pa().

Without this patch /sys/devices/system/cpu/cpu*/crash_notes shows incorrect 
values, which breaks kdump. Other things may also be broken.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>

diff --git a/mm/percpu.c b/mm/percpu.c
index 3bb810a..1a1b5ac 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -998,6 +998,7 @@ phys_addr_t per_cpu_ptr_to_phys(void *addr)
 	bool in_first_chunk = false;
 	unsigned long first_low, first_high;
 	unsigned int cpu;
+	phys_addr_t page_addr;
 
 	/*
 	 * The following test on unit_low/high isn't strictly
@@ -1023,9 +1024,10 @@ phys_addr_t per_cpu_ptr_to_phys(void *addr)
 		if (!is_vmalloc_addr(addr))
 			return __pa(addr);
 		else
-			return page_to_phys(vmalloc_to_page(addr));
+			page_addr = page_to_phys(vmalloc_to_page(addr));
 	} else
-		return page_to_phys(pcpu_addr_to_page(addr));
+		page_addr = page_to_phys(pcpu_addr_to_page(addr));
+	return page_addr + offset_in_page(addr);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
