Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA16878
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 16:26:51 -0400
Date: Tue, 6 Apr 1999 22:26:20 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <m11zhxyb4h.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.4.05.9904062119441.1277-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 6 Apr 1999, Eric W. Biederman wrote:

>>> --- linux/include/linux/mm.h	Tue Mar  9 01:55:28 1999
>>> +++ mm.h	Tue Apr  6 02:00:22 1999
>>> @@ -131,0 +133,6 @@
>>> +#ifdef __SMP__
>>> +	/* cacheline alignment */
>>> +	char dummy[(sizeof(void *) * 7 +
>>> +		    sizeof(unsigned long) * 2 +
>>> +		    sizeof(atomic_t)) % L1_CACHE_BYTES];
>>> +#endif
>
>Am I the only one to notice that this little bit of code is totally wrong.
>It happens to get it right for cache sizes of 16 & 32 with the current struct
>page but the code is 100% backwords.

Does something like this looks like better?

Index: mm/page_alloc.c
===================================================================
RCS file: /var/cvs/linux/mm/page_alloc.c,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 page_alloc.c
--- page_alloc.c	1999/01/26 18:32:27	1.1.1.3
+++ linux/mm/page_alloc.c	1999/04/06 20:04:59
@@ -315,7 +315,7 @@
 	freepages.min = i;
 	freepages.low = i * 2;
 	freepages.high = i * 3;
-	mem_map = (mem_map_t *) LONG_ALIGN(start_mem);
+	mem_map = (mem_map_t *) L1_CACHE_ALIGN(start_mem);
 	p = mem_map + MAP_NR(end_mem);
 	start_mem = LONG_ALIGN((unsigned long) p);
 	memset(mem_map, 0, start_mem - (unsigned long) mem_map);
Index: include/linux/mm.h
===================================================================
RCS file: /var/cvs/linux/include/linux/mm.h,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 mm.h
--- mm.h	1999/03/09 00:55:28	1.1.1.4
+++ linux/include/linux/mm.h	1999/04/06 20:24:43
@@ -129,6 +129,14 @@
 	struct wait_queue *wait;
 	struct page **pprev_hash;
 	struct buffer_head * buffers;
+#ifdef	__SMP__
+#define	MEM_MAP_L1_WRAP ((sizeof(void *) * 7 +			\
+			  sizeof(unsigned long) * 2 +		\
+			  sizeof(atomic_t)) % L1_CACHE_BYTES)
+	/* cacheline alignment */
+	char dummy[MEM_MAP_L1_WRAP ? L1_CACHE_BYTES - MEM_MAP_L1_WRAP : 0];
+#undef	MEM_MAP_L1_WRAP
+#endif
 } mem_map_t;
 
 /* Page flag bit values */



Thanks.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
