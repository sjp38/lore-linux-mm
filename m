Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A55576B002C
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 15:35:35 -0400 (EDT)
Date: Wed, 19 Oct 2011 12:35:30 -0700
From: Stephen Hemminger <shemminger@vyatta.com>
Subject: regression in /proc/self/numa_maps with huge pages
Message-ID: <20111019123530.2e59b86c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

We are working on an application that uses a library that uses
both huge pages and parses numa_maps.  This application is no longer
able to identify the socket id correctly for huge pages because the
that 'huge' is no longer part of /proc/self/numa_maps.

Basically, application sets up huge page mmaps, then reads /proc/self/numa_maps
and skips all entries without the string " huge ".  Then it looks for address
and socket info.

Why was this information dropped? Looks like the desire to be generic
overstepped the desire to remain compatible.


This regression in kernel ABI was introduced by:
commit 29ea2f6982f1edc4302729116f2246dd7b45471d
Author: Stephen Wilson <wilsons@start.ca>
Date:   Tue May 24 17:12:42 2011 -0700

    mm: use walk_page_range() instead of custom page table walking code
    
    Converting show_numa_map() to use the generic routine decouples the
    function from mempolicy.c, allowing it to be moved out of the mm subsystem
    and into fs/proc.
    
    Also, include KSM pages in /proc/pid/numa_maps statistics.  The pagewalk
    logic implemented by check_pte_range() failed to account for such pages as
    they were not applicable to the page migration case.
    
    Signed-off-by: Stephen Wilson <wilsons@start.ca>
    Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
    Cc: Hugh Dickins <hughd@google.com>
    Cc: David Rientjes <rientjes@google.com>
    Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
    Cc: Alexey Dobriyan <adobriyan@gmail.com>
    Cc: Christoph Lameter <cl@linux-foundation.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
