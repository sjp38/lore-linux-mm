Date: Tue, 23 Aug 2005 09:30:16 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFT][PATCH 0/2] pagefault scalability alternative
In-Reply-To: <Pine.LNX.4.61.0508230822300.5224@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.62.0508230909120.16321@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508221448480.8933@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0508230822300.5224@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Aug 2005, Hugh Dickins wrote:

> > The basic idea is to have a spinlock per page table entry it seems.
> A spinlock per page table, not a spinlock per page table entry.

Thats a spinlock per pmd? Calling it per page table is a bit confusing 
since page table may refer to the whole tree. Could you develop 
a clearer way of referring to these locks that is not page_table_lock or 
ptl?

> After dealing with the really hard issues (how to get the definitions
> and inlines into the header files without crashing the HIGHPTE build)
> yesterday, I spent several hours ruminating again on that *pmd issue,
> holding off from making a hundred edits; and in the end added just
> an unsigned long cast into the i386 definition of pmd_none.  We must
> avoid basing decisions on two mismatched halves; but pmd_present is
> already safe, and now pmd_none also.  The remaining races are benign.
> 
> What do you think?

Atomicity can be guaranteed to some degree by using the present bit. 
For an update the present bit is first switched off. When a 
new value is written, it is first written in the piece of the entry that 
does not contain the pte bit which keeps the entry "not present". Last the 
word with the present bit is written.

This means that if any p?d entry has been found to not contain the present 
bit then a lock must be taken and then the entry must be reread to get a 
consistent value.

Here are the results of the performance test. In summary these show that
the performance of both our approaches are equivalent. I would prefer your 
patches over mine since they have a broader scope and may accellerate 
other aspects of vm operations.

Note that these tests need to be taken with some caution. Results are 
topology dependent and its just one special case (allocating new
pages in do_anon_page) that is measured. Results are somewhat scewed if
the amount of memory per task (mem/threads) becomes too small so that 
there is not enough time spend in concurrent page faulting.

We only scale well up to 32 processors. Beyond that performance is still 
dropping and there is severe contention at 60. This is still better than 
to experience this drop at 4 processors (2.6.13) but not all that we 
are after. This performance pattern is typical for only dealing with
the page_table_lock.

I tried the delta patches which increase performance somewhat more but I 
do not get the performance results in the very high range that I saw last 
year. Either something is wrong with the delta patches or there is 
another other issue these days that limits performance. I still have to 
figure out what is going on there. I may know more after I test on a 
machine with more processors.

Two samples each allocating 1,4,8,16 GB with 1-60 processors.

