Message-ID: <39CA6F84.813057D6@norran.net>
Date: Thu, 21 Sep 2000 22:28:52 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [patch *] VM deadlock fix
References: <Pine.LNX.4.21.0009211340110.18809-100000@duckman.distro.conectiva>
Content-Type: multipart/mixed;
 boundary="------------F7EE82892EE825EC04F3B84F"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------F7EE82892EE825EC04F3B84F
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

Tried your patch on 2.2.4-test9-pre4
with the included debug patch applied.

Rebooted, started mmap002

After a while it starts outputting (magic did not work
this time - usually does):

- - -
"VM: try_to_free_pages (result: 1) try_again # 12345"
"VM: try_to_free_pages (result: 1) try_again # 12346"
- - -

My interpretation:
1) try_to_free_pages succeeds (or returns ok when it did not work)
2) __alloc_pages still can't alloc

Maybe it is different limits,
  try_to_free_pages requires less to succeed than
  __alloc_pages_limit requires.
or a bug in
  __alloc_pages_limit(zonelist, order, PAGES_MIN, direct_reclaim)

Note:
  12345  is an example, it loops to over 30000...

/RogerL

Rik van Riel wrote:
> 
> Hi,
> 
> I've found and fixed the deadlocks in the new VM. They turned out
> to be single-cpu only bugs, which explains why they didn't crash my
> SMP tesnt box ;)
> 
> They have to do with the fact that processes schedule away while
> holding IO locks after waking up kswapd. At that point kswapd
> spends its time spinning on the IO locks and single-cpu systems
> will die...
> 
> Due to bad connectivity I'm not attaching this patch but have only
> put it online on my home page:
> 
> http://www.surriel.com/patches/2.4.0-t9p2-vmpatch
> 
> (yes, I'm at a conference now ... the worst beating this patch
> has had is a full night in 'make bzImage' with mem=8m)
> 
> regards,
> 
> Rik
> --
> "What you're running that piece of shit Gnome?!?!"
>        -- Miguel de Icaza, UKUUG 2000
> 
> http://www.conectiva.com/               http://www.surriel.com/
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> Please read the FAQ at http://www.tux.org/lkml/

--
Home page:
  http://www.norran.net/nra02596/
--------------F7EE82892EE825EC04F3B84F
Content-Type: text/plain; charset=us-ascii;
 name="vmdebug.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vmdebug.patch"

--- mm/page_alloc.c.orig	Thu Sep 21 20:02:54 2000
+++ mm/page_alloc.c	Thu Sep 21 20:49:35 2000
@@ -295,6 +295,7 @@
 	int direct_reclaim = 0;
 	unsigned int gfp_mask = zonelist->gfp_mask;
 	struct page * page = NULL;
+	int try_again_loops = 0;
 
 	/*
 	 * Allocations put pressure on the VM subsystem.
@@ -320,8 +321,10 @@
 	/*
 	 * Are we low on inactive pages?
 	 */
-	if (inactive_shortage() > inactive_target / 2 && free_shortage())
+	if (inactive_shortage() > inactive_target / 2 && free_shortage()) {
+	  printk("VM: inactive shortage wake kswapd\n");
 		wakeup_kswapd(0);
+	}
 
 try_again:
 	/*
@@ -410,6 +413,7 @@
 		 * piece of free memory.
 		 */
 		if (order > 0 && (gfp_mask & __GFP_WAIT)) {
+		  printk("VM: higher order");
 			zone = zonelist->zones;
 			/* First, clean some dirty pages. */
 			page_launder(gfp_mask, 1);
@@ -444,7 +448,9 @@
 		 * processes, etc).
 		 */
 		if (gfp_mask & __GFP_WAIT) {
-			try_to_free_pages(gfp_mask);
+			int success = try_to_free_pages(gfp_mask);
+         printk("VM: try_to_free_pages (result: %d) try_again # %d\n",
+                success, ++try_again_loops);   
 			memory_pressure++;
 			goto try_again;
 		}

--------------F7EE82892EE825EC04F3B84F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
