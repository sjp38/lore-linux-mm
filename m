Received: from adsl-64-161-28-170.dsl.sntc01.pacbell.net ([64.161.28.170] helo=zip.com.au)
	by www.linux.org.uk with esmtp (Exim 3.33 #5)
	id 17XFa3-0003PM-00
	for linux-mm@kvack.org; Wed, 24 Jul 2002 07:25:04 +0100
Message-ID: <3D3E4A30.8A108B45@zip.com.au>
Date: Tue, 23 Jul 2002 23:33:20 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: page_add/remove_rmap costs
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Been taking a look at the page_add_rmap/page_remove_rmap cost in 2.5.27
on the quad pIII.  The workload is ten instances of this script running
concurrently:

#!/bin/sh

doit()
{
	( cat $1 | wc -l )
}
	
count=0
	
while [ $count != 500 ]
do
	doit foo > /dev/null
	count=$(expr $count + 1)
done
echo done


It's just a ton of forking and exitting.

	
With rmap oprofile says:

./doitlots.sh 10  41.67s user 95.04s system 398% cpu 34.338 total

c0133030 317      1.07963     __free_pages_ok         
c0131428 375      1.27716     kmem_cache_free         
c01342d0 432      1.47129     free_page_and_swap_cache 
c01281d0 461      1.57006     clear_page_tables       
c013118c 462      1.57346     kmem_cache_alloc        
c012a08c 470      1.60071     handle_mm_fault         
c0113e50 504      1.7165      pte_alloc_one           
c0107b68 512      1.74375     page_fault              
c012c718 583      1.98556     find_get_page           
c01332cc 650      2.21375     rmqueue                 
c0129bc4 807      2.74845     do_anonymous_page       
c013396c 851      2.8983      page_cache_release      
c0129db0 1124     3.82808     do_no_page              
c0128750 1164     3.96431     zap_pte_range           
c01284f8 1374     4.67952     copy_page_range         
c013a994 1590     5.41516     page_add_rmap           
c013aa5c 3739     12.7341     page_remove_rmap        
c01293bc 5106     17.3898     do_wp_page              

And without rmap it says:

./doitlots.sh 10  43.01s user 76.19s system 394% cpu 30.222 total

c013074c 238      1.20592     lru_cache_add           
c0144e90 251      1.27179     link_path_walk          
c0112a64 252      1.27685     do_page_fault           
c0132b0c 252      1.27685     free_page_and_swap_cache 
c01388b4 261      1.32246     do_page_cache_readahead 
c01e0700 296      1.4998      radix_tree_lookup       
c01263e0 300      1.52006     clear_page_tables       
c01319b0 302      1.5302      __free_pages_ok         
c01079f8 395      2.00142     page_fault              
c012a8a8 396      2.00649     find_get_page           
c01127d4 401      2.03182     pte_alloc_one           
c0131ca0 451      2.28516     rmqueue                 
c0127cc8 774      3.92177     do_anonymous_page       
c013230c 933      4.7274      page_cache_release      
c0126880 964      4.88448     zap_pte_range           
c012662c 1013     5.13275     copy_page_range         
c0127e70 1138     5.76611     do_no_page              
c012750c 4485     22.725      do_wp_page              

So that's a ton of CPU time lost playing with pte chains.

I instrumented it all up with the `debug.patch' from
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.27/

./doitlots.sh 5

(gdb) p rmap_stats
$3 = {page_add_rmap = 4106673, page_add_rmap_nope = 20009, page_add_rmap_1st = 479482, 
  page_add_rmap_2nd = 357745, page_add_rmap_3rd = 3618421, page_remove_rmap = 4119825, 
  page_remove_rmap_1st = 479263, page_remove_rmap_nope = 20001, add_put_dirty_page = 8742, 
  add_copy_page_range = 2774954, add_do_wp_page = 272151, add_do_swap_page = 0, add_do_anonymous_page = 93689, 
  add_do_no_page = 1029498, add_copy_one_pte = 0, remove_zap_pte_range = 3863194, remove_do_wp_page = 272880, 
  remove_copy_one_pte = 0, do_no_page = 1119244, do_swap_page = 0, do_wp_page = 423034, 
  nr_copy_page_ranges = 174521, nr_forks = 12477}

What we see here is:

- We did 12477 forks
- those forks called copy_page_range() 174,521 times in total
- Of the 4,106,673 calls to page_add_rmap, 2,774,954 came from
  copy_page_range and 1,029,498 came from do_no_page.
- Of the 4,119,825 calls to page_remove_rmap(), 3,863,194 came
  from zap_page_range().

So it's pretty much all happening in fork() and exit().

Instruction-level profiling of page_add_rmap shows:

c013ab24 4074     8.63026     0        0           page_add_rmap           
 c013ab24 11       0.270005    0        0           
 c013ab25 67       1.64458     0        0           
 c013ab28 12       0.294551    0        0           
 c013ab29 12       0.294551    0        0           
 c013ab2b 1        0.0245459   0        0           
 c013ab2d 8        0.196367    0        0           
 c013ab38 313      7.68287     0        0           
 c013ab3e 7        0.171821    0        0           
 c013ab40 1        0.0245459   0        0           
 c013ab43 6        0.147275    0        0           
 c013ab46 1        0.0245459   0        0           
 c013ab4e 5        0.12273     0        0           
 c013ab53 5        0.12273     0        0           
 c013ab58 7        0.171821    0        0           
 c013ab5d 1364     33.4806     0        0           (pte_chain_lock)
 c013ab61 4        0.0981836   0        0           
 c013ab63 13       0.319097    0        0           
 c013ab66 14       0.343643    0        0           
 c013ab69 1        0.0245459   0        0           
 c013ab6b 17       0.41728     0        0           
 c013ab70 2        0.0490918   0        0           
 c013ab73 41       1.00638     0        0           
 c013ab78 8        0.196367    0        0           
 c013ab7a 1        0.0245459   0        0           
 c013ab7f 4        0.0981836   0        0           
 c013ab84 16       0.392734    0        0           
 c013ab87 1        0.0245459   0        0           
 c013ab9a 102      2.50368     0        0           
 c013aba0 33       0.810015    0        0           
 c013aba4 33       0.810015    0        0           
 c013aba6 3        0.0736377   0        0           
 c013abab 13       0.319097    0        0           
 c013abb0 8        0.196367    0        0           
 c013abb3 2        0.0490918   0        0           
 c013abb5 7        0.171821    0        0           
 c013abb8 2        0.0490918   0        0           
 c013abbe 247      6.06284     0        0           
 c013abc0 1        0.0245459   0        0           
 c013abc3 6        0.147275    0        0           
 c013abcd 55       1.35002     0        0           
 c013abd3 39       0.95729     0        0           
 c013abd8 1        0.0245459   0        0           
 c013abdd 1468     36.0334     0        0           (pte_chain_unlock)
 c013abe7 46       1.12911     0        0           
 c013abea 9        0.220913    0        0           
 c013abf0 42       1.03093     0        0           
 c013abf4 4        0.0981836   0        0           
 c013abf5 3        0.0736377   0        0           
 c013abf8 8        0.196367    0        0           

And page_remove_rmap():

c013abfc 6600     13.9813     0        0           page_remove_rmap        
 c013abfc 5        0.0757576   0        0           
 c013abfd 10       0.151515    0        0           
 c013ac00 1        0.0151515   0        0           
 c013ac01 23       0.348485    0        0           
 c013ac02 21       0.318182    0        0           
 c013ac06 2        0.030303    0        0           
 c013ac08 1        0.0151515   0        0           
 c013ac11 339      5.13636     0        0           
 c013ac17 9        0.136364    0        0           
 c013ac20 1        0.0151515   0        0           
 c013ac26 5        0.0757576   0        0           
 c013ac2b 5        0.0757576   0        0           
 c013ac36 1        0.0151515   0        0           
 c013ac40 20       0.30303     0        0           
 c013ac45 3        0.0454545   0        0           
 c013ac4a 2399     36.3485     0        0           (The pte_chain_lock)
 c013ac50 18       0.272727    0        0           
 c013ac53 13       0.19697     0        0           
 c013ac58 15       0.227273    0        0           
 c013ac60 3        0.0454545   0        0           
 c013ac63 50       0.757576    0        0           
 c013ac68 28       0.424242    0        0           
 c013ac6d 6        0.0909091   0        0           
 c013ac80 32       0.484848    0        0           
 c013ac86 42       0.636364    0        0           
 c013ac94 3        0.0454545   0        0           
 c013ac97 11       0.166667    0        0           
 c013ac99 3        0.0454545   0        0           
 c013ac9b 1        0.0151515   0        0           
 c013aca0 10       0.151515    0        0           (The `for (pc = page->pte.chain)' loop)
 c013aca3 2633     39.8939     0        0           
 c013aca5 5        0.0757576   0        0           
 c013aca6 23       0.348485    0        0           
 c013aca7 2        0.030303    0        0           
 c013aca8 2        0.030303    0        0           
 c013acad 15       0.227273    0        0           
 c013acb0 29       0.439394    0        0           
 c013acb6 218      3.30303     0        0           
 c013acbb 2        0.030303    0        0           
 c013acbe 3        0.0454545   0        0           
 c013acc3 20       0.30303     0        0           
 c013accd 1        0.0151515   0        0           
 c013acd0 6        0.0909091   0        0           
 c013acd2 2        0.030303    0        0           
 c013acd4 2        0.030303    0        0           
 c013acd6 12       0.181818    0        0           
 c013ace0 7        0.106061    0        0           
 c013ace5 1        0.0151515   0        0           
 c013acea 6        0.0909091   0        0           
 c013acf3 34       0.515152    0        0           
 c013acf8 1        0.0151515   0        0           
 c013acfd 411      6.22727     0        0           (Probably the pte_chain_unlock)
 c013ad03 4        0.0606061   0        0           
 c013ad04 57       0.863636    0        0           
 c013ad05 10       0.151515    0        0           
 c013ad06 6        0.0909091   0        0           
 c013ad09 8        0.121212    0        0           

The page_add_rmap() one is interesting - the pte_chain_unlock() is as expensive
as the pte_chain_lock().  Which would tend to indicate either that the page->flags
has expired from cache or some other CPU has stolen it.

It is interesting to note that the length of the pte_chain is not a big
factor in all of this.  So changing the singly-linked list to something
else probably won't help much.

Instrumentation of pte_chain_lock() shows:

nr_chain_locks =         8152300
nr_chain_lock_contends =   22436
nr_chain_lock_spins =    1946858

So the lock is only contended 0.3% of the time.  And when it _is_
contended, the waiting CPU spins an average of 87 loops.

Which leaves one to conclude that the page->flags has just been
naturally evicted out of cache.  So the next obvious step is to move a
lot of code out of the locked regions.

debug.patch moves the kmem_cache_alloc() and kmem_cache_free() calls
outside the locked region.  But it doesn't help.

So I don't know why the pte_chain_unlock() is so expensive in there.
But even if it could be fixed, we're still too slow.


My gut feel here is that this will be hard to tweak - some algorithmic
change will be needed.

The pte_chains are doing precisely zilch but chew CPU cycles with this
workload.  The machine has 2G of memory free.  The rmap is pure overhead.

Would it be possible to not build the pte_chain _at all_ until it is
actually needed?  Do it lazily?  So in the page reclaim code, if the
page has no rmap chain we go off and build it then?  This would require
something like a pfn->pte lookup function at the vma level, and a
page->vmas_which_own_me lookup.

Nice thing about this is that a) we already have page->flags
exclusively owned at that time, so the pte_chain_lock() _should_ be
cheap.  And b) if the rmap chain is built in this way, all the
pte_chain structures against a page will have good
locality-of-reference, so the chain walk will involve far fewer cache
misses.

Then again, if the per-vma pfn->pte lookup is feasible, we may not need
the pte_chain at all...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
