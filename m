Received: from Galois.suse.de (Galois.suse.de [195.125.217.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA07006
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 15:16:10 -0400
Received: from boole.suse.de (Boole.suse.de [192.168.102.7])
	by Galois.suse.de (8.8.8/8.8.8) with ESMTP id VAA04384
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 21:12:22 +0200
Message-ID: <19980723211222.37937@boole.suse.de>
Date: Thu, 23 Jul 1998 21:12:22 +0200
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk> <m190lxmxmv.fsf@flinx.npwt.net> <199807141730.SAA07239@dax.dcs.ed.ac.uk> <m14swgm0am.fsf@flinx.npwt.net> <87d8b370ge.fsf@atlas.CARNet.hr> <199807221033.LAA00826@dax.dcs.ed.ac.uk> <87hg08vnmt.fsf@atlas.CARNet.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87hg08vnmt.fsf@atlas.CARNet.hr>; from Zlatko Calusic on Thu, Jul 23, 1998 at 12:59:38PM +0200
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 23, 1998 at 12:59:38PM +0200, Zlatko Calusic wrote:
> 
> I tried the other way, to age page cache harder, and it looks like it
> works very well. Patch is simple, so simple that I can't understand
> nobody suggested (something like) it yet.
> 
> 
> --- filemap.c.virgin   Tue Jul 21 18:41:30 1998
> +++ filemap.c   Thu Jul 23 12:14:43 1998
> @@ -171,6 +171,11 @@
>                                 touch_page(page);
>                                 break;
>                         }
> +                       /* Age named pages aggresively, so page cache
> +                        * doesn't grow too fast.    -zcalusic
> +                        */
> +                       age_page(page);
> +                       age_page(page);
>                         age_page(page);
>                         if (page->age)
>                                 break;
> 

I've something similar ... cut&paste (no tabs) ... which would only do
less graduated ageing on small systems.

------------------------------------------------------------------------------- 
diff -urN linux-2.1.110/include/linux/swapctl.h linux/include/linux/swapctl.h
--- linux-2.1.110/include/linux/swapctl.h       Tue Jul 21 02:32:01 1998
+++ linux/include/linux/swapctl.h       Wed Jul 22 18:04:28 1998
@@ -94,12 +94,26 @@
                return n;
 }
 
+extern int pgcache_max_age;
+extern void do_pgcache_max_age(void);
+
 static inline void touch_page(struct page *page)
 {
-       if (page->age < (MAX_PAGE_AGE - PAGE_ADVANCE))
+       int max_age = MAX_PAGE_AGE;
+
+       if (atomic_read(&page->count) == 1) {
+               static int save_max_age = 0;
+               if (save_max_age != max_age) {
+                       save_max_age = max_age;
+                       do_pgcache_max_age();
+               }
+               max_age = pgcache_max_age;
+       }
+
+       if (page->age < (max_age - PAGE_ADVANCE))
                page->age += PAGE_ADVANCE;
        else
-               page->age = MAX_PAGE_AGE;
+               page->age = max_age;
 }
 
 static inline void age_page(struct page *page)
diff -urN linux-2.1.110/include/linux/swapctl.h linux/include/linux/swapctl.h
--- linux-2.1.110/include/linux/swapctl.h       Tue Jul 21 02:32:01 1998
+++ linux/include/linux/swapctl.h       Wed Jul 22 18:04:28 1998
@@ -94,12 +94,26 @@
                return n;
 }
 
+extern int pgcache_max_age;
+extern void do_pgcache_max_age(void);
+
 static inline void touch_page(struct page *page)
 {
-       if (page->age < (MAX_PAGE_AGE - PAGE_ADVANCE))
+       int max_age = MAX_PAGE_AGE;
+
+       if (atomic_read(&page->count) == 1) {
+               static int save_max_age = 0;
+               if (save_max_age != max_age) {
+                       save_max_age = max_age;
+                       do_pgcache_max_age();
+               }
+               max_age = pgcache_max_age;
+       }
+
+       if (page->age < (max_age - PAGE_ADVANCE))
                page->age += PAGE_ADVANCE;
        else
-               page->age = MAX_PAGE_AGE;
+               page->age = max_age;
 }
 
 static inline void age_page(struct page *page)
------------------------------------------------------------------------------- 



        Werner
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
