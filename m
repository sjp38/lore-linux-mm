Message-ID: <41E9E5B6.1020306@yahoo.com.au>
Date: Sun, 16 Jan 2005 14:55:34 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
References: <20050113061401.GA7404@blackham.com.au> <41E61479.5040704@yahoo.com.au> <20050113085626.GA5374@blackham.com.au> <20050113101426.GA4883@blackham.com.au> <41E8ED89.8090306@yahoo.com.au> <1105785254.13918.4.camel@desktop.cunninghams> <41E8F313.4030102@yahoo.com.au> <1105786115.13918.9.camel@desktop.cunninghams> <41E8F7F7.1010908@yahoo.com.au> <20050115124018.GA24653@blackham.com.au> <20050115125311.GA19055@blackham.com.au>
In-Reply-To: <20050115125311.GA19055@blackham.com.au>
Content-Type: multipart/mixed;
 boundary="------------060809080903080000000900"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bernard Blackham <bernard@blackham.com.au>
Cc: ncunningham@linuxmail.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060809080903080000000900
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Bernard Blackham wrote:
> On Sat, Jan 15, 2005 at 08:40:18PM +0800, Bernard Blackham wrote:
> 
>>On Sat, Jan 15, 2005 at 10:01:11PM +1100, Nick Piggin wrote:
>>
>>>Also, Bernard, can you try running with the following patch and
>>>see what output it gives when you reproduce the problem?
>>
>>On resuming:
> 
> 
> And now with higher debug info that may prove useful (balance_pgdat
> firing as soon as kswapd woken):
> 
> *** Cleaning up...
> Free memory at 'out': 59157.
> Last free mem was 59157. Is now 59156. I/O info        value 0 now -1.
> Free memory at start of free_pagedir_data: 59156.
> Last free mem was 59156. Is now 60013. Checksum pages  value 1 now 857.
> Free memory at end of free_pagedir: 60013.
> Pageset size1 was 3057; size2 was 2330.
> Free memory after freeing pagedir data: 60013.
> Thawing tasks
> Waking     4: khelper.
> Waking     5: kthread.
> Waking     6: kacpid.
> Waking     8: pdflush.
> Waking    11: aio/0.
> Waking    10: kswapd0.
> Wakikswapd: balance_pgdat, order = 10

Someone asked for an order 10 allocation by the looks.

This might tell us what happened.

--------------060809080903080000000900
Content-Type: text/plain;
 name="kswapd-debug"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kswapd-debug"

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2005-01-16 14:52:42.753380598 +1100
+++ linux-2.6/mm/vmscan.c	2005-01-16 14:54:28.468932870 +1100
@@ -1194,6 +1194,11 @@
 {
 	pg_data_t *pgdat;
 
+	if (order >= 8) {
+		printk("wakeup_kswapd(order = %d)\n", order);
+		dump_stack();
+	}
+	
 	if (zone->present_pages == 0)
 		return;
 

--------------060809080903080000000900--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
