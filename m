Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07D466B0499
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 21:12:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r25so8884769pfk.11
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 18:12:12 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id f1si3463955plb.747.2017.08.29.18.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 18:12:10 -0700 (PDT)
Date: Tue, 29 Aug 2017 18:12:08 -0700 (PDT)
Message-Id: <20170829.181208.171985548699678313.davem@davemloft.net>
Subject: Re: [PATCH v7 07/11] sparc64: optimized struct page zeroing
From: David Miller <davem@davemloft.net>
In-Reply-To: <1503972142-289376-8-git-send-email-pasha.tatashin@oracle.com>
References: <1503972142-289376-1-git-send-email-pasha.tatashin@oracle.com>
	<1503972142-289376-8-git-send-email-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@oracle.com
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 28 Aug 2017 22:02:18 -0400

> Add an optimized mm_zero_struct_page(), so struct page's are zeroed without
> calling memset(). We do eight to ten regular stores based on the size of
> struct page. Compiler optimizes out the conditions of switch() statement.
> 
> SPARC-M6 with 15T of memory, single thread performance:
> 
>                                BASE            FIX  OPTIMIZED_FIX
>         bootmem_init   28.440467985s   2.305674818s   2.305161615s
> free_area_init_nodes  202.845901673s 225.343084508s 172.556506560s
>                       --------------------------------------------
> Total                 231.286369658s 227.648759326s 174.861668175s
> 
> BASE:  current linux
> FIX:   This patch series without "optimized struct page zeroing"
> OPTIMIZED_FIX: This patch series including the current patch.
> 
> bootmem_init() is where memory for struct pages is zeroed during
> allocation. Note, about two seconds in this function is a fixed time: it
> does not increase as memory is increased.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>

You should probably use initializing stores when you are doing 8
stores and we thus know the page struct is cache line aligned.

But other than that:

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
