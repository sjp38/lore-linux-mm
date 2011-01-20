Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 582BB8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 10:00:25 -0500 (EST)
Date: Thu, 20 Jan 2011 09:00:09 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [REPOST] [PATCH 3/3] Provide control over unmapped pages (v3)
In-Reply-To: <20110120123649.30481.93286.stgit@localhost6.localdomain6>
Message-ID: <alpine.DEB.2.00.1101200856310.10695@router.home>
References: <20110120123039.30481.81151.stgit@localhost6.localdomain6> <20110120123649.30481.93286.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 20 Jan 2011, Balbir Singh wrote:

> +	unmapped_page_control
> +			[KNL] Available if CONFIG_UNMAPPED_PAGECACHE_CONTROL
> +			is enabled. It controls the amount of unmapped memory
> +			that is present in the system. This boot option plus
> +			vm.min_unmapped_ratio (sysctl) provide granular control

min_unmapped_ratio is there to guarantee that zone reclaim does not
reclaim all unmapped pages.

What you want here is a max_unmapped_ratio.


>  {
> @@ -2297,6 +2320,12 @@ loop_again:
>  				shrink_active_list(SWAP_CLUSTER_MAX, zone,
>  							&sc, priority, 0);
>
> +			/*
> +			 * We do unmapped page reclaim once here and once
> +			 * below, so that we don't lose out
> +			 */
> +			reclaim_unmapped_pages(priority, zone, &sc);
> +
>  			if (!zone_watermark_ok_safe(zone, order,

Hmmmm. Okay that means background reclaim does it. If so then we also want
zone reclaim to be able to work in the background I think.
max_unmapped_ratio could also be useful to the zone reclaim logic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
