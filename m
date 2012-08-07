Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id A7B656B0044
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 04:56:05 -0400 (EDT)
Date: Tue, 7 Aug 2012 09:55:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] netvm: check for page == NULL when propogating the
 skb->pfmemalloc flag
Message-ID: <20120807085554.GF29814@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux-Netdev <netdev@vger.kernel.org>, Xen-devel <xen-devel@lists.xensource.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Ian Campbell <Ian.Campbell@eu.citrix.com>, Andrew Morton <akpm@linux-foundation.org>

Commit [c48a11c7: netvm: propagate page->pfmemalloc to skb] is responsible
for the following bug triggered by a xen network driver

[    1.908592] BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
[    1.908643] IP: [<ffffffffa0037750>] xennet_poll+0x980/0xec0 [xen_netfront]
[    1.908703] PGD ea1df067 PUD e8ada067 PMD 0
[    1.908774] Oops: 0000 [#1] SMP
[    1.908797] Modules linked in: fbcon tileblit font radeon bitblit softcursor ttm drm_kms_helper crc32c_intel xen_blkfront xen_netfront xen_fbfront fb_sys_fops sysimgblt sysfillrect syscopyarea +xen_kbdfront xenfs xen_privcmd
[    1.908938] CPU 0
[    1.908950] Pid: 2165, comm: ip Not tainted 3.5.0upstream-08854-g444fa66 #1
[    1.908983] RIP: e030:[<ffffffffa0037750>]  [<ffffffffa0037750>] xennet_poll+0x980/0xec0 [xen_netfront]
[    1.909029] RSP: e02b:ffff8800ffc03db8  EFLAGS: 00010282
[    1.909055] RAX: ffff8800ea010140 RBX: ffff8800f00e86c0 RCX: 000000000000009a
[    1.909055] RDX: 0000000000000040 RSI: 000000000000005a RDI: ffff8800fa7dee80
[    1.909055] RBP: ffff8800ffc03ee8 R08: ffff8800f00e86d8 R09: ffff8800ea010000
[    1.909055] R10: dead000000200200 R11: dead000000100100 R12: ffff8800fa7dee80
[    1.909055] R13: 000000000000005a R14: ffff8800fa7dee80 R15: 0000000000000200
[    1.909055] FS:  00007fbafc188700(0000) GS:ffff8800ffc00000(0000) knlGS:0000000000000000
[    1.909055] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
[    1.909055] CR2: 0000000000000010 CR3: 00000000ea108000 CR4: 0000000000002660
[    1.909055] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    1.909055] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    1.909055] Process ip (pid: 2165, threadinfo ffff8800ea0f2000, task ffff8800fa783040)
[    1.909055] Stack:
[    1.909055]  ffff8800e27e5040 ffff8800ffc03e88 ffff8800ffc03e68 ffff8800ffc03e48
[    1.909055]  7fffffffffffffff ffff8800ffc03e00 ffff8800e27e5040 ffff8800f00e86d8
[    1.909055]  ffff8800ffc03eb0 00000040ffffffff ffff8800f00e8000 00000000ffc03e30
[    1.909055] Call Trace:
[    1.909055]  <IRQ>
[    1.909055]  [<ffffffff81066028>] ?  pvclock_clocksource_read+0x58/0xd0
[    1.909055]  [<ffffffff81486352>] net_rx_action+0x112/0x240
[    1.909055]  [<ffffffff8107f319>] __do_softirq+0xb9/0x190
[    1.909055]  [<ffffffff815d8d7c>] call_softirq+0x1c/0x30

The problem is that the xenfront driver is passing a NULL page to
__skb_fill_page_desc() which was unexpected. This patch checks that
there is a page before dereferencing.

Reported-and-Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/skbuff.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7632c87..8857669 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1256,7 +1256,7 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
 	 * do not lose pfmemalloc information as the pages would not be
 	 * allocated using __GFP_MEMALLOC.
 	 */
-	if (page->pfmemalloc && !page->mapping)
+	if (page && page->pfmemalloc && !page->mapping)
 		skb->pfmemalloc	= true;
 	frag->page.p		  = page;
 	frag->page_offset	  = off;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
