Message-ID: <20050113202642.68138.qmail@web14325.mail.yahoo.com>
Date: Thu, 13 Jan 2005 12:26:42 -0800 (PST)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: smp_rmb in mm/memory.c in 2.6.10
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks,
                                                      
                         
I am trying to understand the usage of smp_rmb() in
mm/memory.c in 2.6.10.
                                                      
                         
This is my understanding of the relevant parts of
do_no_page():
                                                      
                         
1. If vma is file backed, snapshot truncate_count
(without holding page_table_lock).
2. smp_rmb() makes sure the above snapshot is
complete.
3. nopage() then figures out the physical address of
the file page.
4. Get page_table_lock.
5. Reread truncate_count, and decide whether to retry
operation.

What I don't understand is that in step 1,
truncate_count is read without page_table_lock, but in
step 5, it is read with page_table_lock. A consistent
approach would seem to be either always snapshot
truncate_count with page_table_lock, and hence do away
with the smp_rmb() in step 2; or always snapshot
truncate_count without page_table_lock, in which case
do not grab page_table_lock in step 4, but rather do
another smp_rmb() (page_table_lock can be grabbed as
step 6). Isn't that reasonable?

The second question is that even though truncate_count
is declared atomic (ie probably volatile on most
architectures), that does not make gcc guarantee
anything in terms of ordering, right?

Finally, does anyone really believe that a smp_rmb()
is required in step 2? My logic is that nopage() is
guaranteed to grab/release (spin)locks etc as part of
its processing, and that would force the snapshots of
truncate_count to be properly ordered.

Thanks.
 
Kanoj




		
__________________________________ 
Do you Yahoo!? 
All your favorites on one personal page ? Try My Yahoo!
http://my.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
