Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id AE2886B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 04:20:23 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id hi5so3874351wib.8
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 01:20:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei5si8055936wib.82.2014.02.11.01.20.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 01:20:21 -0800 (PST)
Date: Tue, 11 Feb 2014 09:20:17 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/4] memblock: memblock_virt_alloc_internal(): alloc from
 specified node only
Message-ID: <20140211092017.GG6732@suse.de>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
 <1392053268-29239-2-git-send-email-lcapitulino@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1392053268-29239-2-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com

On Mon, Feb 10, 2014 at 12:27:45PM -0500, Luiz Capitulino wrote:
> From: Luiz capitulino <lcapitulino@redhat.com>
> 
> If an allocation from the node specified by the nid argument fails,
> memblock_virt_alloc_internal() automatically tries to allocate memory
> from other nodes.
> 
> This is fine is the caller don't care which node is going to allocate
> the memory. However, there are cases where the caller wants memory to
> be allocated from the specified node only. If that's not possible, then
> memblock_virt_alloc_internal() should just fail.
> 
> This commit adds a new flags argument to memblock_virt_alloc_internal()
> where the caller can control this behavior.
> 
> Signed-off-by: Luiz capitulino <lcapitulino@redhat.com>
> ---
>  mm/memblock.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 39a31e7..b0c7b2e 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1028,6 +1028,8 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
>  	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
>  }
>  
> +#define ALLOC_SPECIFIED_NODE_ONLY 0x1
> +

It's not a perfect fit but you could use gfp_t and GFP_THISNODE. The
meaning of the flag is recognised and while you are not using it with a
page allocator, we already use GFP flags with the slab allocator without
confusion.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
