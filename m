Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB729280858
	for <linux-mm@kvack.org>; Wed, 10 May 2017 05:51:30 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d14so10270665qkb.0
        for <linux-mm@kvack.org>; Wed, 10 May 2017 02:51:30 -0700 (PDT)
Received: from sym2.noone.org (sym2.noone.org. [178.63.92.236])
        by mx.google.com with ESMTPS id l15si2659828qke.195.2017.05.10.02.51.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 02:51:29 -0700 (PDT)
Date: Wed, 10 May 2017 11:51:26 +0200
From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] mm, vmalloc: fix vmalloc users tracking properly
Message-ID: <20170510095126.GB3447@distanz.ch>
References: <20170509144108.31910-1-mhocko@kernel.org>
 <20170509153702.GR6481@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170509153702.GR6481@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 2017-05-09 at 17:37:02 +0200, Michal Hocko <mhocko@kernel.org> wrote:
> Sigh. I've apparently managed to screw up again. This should address the
> nommu breakage reported by 0-day.
> ---
> From 95d49bf93ae4467f3f918520ec03b3596e5b36cc Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 9 May 2017 16:27:39 +0200
> Subject: [PATCH] mm, vmalloc: fix vmalloc users tracking properly
> 
> 1f5307b1e094 ("mm, vmalloc: properly track vmalloc users") has pulled
> asm/pgtable.h include dependency to linux/vmalloc.h and that turned out
> to be a bad idea for some architectures. E.g. m68k fails with
>    In file included from arch/m68k/include/asm/pgtable_mm.h:145:0,
>                     from arch/m68k/include/asm/pgtable.h:4,
>                     from include/linux/vmalloc.h:9,
>                     from arch/m68k/kernel/module.c:9:
>    arch/m68k/include/asm/mcf_pgtable.h: In function 'nocache_page':
> >> arch/m68k/include/asm/mcf_pgtable.h:339:43: error: 'init_mm' undeclared (first use in this function)
>     #define pgd_offset_k(address) pgd_offset(&init_mm, address)
> 
> as spotted by kernel build bot. nios2 fails for other reason
> In file included from ./include/asm-generic/io.h:767:0,
>                  from ./arch/nios2/include/asm/io.h:61,
>                  from ./include/linux/io.h:25,
>                  from ./arch/nios2/include/asm/pgtable.h:18,
>                  from ./include/linux/mm.h:70,
>                  from ./include/linux/pid_namespace.h:6,
>                  from ./include/linux/ptrace.h:9,
>                  from ./arch/nios2/include/uapi/asm/elf.h:23,
>                  from ./arch/nios2/include/asm/elf.h:22,
>                  from ./include/linux/elf.h:4,
>                  from ./include/linux/module.h:15,
>                  from init/main.c:16:
> ./include/linux/vmalloc.h: In function '__vmalloc_node_flags':
> ./include/linux/vmalloc.h:99:40: error: 'PAGE_KERNEL' undeclared (first use in this function); did you mean 'GFP_KERNEL'?
> 
> which is due to the newly added #include <asm/pgtable.h>, which on nios2
> includes <linux/io.h> and thus <asm/io.h> and <asm-generic/io.h> which
> again includes <linux/vmalloc.h>.
> 
> Tweaking that around just turns out a bigger headache than
> necessary. This patch reverts 1f5307b1e094 and reimplements the original
> fix in a different way. __vmalloc_node_flags can stay static inline
> which will cover vmalloc* functions. We only have one external user
> (kvmalloc_node) and we can export __vmalloc_node_flags_caller and
> provide the caller directly. This is much simpler and it doesn't really
> need any games with header files.
> 
> Fixes: 1f5307b1e094 ("mm, vmalloc: properly track vmalloc users")
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Tested-by: Tobias Klauser <tklauser@distanz.ch>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
