Return-Path: <linux-kernel-owner+w=401wt.eu-S1757195AbYLLFuT@vger.kernel.org>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
In-Reply-To: <493D82A6.9070104@redhat.com>
References: <20081208220016.53FB.KOSAKI.MOTOHIRO@jp.fujitsu.com> <493D82A6.9070104@redhat.com>
Message-Id: <20081212144445.297A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 12 Dec 2008 14:50:00 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> Index: linux-2.6.28-rc7/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.28-rc7.orig/include/linux/mmzone.h        2008-12-02 
> 15:04:33.000000000 -0500
> +++ linux-2.6.28-rc7/include/linux/mmzone.h     2008-12-08 
> 15:24:25.000000000 -0500
> @@ -58,7 +58,6 @@ static inline int get_pageblock_migratet
> 
>   struct free_area {
>          struct list_head        free_list[MIGRATE_TYPES];
> -       unsigned long           nr_free;
>   };
> 
>   struct pglist_data;
> @@ -296,6 +295,7 @@ struct zone {
>          seqlock_t               span_seqlock;
>   #endif
>          struct free_area        free_area[MAX_ORDER];
> +       struct nr_free          [MAX_ORDER];
> 
>   #ifndef CONFIG_SPARSEMEM
>          /*

mesurement result:

% tbench 8

                 2.6.28-rc6              +rvr free area restructure

	throughput     max latency	throughput	max latency
	------------------------------------------------------------
	1480.920 	20.896 		742.470 	 30.401 
	1483.940 	19.202		791.648 	635.623 
	1478.930 	22.215		733.433 	 92.515 

avg	1481.263 	20.771		755.850 	252.846 
std	   2.060 	 1.233		 25.580 	271.849 
min	1478.930 	19.202		733.433 	 30.401 
max	1483.940 	22.215		791.648 	635.623 


I think nick is right. I drop this idea.