1. 2.6.13-rc6-mm1

 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  1  3    1   1    0.06s      2.08s   2.01s 91530.726  91686.487
  1  3    2   1    0.04s      2.40s   1.03s 80313.725 148253.347
  1  3    4   1    0.04s      2.48s   0.07s 78019.048 247860.666
  1  3    8   1    0.04s      2.76s   0.05s 70217.143 336562.559
  1  3   16   1    0.07s      4.37s   0.05s 44201.439 332361.815
  1  3   32   1    5.94s     10.92s   1.00s 11650.154 180992.401
  1  3   60   1   42.57s     21.80s   2.02s  3054.057  89132.235
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  4  3    1   1    0.13s      8.28s   8.04s 93356.125  93399.776
  4  3    2   1    0.13s      9.44s   5.01s 82091.023 152346.188
  4  3    4   1    0.12s      9.80s   3.00s 79245.466 256976.998
  4  3    8   1    0.17s     10.54s   2.00s 73361.194 383107.125
  4  3   16   1    0.16s     17.06s   1.09s 45637.883 404563.542
  4  3   32   1    4.27s     42.62s   2.06s 16768.273 294151.260
  4  3   60   1   40.02s    110.99s   4.04s  5207.607 177074.387
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  8  3    1   1    0.32s     16.84s  17.01s 91637.381  91636.318
  8  3    2   1    0.32s     18.80s  10.02s 82228.356 153285.701
  8  3    4   1    0.30s     19.45s   6.00s 79630.620 261810.203
  8  3    8   1    0.34s     20.94s   4.00s 73885.006 391636.418
  8  3   16   1    0.42s     34.06s   3.07s 45600.835 417784.690
  8  3   32   1    9.57s     87.58s   5.01s 16188.390 303679.562
  8  3   60   1   37.34s    246.24s   7.07s  5546.221 202734.992
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
 16  3    1   1    0.64s     40.12s  40.07s 77161.695  77175.960
 16  3    2   1    0.64s     38.24s  20.08s 80891.998 151015.426
 16  3    4   1    0.67s     38.75s  11.09s 79784.113 263917.598
 16  3    8   1    0.62s     41.82s   7.08s 74107.802 399410.789
 16  3   16   1    0.61s     67.76s   7.03s 46003.627 429354.596
 16  3   32   1    8.76s    173.04s   9.04s 17302.854 333248.692
 16  3   60   1   32.76s    466.27s  13.03s  6303.609 235490.831

 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  1  3    1   1    0.03s      2.08s   2.01s 92739.623  92765.448
  1  3    2   1    0.02s      2.38s   1.03s 81647.841 150542.942
  1  3    4   1    0.06s      2.46s   0.07s 77649.289 247254.017
  1  3    8   1    0.05s      2.75s   0.05s 70017.094 346483.976
  1  3   16   1    0.06s      4.39s   0.06s 44161.725 313310.777
  1  3   32   1    9.02s     11.20s   1.02s  9717.675 162578.985
  1  3   60   1   28.92s     29.71s   2.01s  3353.254  93278.693
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  4  3    1   1    0.16s      8.20s   8.03s 93935.977  93937.837
  4  3    2   1    0.19s      9.33s   5.01s 82539.043 153124.158
  4  3    4   1    0.22s      9.70s   3.00s 79213.537 257326.049
  4  3    8   1    0.23s     10.48s   2.00s 73361.194 383192.157
  4  3   16   1    0.22s     16.97s   1.09s 45722.791 405459.259
  4  3   32   1    4.67s     43.56s   2.06s 16301.136 292609.111
  4  3   60   1   21.01s     99.12s   4.00s  6546.181 193120.292
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  8  3    1   1    0.28s     16.77s  17.00s 92196.014  92248.241
  8  3    2   1    0.36s     18.64s  10.02s 82747.475 154108.957
  8  3    4   1    0.36s     19.39s   6.00s 79598.381 261456.810
  8  3    8   1    0.31s     20.96s   4.00s 73898.891 392375.888
  8  3   16   1    0.37s     34.28s   3.07s 45385.042 416385.059
  8  3   32   1    8.75s     88.48s   5.01s 16175.737 303964.057
  8  3   60   1   34.85s    213.80s   7.03s  6325.563 213671.451
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
 16  3    1   1    0.63s     40.19s  40.08s 77040.752  77044.800
 16  3    2   1    0.58s     38.34s  20.08s 80800.575 150916.421
 16  3    4   1    0.71s     38.66s  11.09s 79873.248 264287.489
 16  3    8   1    0.64s     41.91s   7.08s 73905.836 399511.701
 16  3   16   1    0.64s     67.46s   7.03s 46187.350 430267.445
 16  3   32   1    8.12s    171.97s   9.04s 17466.563 333665.446
 16  3   60   1   28.56s    483.76s  13.03s  6140.067 235670.414

