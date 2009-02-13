Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5976B003D
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 17:21:27 -0500 (EST)
Date: Fri, 13 Feb 2009 14:20:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] clean up for early_pfn_to_nid
Message-Id: <20090213142032.09b4a4da.akpm@linux-foundation.org>
In-Reply-To: <20090212162203.db3f07cb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090212161920.deedea35.kamezawa.hiroyu@jp.fujitsu.com>
	<20090212162203.db3f07cb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, davem@davemlloft.net, heiko.carstens@de.ibm.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Feb 2009 16:22:03 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Declaration of early_pfn_to_nid() is scattered over per-arch include files,
> and it seems it's complicated to know when the declaration is used.
> I think it makes fix-for-memmap-init not easy.
> 
> This patch moves all declaration to include/linux/mm.h
> 
> After this,
>   if !CONFIG_NODES_POPULATES_NODE_MAP && !CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
>      -> Use static definition in include/linux/mm.h
>   else if !CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
>      -> Use generic definition in mm/page_alloc.c
>   else
>      -> per-arch back end function will be called.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  arch/ia64/include/asm/mmzone.h   |    4 ----
>  arch/ia64/mm/numa.c              |    2 +-
>  arch/x86/include/asm/mmzone_32.h |    2 --
>  arch/x86/include/asm/mmzone_64.h |    2 --
>  arch/x86/mm/numa_64.c            |    2 +-
>  include/linux/mm.h               |   19 ++++++++++++++++---
>  mm/page_alloc.c                  |    8 +++++++-
>  7 files changed, 25 insertions(+), 14 deletions(-)

It's rather unfortunate that this bugfix includes a fair-sized cleanup
patch, because we should backport it into 2.6.28.x.

Oh well.

I queued these as

mm-clean-up-for-early_pfn_to_nid.patch
mm-fix-memmap-init-for-handling-memory-hole.patch

and tagged them as needed-in-2.6.28.x.  I don't recall whether they are
needed in earlier -stable releases?

I don't have a record here of davem having tested these new patches, btw ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
