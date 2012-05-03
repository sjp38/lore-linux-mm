Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id E88396B00F1
	for <linux-mm@kvack.org>; Thu,  3 May 2012 11:03:37 -0400 (EDT)
Message-ID: <4FA29E49.8050801@ubuntu.com>
Date: Thu, 03 May 2012 11:03:37 -0400
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Accounting for missing ( bootmem? ) memory
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I've been trying to track down why free always seems to report a little 
less total ram than it should, compared to the total usable areas in the 
e820 memory map.  I have been reading mm/bootmem.c and it seems that the 
low memory zone is managed by this allocator prior to mm_init(), and 
then free_all_bootmem() is called, which releases all free bootmem pages 
to mm to handle, and adds that space to totalram_pages.  That means that 
any bootmem that is still allocated is lost from the totalram_pages count.

I'm trying to figure out what is consuming this bootmem.  Based on 
comments in bootmem.c, the memory is initially marked as allocated, and 
setup_arch() has to explicitly free any that isn't reserved, presumably 
for things like the kernel itself, and the initrd, and any reserved 
areas in the e820 map, but I can not find where this is done.

So my questions are:

1)  Where is the bootmem initially freed ( so I can see what sections 
are *not* initially freed )

2)  Why is all of the bootmem not reserved in the e820 map not 
eventually freed and turned over to mm to manage?

3)  How can I see what is allocating and never freeing bootmem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
