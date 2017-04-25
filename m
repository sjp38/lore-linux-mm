Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9326B0038
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 17:37:22 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 194so240588194iof.21
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 14:37:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b31si1103943ioj.82.2017.04.25.14.37.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 14:37:21 -0700 (PDT)
Date: Tue, 25 Apr 2017 14:37:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] mm, swap: Fix swap space leak in error path of
 swap_free_entries()
Message-Id: <20170425143718.d05d4f5020b266dfdd61ed9c@linux-foundation.org>
In-Reply-To: <20170421124739.24534-1-ying.huang@intel.com>
References: <20170421124739.24534-1-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>

On Fri, 21 Apr 2017 20:47:39 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> From: Huang Ying <ying.huang@intel.com>
> 
> In swapcache_free_entries(), if swap_info_get_cont() return NULL,
> something wrong occurs for the swap entry.  But we should still
> continue to free the following swap entries in the array instead of
> skip them to avoid swap space leak.  This is just problem in error
> path, where system may be in an inconsistent state, but it is still
> good to fix it.
> 
> ...
>
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1079,8 +1079,6 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
>  		p = swap_info_get_cont(entries[i], prev);
>  		if (p)
>  			swap_entry_free(p, entries[i]);
> -		else
> -			break;
>  		prev = p;

So now prev==NULL.  Will this code get the locking correct in
swap_info_get_cont()?  I think so, but please double-check.

>  	}
>  	if (p)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
