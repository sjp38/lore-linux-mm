Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3C46B6B0038
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 19:38:12 -0400 (EDT)
Received: by pddn5 with SMTP id n5so35716588pdd.2
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 16:38:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fc6si147615pdb.146.2015.03.31.16.38.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 16:38:10 -0700 (PDT)
Date: Tue, 31 Mar 2015 16:38:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memblock: add debug output for the memblock_add
Message-Id: <20150331163808.6ffa50f3140b50828bd5dba8@linux-foundation.org>
In-Reply-To: <1427562483-29839-1-git-send-email-kuleshovmail@gmail.com>
References: <1427562483-29839-1-git-send-email-kuleshovmail@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Philipp Hachtmann <phacht@linux.vnet.ibm.com>, Fabian Frederick <fabf@skynet.be>, Catalin Marinas <catalin.marinas@arm.com>, Emil Medve <Emilian.Medve@freescale.com>, Akinobu Mita <akinobu.mita@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 28 Mar 2015 23:08:03 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:

> memblock_reserve function calls memblock_reserve_region which
> prints debugging information if 'memblock=debug' passed to the
> command line. This patch adds the same behaviour, but for the 
> memblock_add function.
> 
> Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
> ---
>  mm/memblock.c | 18 ++++++++++++++++--
>  1 file changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 252b77b..c7b8306 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -580,10 +580,24 @@ int __init_memblock memblock_add_node(phys_addr_t base, phys_addr_t size,
>  	return memblock_add_range(&memblock.memory, base, size, nid, 0);
>  }
>  
> +static int __init_memblock memblock_add_region(phys_addr_t base,
> +						phys_addr_t size,
> +						int nid,
> +						unsigned long flags)
> +{
> +	struct memblock_type *_rgn = &memblock.memory;
> +
> +	memblock_dbg("memblock_memory: [%#016llx-%#016llx] flags %#02lx %pF\n",

I guess this should be "memblock_add:".  That's what
memblock_reserve_region() does?

--- a/mm/memblock.c~mm-memblock-add-debug-output-for-the-memblock_add-fix
+++ a/mm/memblock.c
@@ -587,7 +587,7 @@ static int __init_memblock memblock_add_
 {
 	struct memblock_type *_rgn = &memblock.memory;
 
-	memblock_dbg("memblock_memory: [%#016llx-%#016llx] flags %#02lx %pF\n",
+	memblock_dbg("memblock_add: [%#016llx-%#016llx] flags %#02lx %pF\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size - 1,
 		     flags, (void *)_RET_IP_);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
