Message-ID: <3D3FA434.35113F60@zip.com.au>
Date: Thu, 25 Jul 2002 00:09:40 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: page_add/remove_rmap costs
References: <3D3E4A30.8A108B45@zip.com.au> <20020725045040.GD2907@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

well I tried a few things.

- Disable the pte_chain_lock stuff for uniprocessor
  builds.

- Disable the cpu_relax()

- shuffle struct page to put ->flags and ->count next
  to each other.



Uniprocessor:

c01c9138 122      0.96649     strnlen_user            
c0145860 162      1.28337     __d_lookup              
c012c2c4 179      1.41805     rmqueue                 
c010ba68 180      1.42597     timer_interrupt         
c01120ec 190      1.50519     do_page_fault           
c013d910 191      1.51311     link_path_walk          
c01052c8 219      1.73493     poll_idle               
c0132e44 227      1.7983      page_add_rmap           
c0122e00 237      1.87753     clear_page_tables       
c0111e40 264      2.09142     pte_alloc_one           
c0123018 287      2.27363     copy_page_range         
c0124324 296      2.34493     do_anonymous_page       
c012aa70 471      3.73128     kmem_cache_alloc        
c0123224 483      3.82635     zap_pte_range           
c01077c4 484      3.83427     page_fault              
c0124490 547      4.33336     do_no_page              
c012ac5c 560      4.43635     kmem_cache_free         
c0132f1c 940      7.44672     page_remove_rmap        
c0123cb0 2581     20.4468     do_wp_page              

So page_add_rmap went away.

page_remove_rmap:

 c0132f8a 1        0.106383    0        0           
 c0132f8d 1        0.106383    0        0           
 c0132f93 1        0.106383    0        0           
 c0132fa4 3        0.319149    0        0           
 c0132fa7 56       5.95745     0        0           the `for' loop
 c0132fa9 2        0.212766    0        0           
 c0132fab 4        0.425532    0        0           
 c0132fb0 13       1.38298     0        0           
 c0132fb3 574      61.0638     0        0           if (pc->ptep == ptep)
 c0132fb5 1        0.106383    0        0           
 c0132fb6 13       1.38298     0        0           
 c0132fb9 2        0.212766    0        0           
 c0132fba 4        0.425532    0        0           

And the page_remove_rmap cost is now in the list walk.


But the SMP performance is unaltered by these changes.

c0129818 1329     2.42966     do_anonymous_page       
c01338dc 1501     2.74411     page_cache_release      
c0129a10 2157     3.9434      do_no_page              
c0128128 2581     4.71855     copy_page_range         
c0128390 2655     4.85384     zap_pte_range           
c013a944 4356     7.96358     page_add_rmap           
c013aaa0 8423     15.3988     page_remove_rmap        
c0128ff8 8457     15.461      do_wp_page              

For page_remove_rmap, 32% is the pte_chain_lock, 35%
is the list walk and 12% is the pte_chain_unlock.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
