Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 597F56B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:53:16 -0500 (EST)
Date: Tue, 30 Nov 2010 13:53:11 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [thisops uV3 07/18] highmem: Use this_cpu_xx_return()
 operations
In-Reply-To: <1291145910.32004.1166.camel@laptop>
Message-ID: <alpine.DEB.2.00.1011301352390.4039@router.home>
References: <20101130190707.457099608@linux.com>  <20101130190845.216537525@linux.com>  <1291144408.2904.232.camel@edumazet-laptop>  <alpine.DEB.2.00.1011301325180.3134@router.home>  <1291145391.2904.247.camel@edumazet-laptop>
 <1291145910.32004.1166.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, Peter Zijlstra wrote:

> On Tue, 2010-11-30 at 20:29 +0100, Eric Dumazet wrote:
> >
> > well maybe a single prototype ;)
> >
> > static inline void kmap_atomic_idx_pop(void)
> > {
> > #ifdef CONFIG_DEBUG_HIGHMEM
> >         int idx = __this_cpu_dec_return(__kmap_atomic_idx);
> >         BUG_ON(idx < 0);
> > #else
> >       __this_cpu_dec(__kmap_atomic_idx);
> > #endif
> > }
>
> Right, at least a consistent prototype, the above looks fine to me.

Ok with right spacing this is:

Subject: highmem: Use this_cpu_dec instead of __this_cpu_dec_return if
!DEBUG_HIGHMEM

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/highmem.h |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h	2010-11-30 13:23:44.000000000 -0600
+++ linux-2.6/include/linux/highmem.h	2010-11-30 13:51:39.000000000 -0600
@@ -95,13 +95,15 @@ static inline int kmap_atomic_idx(void)
 	return __this_cpu_read(__kmap_atomic_idx) - 1;
 }

-static inline int kmap_atomic_idx_pop(void)
+static inline void kmap_atomic_idx_pop(void)
 {
-	int idx = __this_cpu_dec_return(__kmap_atomic_idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
+	int idx = __this_cpu_dec_return(__kmap_atomic_idx);
+
 	BUG_ON(idx < 0);
+#else
+	__this_cpu_dec(__kmap_atomic_idx);
 #endif
-	return idx;
 }

 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
