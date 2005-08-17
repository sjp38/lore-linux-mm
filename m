Date: Wed, 17 Aug 2005 16:12:05 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: pagefault scalability patches
In-Reply-To: <Pine.LNX.4.58.0508171559350.3553@g5.osdl.org>
Message-ID: <Pine.LNX.4.62.0508171603240.19363@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
 <Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508171559350.3553@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Aug 2005, Linus Torvalds wrote:

> On Wed, 17 Aug 2005, Christoph Lameter wrote:
> >
> > We are trading 2x (spinlock(page_table_lock), 
> > spin_unlock(page_table_lock)) against one atomic inc.
> 
> Bzzt. Thank you for playing.
> 
> Spinunlock is free on x86 and x86-64, since it's a plain normal store. The 
> x86 memory ordering semantics take care of the rest.

The same is basically true for ia64 (there is an additional memory barrier 
since ordering must be enforced at that point)

> In other words, one uncontended spinlock/unlock pair is pretty much
> _exactly_ the same cost as one single atomic operation, and there is no 
> win.

We have no problems if the lock are not contended. Then we just reduce the 
overhead by eliminating one semaphore instruction.

If they are contended then spinlock/unlock serializes the page 
fault handler.

Numbers:

Unpatched:

 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
 16   3    1    0.757s     62.772s  63.052s 49515.393  49522.112
 16   3    2    0.674s     68.268s  36.048s 45627.693  86230.400
 16   3    4    0.649s     66.478s  20.061s 46861.663 152603.033
 16   3    8    0.666s    179.611s  25.096s 17449.372 121159.869
 16   3   16    0.721s    545.957s  38.015s  5754.251  82456.599
 16   3   32    1.327s   1718.947s  59.083s  1828.620  52573.584
 16   3   64    3.181s   5260.674s  93.047s   597.609  33651.618
 16   3  128   15.966s  19392.742s 163.090s   162.078  19192.626
 16   3  256   18.214s   9994.286s  84.077s   314.180  37105.725
 16   3  512   13.866s   5023.788s  42.063s   624.443  73776.955

Page fault patches

 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
  4   3    1    0.153s     12.314s  12.047s 63077.153  63065.474
  4   3    2    0.155s     10.430s   5.074s 74290.224 136812.728
  4   3    4    0.157s      9.377s   2.095s 82477.064 266154.766
  4   3    8    0.164s     10.348s   2.002s 74807.804 388714.846
  4   3   16    0.250s     20.687s   2.017s 37560.913 360858.481
  4   3   32    0.568s     43.941s   2.034s 17668.743 335334.362
  4   3   64    2.954s     95.528s   2.066s  7985.502 294723.687
  4   3  128   15.449s    259.534s   3.053s  2859.924 222310.352
  4   3  256   16.108s    137.784s   2.019s  5110.263 357984.896
  4   3  512   14.083s     82.377s   1.049s  8152.851 527180.088

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
