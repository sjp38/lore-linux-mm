Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 23A596B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 14:18:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c187-v6so1645265pfa.20
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 11:18:24 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n20-v6si49714937pff.370.2018.06.05.11.18.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 11:18:22 -0700 (PDT)
Subject: Re: [PATCH] mremap: Avoid TLB flushing anonymous pages that are not
 in swap cache
References: <20180605171319.uc5jxdkxopio6kg3@techsingularity.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <bfc2e579-915f-24db-0ff0-29bd9148b8c0@intel.com>
Date: Tue, 5 Jun 2018 11:18:18 -0700
MIME-Version: 1.0
In-Reply-To: <20180605171319.uc5jxdkxopio6kg3@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@kernel.org, vbabka@suse.cz, Aaron Lu <aaron.lu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/05/2018 10:13 AM, Mel Gorman wrote:
> The anonymous page race fix is overkill for two reasons. Pages that are not
> in the swap cache are not going to be issued for IO and if a stale TLB entry
> is used, the write still occurs on the same physical page. Any race with
> mmap replacing the address space is handled by mmap_sem. As anonymous pages
> are often dirty, it can mean that mremap always has to flush even when it is
> not necessary.

This looks fine to me.  One nit on the description: I found myself
wondering if we skip the flush under the ptl where the flush is
eventually done.  That code is a bit out of the context, so we don't see
it in the patch.

We have two modes of flushing during move_ptes():
1. The flush_tlb_range() while holding the ptl in move_ptes().
2. A flush_tlb_range() at the end of move_table_tables(), driven by
  'need_flush' which will be set any time move_ptes() does *not* flush.

This patch broadens the scope where move_ptes() does not flush and
shifts the burden to the flush inside move_table_tables().

Right?

Other minor nits:

> +/* Returns true if a TLB must be flushed before PTL is dropped */
> +static bool should_force_flush(pte_t *pte)
> +{

I usually try to make the non-pte-modifying functions take a pte_t
instead of 'pte_t *' to make it obvious that there no modification going
on.  Any reason not to do that here?

> +	if (!trylock_page(page))
> +		return true;
> +	is_swapcache = PageSwapCache(page);
> +	unlock_page(page);
> +
> +	return is_swapcache;
> +}

I was hoping we didn't have to go as far as taking the page lock, but I
guess the proof is in the pudding that this tradeoff is worth it.

BTW, do you want to add a tiny comment about why we do the
trylock_page()?  I assume it's because we don't want to wait on finding
an exact answer: we just assume it is in the swap cache if the page is
locked and flush regardless.
