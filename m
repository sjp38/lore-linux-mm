Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0E1D6B02F0
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 11:59:24 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n17-v6so12010109pff.10
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 08:59:24 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y78-v6si16647488pfj.159.2018.07.09.08.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 08:59:23 -0700 (PDT)
Subject: Re: [PATCH -mm -v4 01/21] mm, THP, swap: Enable PMD swap operations
 for CONFIG_THP_SWAP
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-2-ying.huang@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <11735e2e-781f-492f-7a1a-71b91e0876dc@linux.intel.com>
Date: Mon, 9 Jul 2018 08:59:20 -0700
MIME-Version: 1.0
In-Reply-To: <20180622035151.6676-2-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

On 06/21/2018 08:51 PM, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> Previously, the PMD swap operations are only enabled for
> CONFIG_ARCH_ENABLE_THP_MIGRATION.  Because they are only used by the
> THP migration support.  We will support PMD swap mapping to the huge
> swap cluster and swapin the THP as a whole.  That will be enabled via
> CONFIG_THP_SWAP and needs these PMD swap operations.  So enable the
> PMD swap operations for CONFIG_THP_SWAP too.

This commit message kinda skirts around the real reasons for this patch.
 Shouldn't we just say something like:

	Currently, "swap entries" in the page tables are used for a
	number of things outside of actual swap, like page migration.
	We support THP/PMD "swap entries" for page migration currently
	and the functions behind this are tied to page migration's
	config option (CONFIG_ARCH_ENABLE_THP_MIGRATION).

	But, we also need them for THP swap.
	...

It would also be nice to explain a bit why you are moving code around.

Would this look any better if we made a Kconfig option:

	config HAVE_THP_SWAP_ENTRIES
		def_bool n
		# "Swap entries" in the page tables are used
		# both for migration and actual swap.
		depends on THP_SWAP || ARCH_ENABLE_THP_MIGRATION

You logically talked about this need for PMD swap operations in your
commit message, so I think it makes sense to codify that in a single
place where it can be coherently explained.
