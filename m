Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1L9r3t3013053
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 15:23:03 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1L9r286491558
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 15:23:02 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1L9r2st027839
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 09:53:02 GMT
Message-ID: <47BD48F3.3040903@linux.vnet.ibm.com>
Date: Thu, 21 Feb 2008 15:18:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] the proposal of improve page reclaim by throttle
References: <20080219134715.7E90.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080219134715.7E90.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> background
> ========================================
> current VM implementation doesn't has limit of # of parallel reclaim.
> when heavy workload, it bring to 2 bad things
>   - heavy lock contention
>   - unnecessary swap out
> 
> abount 2 month ago, KAMEZA Hiroyuki proposed the patch of page 
> reclaim throttle and explain it improve reclaim time.
> 	http://marc.info/?l=linux-mm&m=119667465917215&w=2
> 
> but unfortunately it works only memcgroup reclaim.
> Today, I implement it again for support global reclaim and mesure it.
> 

Hi, Kosaki,

It's good to keep the main reclaim code and the memory controller reclaim in
sync, so this is a nice effort.

> @@ -1456,7 +1501,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  	int target_zone = gfp_zone(GFP_HIGHUSER_MOVABLE);
> 
>  	zones = NODE_DATA(numa_node_id())->node_zonelists[target_zone].zones;
> -	if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
> +	if (try_to_free_pages_throttled(zones, 0, sc.gfp_mask, &sc))
>  		return 1;
>  	return 0;
>  }
> 

try_to_free_pages_throttled checks for zone_watermark_ok(), that will not work
in the case that we are reclaiming from a cgroup which over it's limit. We need
a different check, to see if the mem_cgroup is still over it's limit or not.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
