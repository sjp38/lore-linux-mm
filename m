Date: Sat, 22 May 2004 14:48:57 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: current -linus tree dies on x86_64
Message-Id: <20040522144857.3af1fc2c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

As soon as I put in enough memory pressure to start swapping it oopses in
release_pages().  ppc64, ia64 and ia32 are working OK.  Is anyone else
seeing this?

I'd be suspecting the atomic_add_negative() and atomic_inc_and_test()
implementations, but they look OK.



Unable to handle kernel paging request at 00000000063c6470 RIP: 
<ffffffff80165c1c>{release_pages+60}PML4 17d79b067 PGD 17a498067 PMD 0 
Oops: 0000 [1] SMP                                                     
CPU 0              
Modules linked in:
Pid: 6990, comm: usemem Not tainted 2.6.6
RIP: 0010:[<ffffffff80165c1c>] <ffffffff80165c1c>{release_pages+60}
RSP: 0000:000001017a46f738  EFLAGS: 00010287                       
RAX: 0000000000000000 RBX: 00000000063c6470 RCX: 0000000000000000
RDX: 0000000000000001 RSI: 0000000000000010 RDI: 000001017a46fa90
RBP: 0000000000000000 R08: 000001017a46fbb8 R09: 0000000000000000
R10: 000001017a46fbb8 R11: 0000000000000180 R12: 0000000000000000
R13: 0000000000000010 R14: 000001017a46fa90 R15: 000001017a46f748
FS:  0000002a9588d6e0(0000) GS:ffffffff805adf00(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b                           
CR2: 00000000063c6470 CR3: 0000000000101000 CR4: 00000000000006e0
Process usemem (pid: 6990, threadinfo 000001017a46e000, task 000001017d58e430)
Stack: 0000000000000001 0000000000000246 0000000100000000 0000000000000246    
       000001017a46f7a8 0000000000000286 0000000000000010 0000000000000286 
       0000000100000001 ffffffff804cb340                                   
Call Trace:<ffffffff80166207>{__pagevec_release+23} <ffffffff80167146>{shrink_zone+1382} 
       <ffffffff8016c2f3>{handle_mm_fault+435} <ffffffff8016c2f3>{handle_mm_fault+435}   
       <ffffffff80158dde>{find_get_page+94} <ffffffff8017e50f>{__find_get_block_slow+79} 
       <ffffffff8017f2fc>{__find_get_block+412} <ffffffff80244f3b>{rb_insert_color+107}  
       <ffffffff80181b7f>{__getblk+31} <ffffffff80181bb6>{__bread+6}                    
       <ffffffff801d87c2>{search_by_key+130} <ffffffff801dcd3e>{get_cnode+142} 
       <ffffffff801def85>{journal_mark_dirty+341} <ffffffff801d8723>{pathrelse+51} 
       <ffffffff801681c0>{try_to_free_pages+272} <ffffffff8015d351>{__alloc_pages+529} 
       <ffffffff8016c811>{handle_mm_fault+1745} <ffffffff801223e0>{do_page_fault+0}    
       <ffffffff8012258a>{do_page_fault+426} <ffffffff803e6835>{schedule+197}       
       <ffffffff801102d9>{error_exit+0}                                       
                                        
Code: 8b 03 f6 c4 08 0f 85 7b 01 00 00 8b 43 04 ff c0 75 12 0f 0b 
RIP <ffffffff80165c1c>{release_pages+60} RSP <000001017a46f738>   
CR2: 00000000063c6470                                          
 <1>Unable to handle kernel paging request at 00000000063c2848 RIP: 
<ffffffff80165c1c>{release_pages+60}PML4 17d111067 PGD 17d5cf067 PMD 0 
Oops: 0000 [2] SMP                                                     
CPU 1              
Modules linked in:
Pid: 59, comm: kswapd0 Not tainted 2.6.6
RIP: 0010:[<ffffffff80165c1c>] <ffffffff80165c1c>{release_pages+60}
RSP: 0018:000001007fc83868  EFLAGS: 00010287                       
RAX: 0000000000000000 RBX: 00000000063c2848 RCX: 0000000000000000
RDX: 0000000000000001 RSI: 0000000000000010 RDI: 000001007fc83bc0
RBP: 0000000000000000 R08: 000001007fc83d48 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000010 R14: 000001007fc83bc0 R15: 000001007fc83878
FS:  0000000000000000(0000) GS:ffffffff805adf80(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b                           
CR2: 00000000063c2848 CR3: 000000017ff9f000 CR4: 00000000000006e0
Process kswapd0 (pid: 59, threadinfo 000001007fc82000, task 000001007fd78370)
Stack: 0000000000000000 0000000000000000 0000000100000000 0000000000000000   
       0000000000000000 0000000000000000 0000000000000000 0000000000000000 
       000001007fc83d48 000001007fc83c68                                   
Call Trace:<ffffffff80166207>{__pagevec_release+23} <ffffffff80167146>{shrink_zone+1382} 
       <ffffffff8016849a>{balance_pgdat+442} <ffffffff80168715>{kswapd+325}              
       <ffffffff80136080>{autoremove_wake_function+0} <ffffffff80136080>{autoremove_wake_function+0} 
       <ffffffff8011048f>{child_rip+8} <ffffffff801685d0>{kswapd+0}                                  
       <ffffffff80110487>{child_rip+0}                              
                                       
Code: 8b 03 f6 c4 08 0f 85 7b 01 00 00 8b 43 04 ff c0 75 12 0f 0b 
RIP <ffffffff80165c1c>{release_pages+60} RSP <000001007fc83868>   
CR2: 00000000063c2848                                          
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
