Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA00616
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 20:18:45 -0500
Date: Thu, 7 Jan 1999 17:16:35 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.95.990107144729.5025P-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.95.990107171547.397A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Thu, 7 Jan 1999, Linus Torvalds wrote:
>
> and I suspect the fix is fairly simple: I'll just add back the __GFP_IO
> bit (we kind of used to have one that did something similar) which will
> make the swap-out code not write out shared pages when it allocates
> buffers. 

Ok, here it is.. Stable.

		Linus

-----
diff -u --recursive --new-file v2.2.0-pre5/linux/include/linux/mm.h linux/include/linux/mm.h
--- v2.2.0-pre5/linux/include/linux/mm.h	Thu Jan  7 15:11:40 1999
+++ linux/include/linux/mm.h	Thu Jan  7 15:04:54 1999
@@ -315,14 +323,15 @@
 #define __GFP_LOW	0x02
 #define __GFP_MED	0x04
 #define __GFP_HIGH	0x08
+#define __GFP_IO	0x10
 
 #define __GFP_DMA	0x80
 
 #define GFP_BUFFER	(__GFP_LOW | __GFP_WAIT)
 #define GFP_ATOMIC	(__GFP_HIGH)
-#define GFP_USER	(__GFP_LOW | __GFP_WAIT)
-#define GFP_KERNEL	(__GFP_MED | __GFP_WAIT)
-#define GFP_NFS		(__GFP_HIGH | __GFP_WAIT)
+#define GFP_USER	(__GFP_LOW | __GFP_WAIT | __GFP_IO)
+#define GFP_KERNEL	(__GFP_MED | __GFP_WAIT | __GFP_IO)
+#define GFP_NFS		(__GFP_HIGH | __GFP_WAIT | __GFP_IO)
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */
diff -u --recursive --new-file v2.2.0-pre5/linux/mm/vmscan.c linux/mm/vmscan.c
--- v2.2.0-pre5/linux/mm/vmscan.c	Thu Jan  7 15:11:41 1999
+++ linux/mm/vmscan.c	Thu Jan  7 15:09:46 1999
@@ -76,7 +76,6 @@
 		set_pte(page_table, __pte(entry));
 drop_pte:
 		vma->vm_mm->rss--;
-		tsk->nswap++;
 		flush_tlb_page(vma, address);
 		__free_page(page_map);
 		return 0;
@@ -99,6 +98,14 @@
 		pte_clear(page_table);
 		goto drop_pte;
 	}
+
+	/*
+	 * Don't go down into the swap-out stuff if
+	 * we cannot do I/O! Avoid recursing on FS
+	 * locks etc.
+	 */
+	if (!(gfp_mask & __GFP_IO))
+		return 0;
 
 	/*
 	 * Ok, it's really dirty. That means that


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
