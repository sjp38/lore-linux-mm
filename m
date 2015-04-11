Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA616B0038
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 22:50:13 -0400 (EDT)
Received: by iget9 with SMTP id t9so24731966ige.1
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 19:50:13 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id j4si1321078igx.32.2015.04.10.19.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Apr 2015 19:50:12 -0700 (PDT)
Received: by igbqf9 with SMTP id qf9so11637053igb.1
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 19:50:12 -0700 (PDT)
Date: Fri, 10 Apr 2015 19:50:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: show free pages per each migrate type
In-Reply-To: <BLU436-SMTP78227860F3E4FAF236A85CBAFB0@phx.gbl>
Message-ID: <alpine.DEB.2.10.1504101944440.9879@chino.kir.corp.google.com>
References: <BLU436-SMTP78227860F3E4FAF236A85CBAFB0@phx.gbl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Neil Zhang <neilzhang1123@hotmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Thu, 9 Apr 2015, Neil Zhang wrote:

> show detailed free pages per each migrate type in show_free_areas.
> 
> After apply this patch, the log printed out will be changed from
> 
> [   558.212844@0] Normal: 218*4kB (UEMC) 207*8kB (UEMC) 126*16kB (UEMC) 21*32kB (UC) 5*64kB (C) 3*128kB (C) 1*256kB (C) 1*512kB (C) 0*1024kB 0*2048kB 1*4096kB (R) = 10784kB
> [   558.227840@0] HighMem: 3*4kB (UMR) 3*8kB (UMR) 2*16kB (UM) 3*32kB (UMR) 0*64kB 1*128kB (M) 1*256kB (R) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 548kB
> 
> to
> 
> [   806.506450@1] Normal: 8969*4kB 4370*8kB 2*16kB 3*32kB 2*64kB 3*128kB 3*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 74804kB
> [   806.517456@1]       orders:      0      1      2      3      4      5      6      7      8      9     10
> [   806.527077@1]    Unmovable:   8287   4370      0      0      0      0      0      0      0      0      0
> [   806.536699@1]  Reclaimable:    681      0      0      0      0      0      0      0      0      0      0
> [   806.546321@1]      Movable:      1      0      0      0      0      0      0      0      0      0      0
> [   806.555942@1]      Reserve:      0      0      2      3      2      3      3      1      0      1      0
> [   806.565564@1]          CMA:      0      0      0      0      0      0      0      0      0      0      0
> [   806.575187@1]      Isolate:      0      0      0      0      0      0      0      0      0      0      0
> [   806.584810@1] HighMem: 80*4kB 15*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 440kB
> [   806.595383@1]       orders:      0      1      2      3      4      5      6      7      8      9     10
> [   806.605004@1]    Unmovable:     12      0      0      0      0      0      0      0      0      0      0
> [   806.614626@1]  Reclaimable:      0      0      0      0      0      0      0      0      0      0      0
> [   806.624248@1]      Movable:     11     15      0      0      0      0      0      0      0      0      0
> [   806.633869@1]      Reserve:     57      0      0      0      0      0      0      0      0      0      0
> [   806.643491@1]          CMA:      0      0      0      0      0      0      0      0      0      0      0
> [   806.653113@1]      Isolate:      0      0      0      0      0      0      0      0      0      0      0
> 
> Signed-off-by: Neil Zhang <neilzhang1123@hotmail.com>

Sorry, this is just way too verbose.  This output is emitted to the kernel 
log on oom kill and since we lack a notification mechanism on system oom, 
the _only_ way for userspace to detect oom kills that have occurred is by 
scraping the kernel log.  This is exactly what we do, and we have missed 
oom kill events because they scroll from the ring buffer due to excessive 
output such as this, which is why output was limited with the 
show_free_areas() filter in the first place.  Just because oom kill output 
is much less than it has been in the past, for precisely this reason, 
doesn't mean we can make it excessive again.

So nack on this patch, and if we really need to have this information (I 
don't know your motivation for adding it since you list none in your 
changelog), then we need to consider an oom verbosity sysctl or, better, 
an actual system oom notification to userspace based on eventfd() without 
requiring memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