2. 2.6.13-rc1-mm1-hugh

 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  1  3    1   1    0.02s      2.12s   2.01s 91530.726  91290.645
  1  3    2   1    0.03s      2.40s   1.03s 80842.105 148577.211
  1  3    4   1    0.04s      2.50s   0.07s 77161.695 246742.307
  1  3    8   1    0.06s      2.74s   0.05s 69917.496 333526.774
  1  3   16   1    0.04s      4.38s   0.05s 44321.010 329911.942
  1  3   32   1    2.70s     11.10s   0.09s 14242.828 208238.299
  1  3   60   1   10.39s     25.69s   1.06s  5448.016 122221.286
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  4  3    1   1    0.20s      8.24s   8.04s 93090.909  93102.689
  4  3    2   1    0.17s      9.40s   5.01s 82125.313 152597.761
  4  3    4   1    0.18s      9.76s   3.00s 78990.759 256940.071
  4  3    8   1    0.14s     10.58s   2.00s 73361.194 383839.118
  4  3   16   1    0.18s     17.34s   1.09s 44887.671 400584.413
  4  3   32   1    3.03s     44.14s   2.06s 16670.171 296955.678
  4  3   60   1   42.77s    124.64s   4.07s  4697.360 164568.728
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  8  3    1   1    0.41s     16.72s  17.01s 91787.115  91811.036
  8  3    2   1    0.32s     18.75s  10.02s 82469.799 153767.106
  8  3    4   1    0.31s     19.49s   6.00s 79405.493 260233.329
  8  3    8   1    0.34s     21.00s   4.00s 73691.154 390162.630
  8  3   16   1    0.33s     33.82s   3.07s 46054.814 420596.124
  8  3   32   1    6.98s     87.06s   4.09s 16724.767 315990.572
  8  3   60   1   39.50s    252.83s   7.06s  5380.182 204361.061
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
 16  3    1   1    0.62s     40.28s  40.09s 76897.624  76894.371
 16  3    2   1    0.73s     38.20s  20.08s 80775.678 150731.248
 16  3    4   1    0.62s     38.86s  11.09s 79670.955 263253.128
 16  3    8   1    0.67s     41.89s   7.09s 73891.948 398115.325
 16  3   16   1    0.67s     68.00s   7.04s 45802.679 424756.786
 16  3   32   1    8.13s    170.75s   9.06s 17584.902 325968.378
 16  3   60   1   19.06s    443.08s  12.08s  6806.696 244372.117

 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  1  3    1   1    0.04s      2.08s   2.01s 92390.977  92501.417
  1  3    2   1    0.04s      2.38s   1.03s 81108.911 149261.811
  1  3    4   1    0.04s      2.48s   0.07s 77895.404 245772.564
  1  3    8   1    0.04s      2.71s   0.05s 71338.171 339935.008
  1  3   16   1    0.08s      4.41s   0.06s 43690.667 321102.290
  1  3   32   1    6.30s     10.29s   1.01s 11843.855 176712.623
  1  3   60   1   31.78s     24.45s   2.00s  3496.372  95318.257
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  4  3    1   1    0.16s      8.23s   8.03s 93622.857  93678.202
  4  3    2   1    0.17s      9.40s   5.01s 82125.313 152957.631
  4  3    4   1    0.13s      9.81s   3.00s 79022.508 256991.607
  4  3    8   1    0.16s     10.59s   2.00s 73142.857 383723.246
  4  3   16   1    0.16s     17.08s   1.09s 45616.705 404165.286
  4  3   32   1    4.28s     43.45s   2.07s 16471.850 283376.758
  4  3   60   1   55.40s    115.75s   5.00s  4594.718 156683.131
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
  8  3    1   1    0.32s     16.76s  17.00s 92044.944  92058.036
  8  3    2   1    0.29s     18.68s  10.01s 82887.015 154397.006
  8  3    4   1    0.33s     19.41s   6.00s 79662.885 262009.505
  8  3    8   1    0.32s     20.91s   3.09s 74079.879 393444.882
  8  3   16   1    0.32s     34.22s   3.07s 45521.649 417768.300
  8  3   32   1    3.44s     85.73s   4.08s 17636.959 325891.128
  8  3   60   1   56.83s    248.51s   8.02s  5150.986 191074.214
 Gb Rep Thr CLine  User      System   Wall  flt/cpu/s fault/wsec
 16  3    1   1    0.62s     40.08s  40.07s 77267.833  77269.273
 16  3    2   1    0.67s     38.21s  20.08s 80891.998 151088.966
 16  3    4   1    0.69s     38.68s  11.09s 79889.476 264299.054
 16  3    8   1    0.65s     41.70s   7.08s 74261.756 400677.914
 16  3   16   1    0.68s     68.20s   7.04s 45664.383 423956.953
 16  3   32   1    4.05s    172.59s   9.03s 17808.292 338026.854
 16  3   60   1   49.84s    458.57s  13.09s  6187.311 224887.539

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
