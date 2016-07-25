Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6982F6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 03:26:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p129so71857973wmp.3
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 00:26:12 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id z12si22814272wmz.119.2016.07.25.00.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 00:26:11 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q128so15428733wma.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 00:26:11 -0700 (PDT)
Date: Mon, 25 Jul 2016 09:26:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: add cond_resched to generic_swapfile_activate
Message-ID: <20160725072609.GB9401@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1607221656530.4818@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1607221710580.4818@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607221710580.4818@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 22-07-16 17:11:20, Mikulas Patocka wrote:
> The function generic_swapfile_activate can take quite long time, it iterates
> over all blocks of a file, so add cond_resched to it. I observed about 1 second
> stalls when activating a swapfile that was almost unfragmented - this patch
> fixes it.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> 
> ---
>  mm/page_io.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> Index: linux-4.7-rc7/mm/page_io.c
> ===================================================================
> --- linux-4.7-rc7.orig/mm/page_io.c	2016-05-30 17:34:37.000000000 +0200
> +++ linux-4.7-rc7/mm/page_io.c	2016-07-11 17:23:33.000000000 +0200
> @@ -166,6 +166,8 @@ int generic_swapfile_activate(struct swa
>  		unsigned block_in_page;
>  		sector_t first_block;
>  
> +		cond_resched();
> +
>  		first_block = bmap(inode, probe_block);
>  		if (first_block == 0)
>  			goto bad_bmap;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
