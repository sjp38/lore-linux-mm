Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB1428089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 23:20:39 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so217058960pgc.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 20:20:39 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id n19si8937489pgk.293.2017.02.08.20.20.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 20:20:38 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id v184so16704559pgv.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 20:20:38 -0800 (PST)
Date: Thu, 9 Feb 2017 14:20:26 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH] mm: fix KPF_SWAPCACHE
Message-ID: <20170209142026.6861ffb0@roar.ozlabs.ibm.com>
In-Reply-To: <alpine.LSU.2.11.1702071105360.11828@eggly.anvils>
References: <alpine.LSU.2.11.1702071105360.11828@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 7 Feb 2017 11:11:16 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> 4.10-rc1 commit 6326fec1122c ("mm: Use owner_priv bit for PageSwapCache,
> valid when PageSwapBacked") aliased PG_swapcache to PG_owner_priv_1:
> so /proc/kpageflags' KPF_SWAPCACHE should now be synthesized, instead
> of being shown on unrelated pages which have PG_owner_priv_1 set.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thanks Hugh, this seems fine to me. We want this for 4.10, no?

Fixes: 6326fec1122c ("mm: Use owner_priv bit for PageSwapCache, valid when PageSwapBacked")
Reviewed-by: Nicholas Piggin <npiggin@gmail.com>

> ---
> 
>  fs/proc/page.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> --- 4.10-rc7/fs/proc/page.c	2016-12-25 18:40:50.618454962 -0800
> +++ linux/fs/proc/page.c	2017-02-07 10:28:51.019640392 -0800
> @@ -173,7 +173,8 @@ u64 stable_page_flags(struct page *page)
>  	u |= kpf_copy_bit(k, KPF_ACTIVE,	PG_active);
>  	u |= kpf_copy_bit(k, KPF_RECLAIM,	PG_reclaim);
>  
> -	u |= kpf_copy_bit(k, KPF_SWAPCACHE,	PG_swapcache);
> +	if (PageSwapCache(page))
> +		u |= 1 << KPF_SWAPCACHE;
>  	u |= kpf_copy_bit(k, KPF_SWAPBACKED,	PG_swapbacked);
>  
>  	u |= kpf_copy_bit(k, KPF_UNEVICTABLE,	PG_unevictable);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
