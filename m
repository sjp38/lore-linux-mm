Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3A0E6B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 18:19:37 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r67-v6so10831385pfd.21
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 15:19:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v67-v6si10087312pfk.264.2018.10.05.15.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 15:19:36 -0700 (PDT)
Date: Fri, 5 Oct 2018 15:19:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memblock: stop using implicit alignement to
 SMP_CACHE_BYTES
Message-Id: <20181005151934.87226fa92825c3002a475413@linux-foundation.org>
In-Reply-To: <1538687224-17535-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1538687224-17535-1-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-um@lists.infradead.org

On Fri,  5 Oct 2018 00:07:04 +0300 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> When a memblock allocation APIs are called with align = 0, the alignment is
> implicitly set to SMP_CACHE_BYTES.
> 
> Replace all such uses of memblock APIs with the 'align' parameter explicitly
> set to SMP_CACHE_BYTES and stop implicit alignment assignment in the
> memblock internal allocation functions.
> 
> For the case when memblock APIs are used via helper functions, e.g. like
> iommu_arena_new_node() in Alpha, the helper functions were detected with
> Coccinelle's help and then manually examined and updated where appropriate.
> 
> ...
>
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1298,9 +1298,6 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
>  {
>  	phys_addr_t found;
>  
> -	if (!align)
> -		align = SMP_CACHE_BYTES;
> -

Can we add a WARN_ON_ONCE(!align) here?  To catch unconverted code
which sneaks in later on.
