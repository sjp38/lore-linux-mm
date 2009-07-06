Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D05786B004F
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 06:22:52 -0400 (EDT)
Subject: Re: [RFC PATCH 2/3] kmemleak: Add callbacks to the bootmem
	allocator
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20090706105155.16051.59597.stgit@pc1117.cambridge.arm.com>
References: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
	 <20090706105155.16051.59597.stgit@pc1117.cambridge.arm.com>
Content-Type: text/plain
Date: Mon, 06 Jul 2009 11:58:40 +0100
Message-Id: <1246877921.16785.26.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-07-06 at 11:51 +0100, Catalin Marinas wrote:
> This patch adds kmemleak_alloc/free callbacks to the bootmem allocator.
> This would allow scanning of such blocks and help avoiding a whole class
> of false positives and more kmemleak annotations.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> ---
>  mm/bootmem.c |   36 +++++++++++++++++++++++++++++-------
>  1 files changed, 29 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index d2a9ce9..18858ad 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -335,6 +335,8 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
>  {
>  	unsigned long start, end;
>  
> +	kmemleak_free(__va(physaddr));

This should actually be

+	kmemleak_free_part(__va(physaddr), size);

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
