Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA436B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 07:06:00 -0400 (EDT)
Date: Wed, 3 Aug 2011 12:05:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] ARM: sparsemem: Enable CONFIG_HOLES_IN_ZONE config
 option for SparseMem and HAS_HOLES_MEMORYMODEL for linux-3.0.
Message-ID: <20110803110555.GD19099@suse.de>
References: <CAFPAmTQByL0YJT8Lvar1Oe+3Q1EREvqPA_GP=hHApJDz5dSOzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAFPAmTQByL0YJT8Lvar1Oe+3Q1EREvqPA_GP=hHApJDz5dSOzQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Russell King <rmk@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Tue, Aug 02, 2011 at 05:38:31PM +0530, Kautuk Consul wrote:
> Hi,
> 
> In the case where the total kernel memory is not aligned to the
> SECTION_SIZE_BITS I see a kernel crash.
> 
> When I copy a huge file, then the kernel crashes at the following callstack:
> 

The callstack should not be 80-column formatted as this is completely
manged and unreadable without manual editting. Also, why did you not
include the full error message? With it, I'd have a better idea of
which bug check you hit.

> Backtrace:
> <SNIP>
> 
> The reason for this is that the CONFIG_HOLES_IN_ZONE configuration
> option is not automatically enabled when SPARSEMEM or
> ARCH_HAS_HOLES_MEMORYMODEL are enabled. Due to this, the
> pfn_valid_within() macro always returns 1 due to which the BUG_ON is
> encountered.
> This patch enables the CONFIG_HOLES_IN_ZONE config option if either
> ARCH_HAS_HOLES_MEMORYMODEL or SPARSEMEM is enabled.
> 
> Although I tested this on an older kernel, i.e., 2.6.35.13, I see that
> this option has not been enabled as yet in linux-3.0 and this appears
> to be a
> logically correct change anyways with respect to pfn_valid_within()
> functionality.
> 

There is a performance cost associated with HOLES_IN_ZONE which may be
offset by memory savings but not necessarily.

If the BUG_ON you are hitting is this one
BUG_ON(page_zone(start_page) != page_zone(end_page)) then I'd be
wondering why the check in move_freepages_block() was insufficient.

If it's because holes are punched in the memmap then the option does
need to be set.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
