Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 760696B0005
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 14:32:52 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x2-v6so792826pgp.4
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:32:52 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id c16-v6si1489413pfj.333.2018.07.17.11.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 11:32:51 -0700 (PDT)
Subject: Re: [PATCH v2 2/7] mm/swapfile.c: Replace some #ifdef with
 IS_ENABLED()
References: <20180717005556.29758-1-ying.huang@intel.com>
 <20180717005556.29758-3-ying.huang@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <10878744-8db0-1d2c-e899-7c132d78e153@linux.intel.com>
Date: Tue, 17 Jul 2018 11:32:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180717005556.29758-3-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

> @@ -878,6 +877,11 @@ static int swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
>  	unsigned long offset, i;
>  	unsigned char *map;
>  
> +	if (!IS_ENABLED(CONFIG_THP_SWAP)) {
> +		VM_WARN_ON_ONCE(1);
> +		return 0;
> +	}

I see you seized the opportunity to keep this code gloriously
unencumbered by pesky comments.  This seems like a time when you might
have slipped up and been temped to add a comment or two.  Guess not. :)

Seriously, though, does it hurt us to add a comment or two to say
something like:

	/*
	 * Should not even be attempting cluster allocations when
	 * huge page swap is disabled.  Warn and fail the allocation.
	 */
	if (!IS_ENABLED(CONFIG_THP_SWAP)) {
		VM_WARN_ON_ONCE(1);
		return 0;
	}
