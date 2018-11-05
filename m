Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC856B0007
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:39:25 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t1-v6so5382727ply.23
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:39:25 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z23-v6si1892861plo.265.2018.11.05.08.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:39:24 -0800 (PST)
Subject: Re: [PATCH 2/2] mm/page_alloc: use a single function to free page
References: <20181105085820.6341-1-aaron.lu@intel.com>
 <20181105085820.6341-2-aaron.lu@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a91592dd-83eb-ab9d-7f59-637928f964f8@intel.com>
Date: Mon, 5 Nov 2018 08:39:23 -0800
MIME-Version: 1.0
In-Reply-To: <20181105085820.6341-2-aaron.lu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>

On 11/5/18 12:58 AM, Aaron Lu wrote:
> We have multiple places of freeing a page, most of them doing similar
> things and a common function can be used to reduce code duplicate.
> 
> It also avoids bug fixed in one function and left in another.

Haha, should have read the next patch. :)

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 91a9a6af41a2..2b330296e92a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4425,9 +4425,17 @@ unsigned long get_zeroed_page(gfp_t gfp_mask)
>  }
>  EXPORT_SYMBOL(get_zeroed_page);
>  
> -void __free_pages(struct page *page, unsigned int order)
> +/*
> + * Free a page by reducing its ref count by @nr.
> + * If its refcount reaches 0, then according to its order:
> + * order0: send to PCP;
> + * high order: directly send to Buddy.
> + */

FWIW, I'm not a fan of comments on the function like this.  Please just
comment the *code* that's doing what you describe.  It's easier to read
and less likely to diverge from the code.

The rest of the patch looks great, though.
