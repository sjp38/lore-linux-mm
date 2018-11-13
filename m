Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF28C6B0007
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 08:32:45 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y8so8065904pgq.12
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 05:32:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w32si20175213pga.337.2018.11.13.05.32.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Nov 2018 05:32:44 -0800 (PST)
Date: Tue, 13 Nov 2018 05:32:43 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] vmscan: return NODE_RECLAIM_NOSCAN in node_reclaim()
 when CONFIG_NUMA is n
Message-ID: <20181113133243.GW21824@bombadil.infradead.org>
References: <20181113041750.20784-1-richard.weiyang@gmail.com>
 <20181113080436.22078-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113080436.22078-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 13, 2018 at 04:04:36PM +0800, Wei Yang wrote:
> This patch fix the return value by adjusting to NODE_RECLAIM_NOSCAN. Since
> node_reclaim() is only called in page_alloc.c, move it to mm/internal.h.

linux/swap.h is included in quite a few places in the kernel, but let's
see what's really used from it outside mm/

SWAP_FLAG* -- only used in mm/swapfile.c.  Move to swapfile.c?
current_is_kswapd() -- used by some drivers.
MAX_SWAPFILES* -- used by arch code.
union swap_header -- used by mtdswap.
struct reclaim_state -- used by fs/inode.c.
struct swap_extent -- embedded in swap_info_struct, which is used widely.
struct swap_cluster_info -- ditto
struct vma_swap_readahead -- only used in swap_state.c.  Move it there?
nr_free_pages() -- used in fs/ and kernel/power/swap.c
totalram_pages -- used widely
totalreserve_pages -- used widely
vm_swappiness -- used by sysctl
vm_total_pages -- only used in mm -- move to mm/internal.h?
node_reclaim_mode -- used by sysctl
kswapd_run -- only used in mm
kswapd_stop -- ditto
swap_address_space -- only used in mm
swapper_spaces -- likewise
SWAP_ADDRESS_SPACE* --likewise

I haven't covered all of the file, but there's definitely opportunity
for some followup patches to shrink linux/swap.h.
