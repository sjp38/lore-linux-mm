Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 522FC6B0253
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 20:42:09 -0400 (EDT)
Received: by igcqs7 with SMTP id qs7so68923910igc.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 17:42:09 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id p65si4031156iop.13.2015.07.08.17.42.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 17:42:08 -0700 (PDT)
Received: by igoe12 with SMTP id e12so3319332igo.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 17:42:08 -0700 (PDT)
Date: Wed, 8 Jul 2015 17:42:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: 4.2rc1 odd looking page allocator failure stats
In-Reply-To: <20150708204334.GA15602@codemonkey.org.uk>
Message-ID: <alpine.DEB.2.10.1507081737060.16585@chino.kir.corp.google.com>
References: <20150708204334.GA15602@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>
Cc: linux-mm@kvack.org

On Wed, 8 Jul 2015, Dave Jones wrote:

> I've got a box with 4GB of RAM that I've driven into oom (so much so that e1000 can't
> alloc a single page, so I can't even ping it). But over serial console I noticed this..
> 
> [158831.710001] DMA32 free:1624kB min:6880kB low:8600kB high:10320kB active_anon:407004kB inactive_anon:799300kB active_file:516kB inactive_file:6644kB unevictable:0kB
>  isolated(anon):0kB isolated(file):0kB present:3127220kB managed:3043108kB mlocked:0kB dirty:6680kB writeback:64kB mapped:31544kB shmem:1146792kB
>  slab_reclaimable:46812kB slab_unreclaimable:388364kB kernel_stack:2288kB pagetables:2076kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
>  free_cma:0kB writeback_tmp:0kB pages_scanned:70152496980 all_unreclaimable? yes
> 
> How come that 'pages_scanned' number is greater than the number of pages in the system ?
> Does kswapd iterate over the same pages a number of times each time the page allocator fails ?
> 
> 
> I've managed to hit this a couple times this week, where the oom killer kicks in, kills some
> processes, but then the machine goes into a death spiral of looping in the page allocator.
> Once that begins, it never tries to oom kill again, just hours of page allocation failure messages.
> 

We don't have the full oom log to see if there's any indication of a 
problem, but pages_scanned should be able to grow very large since it's 
never reset as a result of either memory freeing or periodic pcp flush (I 
notice free_pcp is 0kB above) so pages_scanned never gets cleared.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
