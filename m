Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5D62D6B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 19:23:45 -0400 (EDT)
Received: by pdbmi9 with SMTP id mi9so20159579pdb.3
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 16:23:45 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id gr3si26831693pbb.10.2015.08.17.16.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 16:23:44 -0700 (PDT)
Received: by paccq16 with SMTP id cq16so74428227pac.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 16:23:44 -0700 (PDT)
Date: Mon, 17 Aug 2015 16:22:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Potential data race in SyS_swapon
In-Reply-To: <CAAeHK+w7bQtAUAWFrcqE5Gf8t8nZoHim6iXg1axXdC_bVmrNDw@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1508171610190.2618@eggly.anvils>
References: <CAAeHK+w7bQtAUAWFrcqE5Gf8t8nZoHim6iXg1axXdC_bVmrNDw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Hugh Dickins <hughd@google.com>, Miklos Szeredi <mszeredi@suse.cz>, Jason Low <jason.low2@hp.com>, Cesar Eduardo Barros <cesarb@cesarb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

On Fri, 7 Aug 2015, Andrey Konovalov wrote:
> 
> We are working on a dynamic data race detector for the Linux kernel
> called KernelThreadSanitizer (ktsan)
> (https://github.com/google/ktsan/wiki).
> 
> While running ktsan on the upstream revision 21bdb584af8c with trinity
> we got a few reports from SyS_swapon, here is one of them:
> 
> ==================================================================
> ThreadSanitizer: data-race in SyS_swapon
> 
> Read of size 8 by thread T307 (K7621):
>  [<     inlined    >] SyS_swapon+0x3c0/0x1850 SYSC_swapon mm/swapfile.c:2395
>  [<ffffffff812242c0>] SyS_swapon+0x3c0/0x1850 mm/swapfile.c:2345
>  [<ffffffff81e97c8a>] ia32_do_call+0x1b/0x25
> 
> Looks like the swap_lock should be taken when iterating through the
> swap_info array on lines 2392 - 2401.

Thanks for the report.  Actually, lines 2392 to 2401 just look redundant
to me: it looks as if claim_swapfile() should do all that's needed,
though in fact it doesn't quite.  I'll send akpm a patch and Cc you,
no need to retest since the offending lines just won't be there.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
