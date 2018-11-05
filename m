Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36E506B0007
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:37:59 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id t5-v6so727747plo.2
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:37:59 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p1-v6si637569pls.381.2018.11.05.08.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:37:58 -0800 (PST)
Subject: Re: [PATCH 1/2] mm/page_alloc: free order-0 pages through PCP in
 page_frag_free()
References: <20181105085820.6341-1-aaron.lu@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f2d00eca-e40b-c0e9-5aae-a9a8105169b1@intel.com>
Date: Mon, 5 Nov 2018 08:37:57 -0800
MIME-Version: 1.0
In-Reply-To: <20181105085820.6341-1-aaron.lu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Yoel Caspersen <yoel@kviknet.dk>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>

On 11/5/18 12:58 AM, Aaron Lu wrote:
> -	if (unlikely(put_page_testzero(page)))
> -		__free_pages_ok(page, compound_order(page));
> +	if (unlikely(put_page_testzero(page))) {
> +		unsigned int order = compound_order(page);
> +
> +		if (order == 0)
> +			free_unref_page(page);
> +		else
> +			__free_pages_ok(page, order);
> +	}
>  }

This little hunk seems repeated in __free_pages() and
__page_frag_cache_drain().  Do we need a common helper?
