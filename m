Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 42B1F6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 00:02:16 -0400 (EDT)
Received: by igcxg11 with SMTP id xg11so15797156igc.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 21:02:16 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id zw3si1385647icb.66.2015.03.24.21.02.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 21:02:15 -0700 (PDT)
Received: by ignm3 with SMTP id m3so64027470ign.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 21:02:15 -0700 (PDT)
Date: Tue, 24 Mar 2015 21:02:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/memory-failure.c: define page types for action_result()
 in one place
In-Reply-To: <1426746272-24306-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.10.1503242058300.20696@chino.kir.corp.google.com>
References: <1426746272-24306-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Xie XiuQi <xiexiuqi@huawei.com>, Steven Rostedt <rostedt@goodmis.org>, Chen Gong <gong.chen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 19 Mar 2015, Naoya Horiguchi wrote:

> This cleanup patch moves all strings passed to action_result() into a single
> array action_page_type so that a reader can easily find which kind of action
> results are possible. And this patch also fixes the odd lines to be printed
> out, like "unknown page state page" or "free buddy, 2nd try page".
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memory-failure.c | 107 +++++++++++++++++++++++++++++++++++++---------------
>  1 file changed, 76 insertions(+), 31 deletions(-)
> 
> diff --git v3.19.orig/mm/memory-failure.c v3.19/mm/memory-failure.c
> index d487f8dc6d39..afb740e1c8b0 100644
> --- v3.19.orig/mm/memory-failure.c
> +++ v3.19/mm/memory-failure.c
> @@ -521,6 +521,52 @@ static const char *action_name[] = {
>  	[RECOVERED] = "Recovered",
>  };
>  
> +enum page_type {
> +	KERNEL,
> +	KERNEL_HIGH_ORDER,
> +	SLAB,
> +	DIFFERENT_COMPOUND,
> +	POISONED_HUGE,
> +	HUGE,
> +	FREE_HUGE,
> +	UNMAP_FAILED,
> +	DIRTY_SWAPCACHE,
> +	CLEAN_SWAPCACHE,
> +	DIRTY_MLOCKED_LRU,
> +	CLEAN_MLOCKED_LRU,
> +	DIRTY_UNEVICTABLE_LRU,
> +	CLEAN_UNEVICTABLE_LRU,
> +	DIRTY_LRU,
> +	CLEAN_LRU,
> +	TRUNCATED_LRU,
> +	BUDDY,
> +	BUDDY_2ND,
> +	UNKNOWN,
> +};
> +

I like the patch because of the consistency in output and think it's worth 
the extra 1% .text size.

My only concern is the generic naming of the enum members.  
memory-failure.c is already an offender with "enum outcome" and the naming 
of its members.

Would you mind renaming these to be prefixed with "MSG_"?

These enums should be anonymous, too, nothing is referencing enum outcome 
or your new enum page_type.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
