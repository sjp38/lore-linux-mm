Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id A6BFB6B0290
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 18:34:02 -0500 (EST)
From: Petr Tesarik <ptesarik@suse.cz>
Subject: Is per_cpu_ptr_to_phys broken?
Date: Wed, 14 Dec 2011 00:33:58 +0100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201112140033.58951.ptesarik@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Vivek Goyal <vgoyal@redhat.com>

Hi folks,

while trying to understand a weird kdump failure, I found out that the 
secondary kernel doesn't get the correct NT_PRSTATUS notes from the primary 
kernel. Further research reveals that the notes are correctly generated, 
corresponding elfcorehdr program headers are created by kexec, but the 
physical address is wrong.

The trouble is that the crash_notes per-cpu variable is not page-aligned:

crash_notes = 0xc08e8ed4
PER-CPU OFFSET VALUES:
  CPU 0: 3711f000
  CPU 1: 37129000
  CPU 2: 37133000
  CPU 3: 3713d000

So, the per-cpu addresses are:
  crash_notes on CPU 0: f7a07ed4 => phys 36b57ed4
  crash_notes on CPU 1: f7a11ed4 => phys 36b4ded4
  crash_notes on CPU 2: f7a1bed4 => phys 36b43ed4
  crash_notes on CPU 3: f7a25ed4 => phys 36b39ed4

However, /sys/devices/system/cpu/cpu*/crash_notes says:
/sys/devices/system/cpu/cpu0/crash_notes: 36b57000
/sys/devices/system/cpu/cpu1/crash_notes: 36b4d000
/sys/devices/system/cpu/cpu2/crash_notes: 36b43000
/sys/devices/system/cpu/cpu3/crash_notes: 36b39000

As you can see, all values are rounded down to a page boundary. Consequently, 
this is where kexec sets up the NOTE segments, and thus where the secondary 
kernel is looking for them. However, when the first kernel crashes, it saves 
the notes to the unaligned addresses, where they are not found.

The value in the crash_notes sysfs attribute are computed as follows:

        addr = per_cpu_ptr_to_phys(per_cpu_ptr(crash_notes, cpunum));

Note that the per-cpu addresses lie between VMALLOC_START (0xf79fe000 on this 
machine) and VMALLOC_END (0xff1fe000).

Now, the per_cpu_ptr_to_phys() function aligns all vmalloc addresses to a page 
boundary. This was probably right when Vivek Goyal introduced that function 
(commit 3b034b0d084221596bf35c8d893e1d4d5477b9cc), because per-cpu addresses
were only allocated by vmalloc if booted with percpu_alloc=page, but this is 
no longer the case, because per-cpu variables are now always allocated that 
way AFAICS.

So, shouldn't we add the offset within the page inside per_cpu_ptr_to_phys?

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>

diff --git a/mm/percpu.c b/mm/percpu.c
index 3bb810a..4c13334 100644
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
+	return page_addr + ((unsigned long)addr & ~PAGE_MASK);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
