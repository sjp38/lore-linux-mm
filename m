Message-Id: <20070504103157.465884989@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:00 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 09/40] mm: optimize gfp_to_rank()
Content-Disposition: inline; filename=mm-optimize-gtp_to_rank.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

The gfp_to_rank() call in the slab allocator severely impacts performance.
Hence reduce it to the bone, keeping only what is needed to make the reserve
work.

[more AIM9 results go here]

 AIM9 test          2.6.21-rc5            2.6.21-rc5-slab1             
                                         CONFIG_SLAB_FAIR=y            

54 tcp_test      2124.48 +/-  10.85    2137.43 +/-  9.22    12.95      
55 udp_test      5204.43 +/-  45.13    5231.59 +/- 56.66    27.16      
56 fifo_test    20991.42 +/-  46.71   19675.97 +/- 56.35  1315.44      
57 stream_pipe  10024.16 +/- 119.88    9912.53 +/- 75.52   111.63      
58 dgram_pipe    9460.18 +/- 119.50    9502.75 +/- 89.06    42.57      
59 pipe_cpy     30719.81 +/- 117.01   27885.52 +/- 46.81  2834.28      

                                          2.6.21-rc5-slab2    
                                         CONFIG_SLAB_FAIR=y   
                                                              
54 tcp_test      2124.48 +/-  10.85    2122.80 +/-   4.70     1.68
55 udp_test      5204.43 +/-  45.13    5136.98 +/-  62.31    67.45
56 fifo_test    20991.42 +/-  46.71   19646.81 +/-  53.61  1344.60
57 stream_pipe  10024.16 +/- 119.88    9940.87 +/- 280.73    83.29
58 dgram_pipe    9460.18 +/- 119.50    9432.69 +/- 250.27    27.49
59 pipe_cpy     30719.81 +/- 117.01   27870.70 +/-  65.50  2849.10

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/internal.h |   33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

Index: linux-2.6-git/mm/internal.h
===================================================================
--- linux-2.6-git.orig/mm/internal.h	2007-02-22 14:09:39.000000000 +0100
+++ linux-2.6-git/mm/internal.h	2007-02-22 14:24:34.000000000 +0100
@@ -105,9 +105,38 @@ static inline int alloc_flags_to_rank(in
 	return rank;
 }
 
-static inline int gfp_to_rank(gfp_t gfp_mask)
+static __always_inline int gfp_to_rank(gfp_t gfp_mask)
 {
-	return alloc_flags_to_rank(gfp_to_alloc_flags(gfp_mask));
+	/*
+	 * Although correct this full version takes a ~3% performance hit
+	 * on the network test in aim9.
+	 *
+	 * return alloc_flags_to_rank(gfp_to_alloc_flags(gfp_mask));
+	 *
+	 * So we go cheat a little. We'll only focus on the correctness of
+	 * rank 0.
+	 */
+
+	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
+		if (gfp_mask & __GFP_EMERGENCY)
+			return 0;
+		else if (!in_irq() && (current->flags & PF_MEMALLOC))
+			return 0;
+		/*
+		 * We skip the TIF_MEMDIE test:
+		 *
+		 * if (!in_interrupt() && unlikely(test_thread_flag(TIF_MEMDIE)))
+		 * 	return 0;
+		 *
+		 * this will force an alloc but since we are allowed the memory
+		 * that will succeed. This will make this very rare occurence
+		 * very expensive when under severe memory pressure, but it
+		 * seems a valid tradeoff.
+		 */
+	}
+
+	/* Cheat by lumping everybody else in rank 1. */
+	return 1;
 }
 
 #endif

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
