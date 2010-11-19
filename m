Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 003536B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:59:10 -0500 (EST)
Date: Fri, 19 Nov 2010 09:59:08 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: percpu: Implement this_cpu_add,sub,dec,inc_return
In-Reply-To: <1290181870.3034.136.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1011190958230.2360@router.home>
References: <alpine.DEB.2.00.1011091124490.9898@router.home>  <alpine.DEB.2.00.1011100939530.23566@router.home>  <1290018527.2687.108.camel@edumazet-laptop>  <alpine.DEB.2.00.1011190941380.32655@router.home> <1290181870.3034.136.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2010, Eric Dumazet wrote:

> > This isnt a use case for this_cpu_dec right? Seems that your message was
> > cut off?
> I wanted to show you the file were it was possible to use this_cpu_{dec|
> inc}_return()
>
> My patch on kmap_atomic_idx() doesnt need your new functions ;)

Oh ok you mean this:

---
 include/linux/highmem.h |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h	2010-11-19 09:55:24.000000000 -0600
+++ linux-2.6/include/linux/highmem.h	2010-11-19 09:57:54.000000000 -0600
@@ -81,7 +81,9 @@ DECLARE_PER_CPU(int, __kmap_atomic_idx);

 static inline int kmap_atomic_idx_push(void)
 {
-	int idx = __get_cpu_var(__kmap_atomic_idx)++;
+	int idx = __this_cpu_read(__kmap_atomic_idx);
+
+	__this_cpu_inc(__kmap_atomic_idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
 	WARN_ON_ONCE(in_irq() && !irqs_disabled());
 	BUG_ON(idx > KM_TYPE_NR);
@@ -91,12 +93,12 @@ static inline int kmap_atomic_idx_push(v

 static inline int kmap_atomic_idx(void)
 {
-	return __get_cpu_var(__kmap_atomic_idx) - 1;
+	return __this_cpu_read(__kmap_atomic_idx) - 1;
 }

 static inline int kmap_atomic_idx_pop(void)
 {
-	int idx = --__get_cpu_var(__kmap_atomic_idx);
+	int idx = __this_cpu_dec_return(__kmap_atomic_idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
 	BUG_ON(idx < 0);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
