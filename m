From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199907062350.QAA99139@google.engr.sgi.com>
Subject: Re: [PATCH] 2.3.10 pre4 SMP/vm fixes
Date: Tue, 6 Jul 1999 16:50:24 -0700 (PDT)
In-Reply-To: <199907062049.NAA59707@google.engr.sgi.com> from "Kanoj Sarcar" at Jul 6, 99 01:49:55 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

Couple of updates on the patches I posted earlier today ...

Kanoj

> 
> 
> 3. kswapd needs to grab the mm spinlock earlier, to prevent other
> access/updates (like from file truncation), once we have removed
> the kernel_lock from those paths.
>

This patch is strictly not needed, since the kswapd code reverifies
with the mm spinlock whether it has still got the old pte contents.
Although it might be cleaner to do everything under the lock ...
Not to mention that I generated the patch in the wrong order ...

> 
> --- mm/vmscan.c	Tue Jul  6 11:31:47 1999
> +++ /tmp/vmscan.c	Tue Jul  6 11:29:49 1999
> @@ -39,7 +39,6 @@
>  	unsigned long page_addr;
>  	struct page * page;
>  
> -	spin_lock(&tsk->mm->page_table_lock);
>  	pte = *page_table;
>  	if (!pte_present(pte))
>  		goto out_failed;
> @@ -48,8 +47,9 @@
>  		goto out_failed;
>  
>  	page = mem_map + MAP_NR(page_addr);
> +	spin_lock(&tsk->mm->page_table_lock);
>  	if (pte_val(pte) != pte_val(*page_table))
> -		goto out_failed;
> +		goto out_failed_unlock;
>  
>  	/*
>  	 * Dont be too eager to get aging right if
> @@ -62,13 +62,13 @@
>  		 */
>  		set_pte(page_table, pte_mkold(pte));
>  		set_bit(PG_referenced, &page->flags);
> -		goto out_failed;
> +		goto out_failed_unlock;
>  	}
>  
>  	if (PageReserved(page)
>  	    || PageLocked(page)
>  	    || ((gfp_mask & __GFP_DMA) && !PageDMA(page)))
> -		goto out_failed;
> +		goto out_failed_unlock;
>  
>  	/*
>  	 * Is the page already in the swap cache? If so, then
> @@ -86,7 +86,7 @@
>  		vma->vm_mm->rss--;
>  		flush_tlb_page(vma, address);
>  		__free_page(page);
> -		goto out_failed;
> +		goto out_failed_unlock;
>  	}
>  
>  	/*
> @@ -113,7 +113,7 @@
>  	 * locks etc.
>  	 */
>  	if (!(gfp_mask & __GFP_IO))
> -		goto out_failed;
> +		goto out_failed_unlock;
>  
>  	/*
>  	 * Ok, it's really dirty. That means that
> @@ -174,8 +174,9 @@
>  out_free_success:
>  	__free_page(page);
>  	return 1;
> -out_failed:
> +out_failed_unlock:
>  	spin_unlock(&tsk->mm->page_table_lock);
> +out_failed:
>  	return 0;
>  }
>  
> 
> 4. Now that smp_flush_tlb can not rely on kernel_lock for single
> threading (eg from mremap()), it is safest to introduce a new lock 
> to provide this protection. Without this lock, at best, irritating 
> messages about stuck TLB IPIs will be generated on concurrent 
> smp_flush_tlb()s. (I can not guess at worst case scenarios).
> I have not attempted to look at the flush_cache_range/flush_tlb_range
> type operations for other processors to determine whether they
> would need similar protection.
>

An alternate solution that Alan Cox pointed out (which I wasn't feeling
too sure about initially):


--- /usr/tmp/p_rdiff_a00CAe/smp.c	Tue Jul  6 16:41:58 1999
+++ arch/i386/kernel/smp.c	Tue Jul  6 15:25:02 1999
@@ -1592,7 +1592,7 @@
 		 * locked or.
 		 */
 
-		smp_invalidate_needed = cpu_online_map;
+		set_bits(cpu_online_map, &smp_invalidate_needed);
 
 		/*
 		 * Processors spinning on some lock with IRQs disabled
--- /usr/tmp/p_rdiff_a00G6P/bitops.h	Tue Jul  6 16:42:26 1999
+++ include/asm-i386/bitops.h	Tue Jul  6 15:31:36 1999
@@ -49,6 +49,14 @@
 		:"Ir" (nr));
 }
 
+extern __inline__ void set_bits(int orval, volatile void * addr)
+{
+	__asm__ __volatile__( LOCK_PREFIX
+		"orl %1,%0"
+		:"=m" (ADDR)
+		:"r" (orval));
+}
+
 extern __inline__ void clear_bit(int nr, volatile void * addr)
 {
 	__asm__ __volatile__( LOCK_PREFIX

> 
> --- arch/i386/kernel/smp.c	Tue Jul  6 10:52:32 1999
> +++ /tmp/smp.c	Tue Jul  6 11:49:54 1999
> @@ -91,6 +91,9 @@
>  /* Kernel spinlock */
>  spinlock_t kernel_flag = SPIN_LOCK_UNLOCKED;
>  
> +/* SMP tlb flush spinlock */
> +spinlock_t tlbflush_lock = SPIN_LOCK_UNLOCKED;
> +
>  /*
>   * function prototypes:
>   */
> @@ -1583,6 +1586,9 @@
>  	 * until the AP CPUs have booted up!
>  	 */
>  	if (cpu_online_map) {
> +
> +		spin_lock(&tlbflush_lock);
> +
>  		/*
>  		 * The assignment is safe because it's volatile so the
>  		 * compiler cannot reorder it, because the i586 has
> @@ -1624,6 +1630,7 @@
>  			}
>  		}
>  		__restore_flags(flags);
> +		spin_unlock(&tlbflush_lock);
>  	}
>  
>  	/*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
