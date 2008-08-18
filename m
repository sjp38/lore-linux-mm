Received: from chimera.site ([72.90.117.230]) by xenotime.net for <linux-mm@kvack.org>; Mon, 18 Aug 2008 09:43:37 -0700
Date: Mon, 18 Aug 2008 09:44:12 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: sparsemem support for mips with highmem
Message-Id: <20080818094412.09086445.rdunlap@xenotime.net>
In-Reply-To: <48A5C831.3070002@sciatl.com>
References: <48A4AC39.7020707@sciatl.com>
	<1218753308.23641.56.camel@nimitz>
	<48A4C542.5000308@sciatl.com>
	<20080815080331.GA6689@alpha.franken.de>
	<1218815299.23641.80.camel@nimitz>
	<48A5AADE.1050808@sciatl.com>
	<20080815163302.GA9846@alpha.franken.de>
	<48A5B9F1.3080201@sciatl.com>
	<1218821875.23641.103.camel@nimitz>
	<48A5C831.3070002@sciatl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Aug 2008 11:17:21 -0700 C Michael Sundius wrote:

> Ah, compromise :] that's why you get paid the big bux dave. thanks.

Here are some documentation comments/corrections.

And please try to use inline patches instead of attachments.
See Documenation/email-clients.txt for some help on this.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

diff --git a/Documentation/sparsemem.txt b/Documentation/sparsemem.txt
new file mode 100644
index 0000000..89656e3
--- /dev/null
+++ b/Documentation/sparsemem.txt
@@ -0,0 +1,96 @@
+Sparsemem divides up physical memory in your system into N section of M

                                                            sections

+bytes. Page descriptors are created for only those sections that
+actually exist (as far as the sparsemem code is concerned). This allows
+for holes in the physical memory without having to waste space by
+creating page discriptors for those pages that do not exist.

               descriptors

+When page_to_pfn() or pfn_to_page() are called there is a bit of overhead to
+look up the proper memory section to get to the descriptors, but this
+is small compared to the memory you are likely to save. So, it's not the
+default, but should be used if you have big holes in physical memory.
+
+Note that discontiguous memory is more closely related to NUMA machines
+and if you are a single CPU system use sparsemem and not discontig. 
+It's much simpler. 
+
+1) CALL MEMORY_PRESENT()
+Once the bootmem allocator is up and running, you should call the
+sparsemem function "memory_present(node, pfn_start, pfn_end)" for each
+block of memory that exists on your system.
+
+2) DETERMINE AND SET THE SIZE OF SECTIONS AND PHYSMEM

...

+3) INITIALIZE SPARSE MEMORY
+You should make sure that you initialize the sparse memory code by calling 
+
+	bootmem_init();
+  +	sparse_init();
+	paging_init();
+
+just before you call paging_init() and after the bootmem_allocator is
+turned on in your setup_arch() code.  
+
+4) ENABLE SPARSEMEM IN KCONFIG
+Add a line like this:
+
+	select ARCH_SPARSEMEM_ENABLE
+
+into the config for your platform in arch/<your_arch>/Kconfig. This will
+ensure that turning on sparsemem is enabled for your platform. 
+
+5) CONFIG
+Run make menuconfig or make gconfig, as you like, and turn on the sparsemem
+memory model under the "Kernel Type" --> "Memory Model" and then build your
+kernel.

Wow!  A gconfig user?  I see more people using menuconfig or xconfig IIRC.
Anyway, we usually just say something like "run make *config"...

+
+
+6) Gotchas
+
+One trick that I encountered when I was turning this on for MIPS was that there
+was some code in mem_init() that set the "reserved" flag for pages that were not
+valid RAM. This caused my kernel to crash when I enabled sparsemem since those
+pages (and page descriptors) didn't actually exist. I changed my code by adding
+lines like below:
+
+
+	for (tmp = highstart_pfn; tmp < highend_pfn; tmp++) {
+		struct page *page = pfn_to_page(tmp);
+
+   +		if (!pfn_valid(tmp))
+   +			continue;
+   +
+		if (!page_is_ram(tmp)) {
+			SetPageReserved(page);
+			continue;
+		}
+		ClearPageReserved(page);
+		init_page_count(page);
+		__free_page(page);
+		physmem_record(PFN_PHYS(tmp), PAGE_SIZE, physmem_highmem);
+		totalhigh_pages++;
+	}
+
+
+Once I got that straight, it worked!!!! I saved 10MiB of memory.  

Please don't end patch lines with whitespace.  (like above)



---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
