Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m04ClXis004558
	for <linux-mm@kvack.org>; Fri, 4 Jan 2008 07:47:33 -0500
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m04ClXOn012972
	for <linux-mm@kvack.org>; Fri, 4 Jan 2008 07:47:33 -0500
Received: from 192.168.1.105 (IDENT:U2FsdGVkX1+xuIJRPkq6iauuHUSdwyz23zSzcVIKHR0@vpn-248-13.boston.redhat.com [10.13.248.13])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id m04ClWnk001192
	for <linux-mm@kvack.org>; Fri, 4 Jan 2008 07:47:32 -0500
Subject: [PATCH] Include count of pagecache pages in show_mem() output.
From: Larry Woodman <lwoodman@redhat.com>
Content-Type: multipart/mixed; boundary="=-086NxjKLPaDWS/soOW3q"
Date: Fri, 04 Jan 2008 07:43:21 -0500
Message-Id: <1199450601.17215.2.camel@dhcp83-56.boston.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-086NxjKLPaDWS/soOW3q
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The show_mem() output does not include the total number of
pagecache pages.  This really limits the value of the debugging
information sent to the console and /var/log/messages file when OOM
kills occur. 
The attached patch includes the total pagecache pages in that output:

-------------------------------------------------
   Node 0 Normal: empty
   Node 0 HighMem: empty
> >>113032 pagecache pages
   Swap cache: add 0, delete 0, find 0/0, race 0+0
   Free swap  = 2031608kB
   Total swap = 2031608kB
   Free swap:       2031608kB
   523900 pages of RAM
   42142 reserved pages
   63864 pages shared
   0 pages swap cached
------------------------------------------------


--=-086NxjKLPaDWS/soOW3q
Content-Disposition: attachment; filename=showmem.patch
Content-Type: text/x-patch; name=showmem.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-2.6.18.noarch/mm/page_alloc.c.orig	2008-01-03 15:12:27.000000000 -0500
+++ linux-2.6.18.noarch/mm/page_alloc.c	2008-01-03 15:12:29.000000000 -0500
@@ -1359,6 +1359,8 @@ void show_free_areas(void)
 		printk("= %lukB\n", K(total));
 	}
 
+	printk("%d pagecache pages\n", global_page_state(NR_FILE_PAGES));
+
 	show_swap_cache_info();
 }
 

--=-086NxjKLPaDWS/soOW3q--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
