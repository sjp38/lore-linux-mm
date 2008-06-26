Message-Id: <20080626003632.049547282@sgi.com>
Date: Wed, 25 Jun 2008 17:36:32 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 0/5] [RFC] Conversion of reverse map locks to semaphores
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: apw@shadowen.org, Hugh Dickins <hugh@veritas.com>, holt@sgi.com, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

(This is going to be the last patchset that I post from clameter@sgi.com.
Please use cl@linux-foundation.org in the future.)

Having semaphores there instead of spinlocks is useful since it
allows sleeping in various code paths. That sleeping is useful
if one wants to implement callbacks to remove external mapping
(like done in the mmu notifier).

Also it seems that a semaphore helps RT and should avoid busy spinning
on systems where these locks experience significant contention.

The first patches move tlb flushing around in such a way that
the _lock's can always be taken in preemptible contexts.

The i_mmap_sem used to be present until someone switched it to a spinlock in
2004 due to scaling concerns on NUMA with a benchmark called SDET. I was not
able to locate that benchmark (but Andi Whitcroft has access and promised me
some results).

AIM9 results (3 samples) anon_vma conversion not applied:

 5 exec_test    1048.95 1025.50     -23.45 -2.24% Program Loads/second
 6 fork_test    4775.22 4945.16     169.94  3.56% Task Creations/second

 5 exec_test    1057.00 1019.00     -38.00 -3.60% Program Loads/second
 6 fork_test    4930.14 4760.00    -170.14 -3.45% Task Creations/second

 5 exec_test    1047.50 1038.96      -8.54 -0.82% Program Loads/second
 6 fork_test    4760.48 4925.07     164.59  3.46% Task Creations/second

Loads per second seem to have down tendency. Task creations are up. Not sure
how much jitter gets into it.

The old page fault performance test on file backed pages
(anon_vma conversion not applied, 250k per process):

Before:
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  0  3    1   1    0.00s      0.08s   0.00s261555.860 246536.848
  0  3    2   1    0.00s      0.09s   0.00s219709.015 357800.362
  0  3    4   1    0.19s      0.13s   0.01s 67810.629 218846.742
  0  3    8   1    1.04s      0.21s   0.02s 17548.427 104461.093

After:
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  0  3    1   1    0.00s      0.09s   0.00s238813.108 243323.477
  0  3    2   1    0.00s      0.10s   0.00s219706.818 354671.772
  0  3    4   1    0.20s      0.13s   0.00s 64619.728 225528.586
  0  3    8   1    1.09s      0.22s   0.02s 16644.421 101027.423

A slight performance degradation in most regimes, just 4 processors
is a bright spot.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
