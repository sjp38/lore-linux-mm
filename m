Message-ID: <3BA89562.CAED589C@earthlink.net>
Date: Wed, 19 Sep 2001 12:53:54 +0000
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: [PATCH] fix page aging (2.4.9-ac12)
References: <Pine.LNX.4.33L.0109191454570.8191-100000@imladris.rielhome.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rik,

 static inline void age_page_down(struct page *page)
 {
-       switch (vm_page_aging_tactic) {
-               case PAGE_AGE_LINEAR:
-               case PAGE_AGE_EXPUP:
-                       if (page->age)
-                               page->age -= PAGE_AGE_DECL;
-                       break;
-               case PAGE_AGE_EXPDOWN:
-               default:
-                       page->age /= 2;
-                       break;
-               case PAGE_AGE_NULL:
-               case PAGE_AGE_SINGLEBIT:
-                       page->age = 0;
-                       break;
-       }
+       unsigned long age = page->age;
+       if (age > 0)
+               age -= PAGE_AGE_DECL;
+       page->age = age;
 }

A nit: if PAGE_AGE_DECL is ever changed to be > 1
for some reason, we could end up with negative/huge
page ages (I had that problem some time ago
when experimenting with aging strategies). So
maybe an "if (age < 0) age = 0" is in order.

Cheers,

-- Joe

-- Joe Knapka
# Replace the pink stuff with net to reply.
# "You know how many remote castles there are along the
#  gorges? You can't MOVE for remote castles!" - Lu Tze re. Uberwald
# Linux MM docs:
http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
