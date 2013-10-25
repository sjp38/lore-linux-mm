Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 481686B00C4
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 06:15:40 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so2023778pad.27
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 03:15:39 -0700 (PDT)
Received: from psmtp.com ([74.125.245.158])
        by mx.google.com with SMTP id n5si4642768pav.127.2013.10.25.03.15.38
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 03:15:39 -0700 (PDT)
Received: by mail-wg0-f53.google.com with SMTP id y10so3603015wgg.20
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 03:15:36 -0700 (PDT)
Date: Fri, 25 Oct 2013 19:15:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RESEND 1/2] =?utf-8?Q?mm=2Fzswa?=
 =?utf-8?Q?p=3A_bugfix=3A_memory_leak_when_invalidate_and_reclaim_occur_co?=
 =?utf-8?Q?ncurrent=E2=80=8Bly?=
Message-ID: <20131025101532.GD6612@gmail.com>
References: <000001ced09e$e3718180$aa548480$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001ced09e$e3718180$aa548480$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: akpm@linux-foundation.org, sjennings@variantweb.net, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu, Oct 24, 2013 at 05:51:11PM +0800, Weijie Yang wrote:
> Consider the following scenario:
> thread 0: reclaim entry x (get refcount, but not call zswap_get_swap_cache_page)
> thread 1: call zswap_frontswap_invalidate_page to invalidate entry x.
> 	finished, entry x and its zbud is not freed as its refcount != 0
> 	now, the swap_map[x] = 0
> thread 0: now call zswap_get_swap_cache_page
> 	swapcache_prepare return -ENOENT because entry x is not used any more
> 	zswap_get_swap_cache_page return ZSWAP_SWAPCACHE_NOMEM
> 	zswap_writeback_entry do nothing except put refcount
> Now, the memory of zswap_entry x and its zpage leak.
> 
> Modify:
>  - check the refcount in fail path, free memory if it is not referenced.
> 
>  - use ZSWAP_SWAPCACHE_FAIL instead of ZSWAP_SWAPCACHE_NOMEM as the fail path
>    can be not only caused by nomem but also by invalidate.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> Reviewed-by: Bob Liu <bob.liu@oracle.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: <stable@vger.kernel.org>
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Minchan Kim <minchan@kernel.org>

Thanks, Weijie!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
