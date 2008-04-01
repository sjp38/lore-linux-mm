From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlb: vmstat events for huge page allocations
Date: Tue, 1 Apr 2008 13:52:04 -0700
Message-ID: <20080401135204.d3aff907.akpm@linux-foundation.org>
References: <1206978548.8042.7.camel@grover.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761919AbYDAVFL@vger.kernel.org>
In-Reply-To: <1206978548.8042.7.camel@grover.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: ebmunson@us.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, agl@us.ibm.com
List-Id: linux-mm.kvack.org

On Mon, 31 Mar 2008 23:49:08 +0800
Eric B Munson <ebmunson@us.ibm.com> wrote:

> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -25,6 +25,12 @@
>  #define HIGHMEM_ZONE(xx)
>  #endif
>  
> +#ifdef CONFIG_HUGETLB_PAGE
> +#define HTLB_STATS	HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
> +#else
> +#define HTLB_STATS
> +#endif
> +
>  #define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) , xx##_MOVABLE
>  
>  enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> @@ -36,7 +42,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		FOR_ALL_ZONES(PGSCAN_KSWAPD),
>  		FOR_ALL_ZONES(PGSCAN_DIRECT),
>  		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
> -		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> +		PAGEOUTRUN, ALLOCSTALL, PGROTATED, HTLB_STATS
>  		NR_VM_EVENT_ITEMS
>  };

The requirement that HTLB_STATS not have a comma after it is just a bit too
weird, methinks.

I did this:

--- a/include/linux/vmstat.h
+++ a/include/linux/vmstat.h
@@ -25,11 +25,6 @@
 #define HIGHMEM_ZONE(xx)
 #endif
 
-#ifdef CONFIG_HUGETLB_PAGE
-#define HTLB_STATS	HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
-#else
-#define HTLB_STATS
-#endif
 
 #define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) , xx##_MOVABLE
 
@@ -42,7 +37,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		FOR_ALL_ZONES(PGSCAN_KSWAPD),
 		FOR_ALL_ZONES(PGSCAN_DIRECT),
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
-		PAGEOUTRUN, ALLOCSTALL, PGROTATED, HTLB_STATS
+		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+#ifdef CONFIG_HUGETLB_PAGE
+		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
