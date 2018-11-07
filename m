Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 700E26B0555
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 15:12:12 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id p4so4484122pgj.21
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 12:12:12 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 188-v6si1588054pfa.199.2018.11.07.12.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 12:12:11 -0800 (PST)
Date: Wed, 7 Nov 2018 12:12:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/sparse: add common helper to mark all memblocks
 present
Message-Id: <20181107121207.62cb37cf58484b7cc80a8fd8@linux-foundation.org>
In-Reply-To: <20181107173859.24096-3-logang@deltatee.com>
References: <20181107173859.24096-1-logang@deltatee.com>
	<20181107173859.24096-3-logang@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>

On Wed,  7 Nov 2018 10:38:59 -0700 Logan Gunthorpe <logang@deltatee.com> wrote:

> Presently the arches arm64, arm and sh have a function which loops through
> each memblock and calls memory present. riscv will require a similar
> function.
> 
> Introduce a common memblocks_present() function that can be used by
> all the arches. Subsequent patches will cleanup the arches that
> make use of this.
> 
> ...
>
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -239,6 +239,17 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
>  	}
>  }
>  
> +void __init memblocks_present(void)
> +{
> +	struct memblock_region *reg;
> +
> +	for_each_memblock(memory, reg) {
> +		memory_present(memblock_get_region_node(reg),
> +			       memblock_region_memory_base_pfn(reg),
> +			       memblock_region_memory_end_pfn(reg));
> +	}
> +}
> +

I don't like the name much.  To me, memblocks_present means "are
memblocks present" whereas this actually means "memblocks are present".
But whatever.  A little covering comment which describes what this
does and why it does it would be nice.

Acked-by: Andrew Morton <akpm@linux-foundation.org>

I can grab both patches and shall sneak them into 4.20-rcX, but feel
free to merge them into some git tree if you'd prefer.  If I see them
turn up in linux-next I shall drop my copy.
