Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j2BKc34I592162
	for <linux-mm@kvack.org>; Fri, 11 Mar 2005 15:38:03 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2BKc3R2217514
	for <linux-mm@kvack.org>; Fri, 11 Mar 2005 13:38:03 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j2BKc3WV028105
	for <linux-mm@kvack.org>; Fri, 11 Mar 2005 13:38:03 -0700
Subject: [PATCH] x86: fix booting non-NUMA system with NUMA config
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0503111922520.9403@goblin.wat.veritas.com>
References: <Pine.LNX.4.61.0503111922520.9403@goblin.wat.veritas.com>
Content-Type: multipart/mixed; boundary="=-lccz448pFMJoMIGeWIF+"
Date: Fri, 11 Mar 2005 12:37:51 -0800
Message-Id: <1110573471.557.73.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-lccz448pFMJoMIGeWIF+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2005-03-11 at 19:25 +0000, Hugh Dickins wrote:
> This used to work fine, but around the time your abstract discontigmem
> patches went into -mm, the resulting kernel failed to boot - blank
> screen after grub for a few seconds, until it reboots again.  And now
> your patches have just gone into mainline, that resulting kernel fails
> to boot.  I've not done a binary search to identify any one of your
> patches as the culprit, but you are my Number One suspect ;)

Hugh, you caught me.  There is, indeed, a bug booting with
CONFIG_NUMA=y, CONFIG_X86_GENERICARCH=y, and booting on a non-NUMA
system.  While not the most common configuration, it should surely be
supported.

memmap_init_zone() is the first user to do pfn_to_nid(), which relies on
physnode_map[] to be done properly.  memory_present() was supposed to do
that, but never got called for the flat configuration, so pfn_to_nid()
was returning -1 on valid pages.

Andrew, please apply and forward the attached patch on to Linus.  It
affects code currently in -bk.

Test compiled and booted on 4-way non-NUMA x86 system.

-- Dave

--=-lccz448pFMJoMIGeWIF+
Content-Disposition: attachment; filename=memory_present_for_flat.patch
Content-Type: text/x-patch; name=memory_present_for_flat.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit



---

 memhotplug-dave/arch/i386/mm/discontig.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN arch/i386/mm/discontig.c~memory_present_for_flat arch/i386/mm/discontig.c
--- memhotplug/arch/i386/mm/discontig.c~memory_present_for_flat	2005-03-11 12:29:45.000000000 -0800
+++ memhotplug-dave/arch/i386/mm/discontig.c	2005-03-11 12:30:04.000000000 -0800
@@ -121,6 +121,7 @@ int __init get_memcfg_numa_flat(void)
 	find_max_pfn();
 	node_start_pfn[0] = 0;
 	node_end_pfn[0] = max_pfn;
+	memory_present(0, 0, max_pfn);
 
         /* Indicate there is one node available. */
 	nodes_clear(node_online_map);
_

--=-lccz448pFMJoMIGeWIF+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
