Message-ID: <3B114667.DCC8A2B7@colorfullife.com>
Date: Sun, 27 May 2001 20:24:39 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] modified memory_pressure calculation
References: <Pine.LNX.4.21.0105271451120.1907-100000@imladris.rielhome.conectiva>
Content-Type: multipart/mixed;
 boundary="------------138E36E92ECB2795D5D22D8C"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------138E36E92ECB2795D5D22D8C
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Rik van Riel wrote:
> 
> On Sun, 27 May 2001, Manfred Spraul wrote:
> 
> > >          if (z->free_pages < z->pages_min / 4 &&
> > > -           !(current->flags & PF_MEMALLOC))
> > > +            (in_interrupt() || !(current->flags & PF_MEMALLOC)))
> > >             continue;
> >
> > It's 'if (in_interrupt()) continue', not 'if (in_interrupt()) alloc'.
> > Currently a network card can allocate the last few pages if the
> > interrupt occurs in the context of the PF_MEMALLOC thread. I think
> > PF_MEMALLOC memory should never be available to interrupt handlers.
> 
> You're right, my mistake.
>
Ok, then the attached patch should be ok [SMP safe 'memory_pressure--' +
the change above].

I've moved the modified memory_pressure calculation into my 'not_now'
folder - not enough time for proper testing, and the change definitively
needs thorough testing.

We should take into account that the current page owner can reactivage a
page, i.e. nr_inactive_{dirty,clean}_pages overestimates the number of
really inactive pages in these lists.

My modified memory_pressure calculation would be one way to implement
that.

--
	Manfred
--------------138E36E92ECB2795D5D22D8C
Content-Type: text/plain; charset=us-ascii;
 name="patch-PF"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-PF"

diff -u 2.4/mm/page_alloc.c build-2.4/mm/page_alloc.c
--- 2.4/mm/page_alloc.c	Sat May 26 10:06:29 2001
+++ build-2.4/mm/page_alloc.c	Sun May 27 20:12:23 2001
@@ -141,8 +141,11 @@
 	 * since it's nothing important, but we do want to make sure
 	 * it never gets negative.
 	 */
-	if (memory_pressure > NR_CPUS)
-		memory_pressure--;
+	{
+		int mp = memory_pressure-1;
+		if (mp > 0)
+			memory_pressure = mp;
+	}
 }
 
 #define MARK_USED(index, order, area) \
@@ -476,7 +479,7 @@
 
 		/* XXX: is pages_min/4 a good amount to reserve for this? */
 		if (z->free_pages < z->pages_min / 4 &&
-				!(current->flags & PF_MEMALLOC))
+			(in_interrupt() || !(current->flags & PF_MEMALLOC)))
 			continue;
 		page = rmqueue(z, order);
 		if (page)

--------------138E36E92ECB2795D5D22D8C--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
