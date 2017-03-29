Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED2C6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 13:08:06 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q19so4440990wra.6
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 10:08:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l1si9241614wrb.253.2017.03.29.10.08.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 10:08:05 -0700 (PDT)
Date: Wed, 29 Mar 2017 13:08:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v7 4/9] mm, THP, swap: Add get_huge_swap_page()
Message-ID: <20170329170800.GC31821@cmpxchg.org>
References: <20170328053209.25876-1-ying.huang@intel.com>
 <20170328053209.25876-5-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328053209.25876-5-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Tue, Mar 28, 2017 at 01:32:04PM +0800, Huang, Ying wrote:
> @@ -527,6 +527,23 @@ static inline swp_entry_t get_swap_page(void)
>  
>  #endif /* CONFIG_SWAP */
>  
> +#ifdef CONFIG_THP_SWAP_CLUSTER
> +static inline swp_entry_t get_huge_swap_page(void)
> +{
> +	swp_entry_t entry;
> +
> +	if (get_swap_pages(1, &entry, true))
> +		return entry;
> +	else
> +		return (swp_entry_t) {0};
> +}
> +#else
> +static inline swp_entry_t get_huge_swap_page(void)
> +{
> +	return (swp_entry_t) {0};
> +}
> +#endif

Your introducing a function without a user, making it very hard to
judge whether the API is well-designed for the callers or not.

I pointed this out as a systemic problem with this patch series in v3,
along with other stuff, but with the way this series is structured I'm
having a hard time seeing whether you implemented my other feedback or
whether your counter arguments to them are justified.

I cannot review and ack these patches this way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
