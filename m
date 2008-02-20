Date: Wed, 20 Feb 2008 13:23:38 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Document huge memory/cache overhead of memory controller in Kconfig
Message-ID: <20080220122338.GA4352@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Document huge memory/cache overhead of memory controller in Kconfig

I was a little surprised that 2.6.25-rc* increased struct page for the memory
controller.  At least on many x86-64 machines it will not fit into a single
cache line now anymore and also costs considerable amounts of RAM. 
At earlier review I remembered asking for a external data structure for this.

It's also quite unobvious that a innocent looking Kconfig option with a 
single line Kconfig description has such a negative effect.

This patch attempts to document these disadvantages at least so that users
configuring their kernel can make a informed decision.

Cc: balbir@linux.vnet.ibm.com

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux/init/Kconfig
===================================================================
--- linux.orig/init/Kconfig
+++ linux/init/Kconfig
@@ -394,6 +394,14 @@ config CGROUP_MEM_CONT
 	  Provides a memory controller that manages both page cache and
 	  RSS memory.
 
+	  Note that setting this option increases fixed memory overhead
+	  associated with each page of memory in the system by 4/8 bytes
+	  and also increases cache misses because struct page on many 64bit
+	  systems will not fit into a single cache line anymore.
+
+	  Only enable when you're ok with these trade offs and really
+	  sure you need the memory controller.
+
 config PROC_PID_CPUSET
 	bool "Include legacy /proc/<pid>/cpuset file"
 	depends on CPUSETS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
