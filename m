Date: Thu, 17 Jun 2004 21:40:35 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Message-Id: <20040617214035.01e38285.akpm@osdl.org>
In-Reply-To: <20040617131031.GB8473@sgi.com>
References: <40D08225.6060900@colorfullife.com>
	<20040616180208.GD6069@sgi.com>
	<40D09872.4090107@colorfullife.com>
	<20040617131031.GB8473@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: manfred@colorfullife.com, linux-kernel@vger.kernel.org, lse-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dimitri Sivanich <sivanich@sgi.com> wrote:
>
> On Wed, Jun 16, 2004 at 08:58:58PM +0200, Manfred Spraul wrote:
>  > Could you try to reduce them? Something like (as root)
>  > 
>  > # cd /proc
>  > # cat slabinfo | gawk '{printf("echo \"%s %d %d %d\" > 
>  > /proc/slabinfo\n", $1,$9,4,2);}' | bash
>  > 
>  > If this doesn't help then perhaps the timer should run more frequently 
>  > and scan only a part of the list of slab caches.
> 
>  I tried the modification you suggested and it had little effect.  On a 4 cpu
>  (otherwise idle) system I saw the characteristic 30+ usec interruptions
>  (holdoffs) every 2 seconds.

Against which slab cache?  How many objects are being reaped in a single
timer tick?

It's very simple:

--- 25/mm/slab.c~a	2004-06-17 21:38:57.728796976 -0700
+++ 25-akpm/mm/slab.c	2004-06-17 21:40:06.294373424 -0700
@@ -2690,6 +2690,7 @@ static void drain_array_locked(kmem_cach
 static inline void cache_reap (void)
 {
 	struct list_head *walk;
+	static int max;
 
 #if DEBUG
 	BUG_ON(!in_interrupt());
@@ -2731,6 +2732,11 @@ static inline void cache_reap (void)
 		}
 
 		tofree = (searchp->free_limit+5*searchp->num-1)/(5*searchp->num);
+		if (tofree > max) {
+			max = tofree;
+			printk("%s: reap %d\n", searchp->name, tofree);
+		}
+
 		do {
 			p = list3_data(searchp)->slabs_free.next;
 			if (p == &(list3_data(searchp)->slabs_free))
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
