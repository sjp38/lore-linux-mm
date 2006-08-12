Message-ID: <44410.81.207.0.53.1155411901.squirrel@81.207.0.53>
In-Reply-To: <1155408431.13508.110.camel@lappy>
References: <20060812141415.30842.78695.sendpatchset@lappy>
    <20060812141445.30842.47336.sendpatchset@lappy>
    <44640.81.207.0.53.1155403862.squirrel@81.207.0.53>
    <1155404697.13508.81.camel@lappy>
    <40048.81.207.0.53.1155405282.squirrel@81.207.0.53>
    <1155406120.13508.87.camel@lappy>
    <57504.81.207.0.53.1155407532.squirrel@81.207.0.53>
    <1155408431.13508.110.camel@lappy>
Date: Sat, 12 Aug 2006 21:45:01 +0200 (CEST)
Subject: Re: [RFC][PATCH 3/4] deadlock prevention core
From: "Indan Zupancic" <indan@nul.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Sat, August 12, 2006 20:47, Peter Zijlstra said:
> Ah right, I did that in v3, with a similar comment, but I realised that
> the inbound reserve need not be per socket, and that the comment was
> ambiguous enough to allow this reading.

True, but better to change the comment than to confuse people.
Lots of it is outdated because reservations aren't per device anymore.

Changes to your version:
- Got rid of memalloc_socks.
- Don't include inetdevice.h (it isn't needed anymore, right?)
- Updated comment.

(I'm editing the diff, so this won't apply)

Index: linux-2.6/net/core/sock.c
===================================================================
--- linux-2.6.orig/net/core/sock.c	2006-08-12 12:56:06.000000000 +0200
+++ linux-2.6/net/core/sock.c	2006-08-12 13:02:59.000000000 +0200
@@ -111,6 +111,8 @@
 #include <linux/poll.h>
 #include <linux/tcp.h>
 #include <linux/init.h>
+#include <linux/blkdev.h>

 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -195,6 +197,78 @@ __u32 sysctl_rmem_default = SK_RMEM_MAX;
 /* Maximal space eaten by iovec or ancilliary data plus some space */
 int sysctl_optmem_max = sizeof(unsigned long)*(2*UIO_MAXIOV + 512);

+static DEFINE_SPINLOCK(memalloc_lock);
+static int memalloc_socks;
+static unsigned long memalloc_reserve;
+
+atomic_t memalloc_skbs_used;
+EXPORT_SYMBOL_GPL(memalloc_skbs_used);
+
+/**
+ *        sk_adjust_memalloc - adjust the global memalloc reserve
+ *        @nr_socks: number of new %SOCK_MEMALLOC sockets
+ *
+ *        This function adjusts the memalloc reserve based on system demand.
+ *        For each %SOCK_MEMALLOC socket 2 * %MAX_PHYS_SEGMENTS pages are
+ *        reserved for outbound traffic (assumption: each %SOCK_MEMALLOC
+ *        socket will have a %request_queue associated).
+ *
+ *        Pages for inbound traffic are already reserved.
+ *
+ *        2 * %MAX_PHYS_SEGMENTS - the request queue can hold up to 150%,
+ *                the remaining 50% goes to being sure we can write packets
+ *                for the outgoing pages.
+ */
+static DEFINE_SPINLOCK(memalloc_lock);
+static int memalloc_socks;
+
+atomic_t memalloc_skbs_used;
+EXPORT_SYMBOL_GPL(memalloc_skbs_used);
+
+int sk_adjust_memalloc(int nr_socks)
+{
+	unsigned long flags;
+	unsigned int reserve;
+	int err;
+
+	spin_lock_irqsave(&memalloc_lock, flags);
+
+	memalloc_socks += nr_socks;
+	BUG_ON(memalloc_socks < 0);
+
+	reserve = nr_socks * 2 * MAX_PHYS_SEGMENTS;	/* outbound */
+
+	err = adjust_memalloc_reserve(reserve);
+	spin_unlock_irqrestore(&memalloc_lock, flags);
+	if (err) {
+		printk(KERN_WARNING
+			"Unable to adjust RX reserve by %lu, error: %d\n",
+			reserve, err);
+	}
+	return err;
+}
+EXPORT_SYMBOL_GPL(sk_adjust_memalloc);

What's missing now is an adjust_memalloc_reserve(5 * MAX_CONCURRENT_SKBS)
call in some init code.

Greetings,

Indan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
