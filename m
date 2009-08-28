Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 927516B004F
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 14:58:59 -0400 (EDT)
Message-ID: <4A9828F4.4040905@zytor.com>
Date: Fri, 28 Aug 2009 11:59:00 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: PG_uncached, CONFIG_EXTENDED_PAGEFLAGS and !NUMA
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arch@vger.kernel.org
Cc: Suresh Siddha <suresh.b.siddha@intel.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>, LKML <linux-kernel@vger.kernel.org>, Jeremy Fitzhardinge <jeremy@goop.org>, Sam Ravnborg <sam@ravnborg.org>
List-ID: <linux-mm.kvack.org>

Hi all,

I am looking at a patchset by Venkatesh Pallipadi which cleans up a lot
of the corner cases in x86 PAT.

http://marc.info/?i=cover.1247162373.git.venkatesh.pallipadi@intel.com

This patchset pages PG_uncached available to other architectures than
IA64 on an opt-in basis.  Unfortunately, it means we run out of page
flags on X86_32+PAE+SPARSEMEM.

Rather than increasing SECTION_SIZE_BITS further, it seems more
reasonable to disable CONFIG_EXTENDED_PAGEFLAGS in this case:

diff --git a/mm/Kconfig b/mm/Kconfig
index c948d4c..fe221c7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -153,7 +153,7 @@ config MEMORY_HOTREMOVE
 #
 config PAGEFLAGS_EXTENDED
        def_bool y
-       depends on 64BIT || SPARSEMEM_VMEMMAP || !NUMA || !SPARSEMEM
+       depends on 64BIT || SPARSEMEM_VMEMMAP || !SPARSEMEM

 # Heavily threaded applications may benefit from splitting the mm-wide

Dropping the !NUMA requirement here seems reasonable, since we already
have generic code that handles removing the node number from the page
flags when there are too many.

We could make this an x86-specific change, but the above generic change
would be cleaner in terms of Kconfig complexity.  Would people object to
this as a general change?

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
