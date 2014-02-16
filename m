Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 14B576B0075
	for <linux-mm@kvack.org>; Sun, 16 Feb 2014 17:17:50 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id um1so14385121pbc.5
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 14:17:49 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id yy4si12676901pbc.159.2014.02.16.14.17.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 16 Feb 2014 14:17:46 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so5388383pdb.37
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 14:17:45 -0800 (PST)
Date: Sun, 16 Feb 2014 14:17:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
In-Reply-To: <20140216200503.GN30257@n2100.arm.linux.org.uk>
Message-ID: <alpine.DEB.2.02.1402161406120.26926@chino.kir.corp.google.com>
References: <20140216200503.GN30257@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Sun, 16 Feb 2014, Russell King - ARM Linux wrote:

> Mem-info:
> Normal per-cpu:
> CPU    0: hi:   42, btch:   7 usd:  36
> active_anon:28041 inactive_anon:104 isolated_anon:0
>  active_file:11 inactive_file:11 isolated_file:0
>  unevictable:0 dirty:1 writeback:6 unstable:0
>  free:342 slab_reclaimable:170 slab_unreclaimable:570
>  mapped:13 shmem:139 pagetables:95 bounce:0
>  free_cma:0
> Normal free:1368kB min:1384kB low:1728kB high:2076kB active_anon:112164kB inactive_anon:416kB active_file:44kB inactive_file:44kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:131072kB managed:120152kB mlocked:0kB dirty:4kB
> writeback:24kB mapped:52kB shmem:556kB slab_reclaimable:680kB slab_unreclaimable:2280kB kernel_stack:248kB pagetables:380kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:136 all_unreclaimable? yes

All memory is accounted for here, there appears to be no leakage.

> [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
...
> [  756]     0   756    28163    27776      57        0             0 ld-linux.so.2

This is taking ~108MB of your ~117MB memory.

Three possibilies that immediately jump to mind:

 - if this is an SMP kernel, then too much free memory is being accounted
   for in cpu-0 vmstat differential and not returned to the ZVC pages 
   count,

 - there is a too little amount of "managed" memory attributed to 
   ZONE_NORMAL, the ~10MB difference between "present" and "managed"
   memory, or

 - ld-linux.so.2 is using too much memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
