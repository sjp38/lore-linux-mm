Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7016B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 00:08:10 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id nt9so5423118obb.9
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 21:08:09 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id p2si220983obi.101.2015.01.22.21.08.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 Jan 2015 21:08:09 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YEWTY-002Esr-QR
	for linux-mm@kvack.org; Fri, 23 Jan 2015 05:08:09 +0000
Date: Thu, 22 Jan 2015 21:08:02 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol: remove
 unnecessary soft limit tree node test'
Message-ID: <20150123050802.GB22751@roeck-us.net>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Jan 22, 2015 at 03:05:17PM -0800, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2015-01-22-15-04 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
qemu test for ppc64 fails with

Unable to handle kernel paging request for data at address 0x0000af50
Faulting instruction address: 0xc00000000089d5d4
Oops: Kernel access of bad area, sig: 11 [#1]

with the following call stack:

Call Trace:
[c00000003d32f920] [c00000000089d588] .__slab_alloc.isra.44+0x7c/0x6f4
(unreliable)
[c00000003d32fa90] [c00000000020cf8c] .kmem_cache_alloc_node_trace+0x12c/0x3b0
[c00000003d32fb60] [c000000000bceeb4] .mem_cgroup_init+0x128/0x1b0
[c00000003d32fbf0] [c00000000000a2b4] .do_one_initcall+0xd4/0x260
[c00000003d32fce0] [c000000000ba26a8] .kernel_init_freeable+0x244/0x32c
[c00000003d32fdb0] [c00000000000ac24] .kernel_init+0x24/0x140
[c00000003d32fe30] [c000000000009564] .ret_from_kernel_thread+0x58/0x74

bisect log:

# bad: [03586ad04b2170ee816e6936981cc7cd2aeba129] pci: test for unexpectedly disabled bridges
# good: [ec6f34e5b552fb0a52e6aae1a5afbbb1605cc6cc] Linux 3.19-rc5
git bisect start 'HEAD' 'v3.19-rc5'
# bad: [d113ba21d15c7d3615fd88490d1197615bb39fc0] mm: remove lock validation check for MADV_FREE
git bisect bad d113ba21d15c7d3615fd88490d1197615bb39fc0
# good: [17351d1625a5030fa16f1346b77064c03b51f107] mm:add KPF_ZERO_PAGE flag for /proc/kpageflags
git bisect good 17351d1625a5030fa16f1346b77064c03b51f107
# good: [ad18ad1fce6f241a9cbd4adfd6b16c9283181e39] memcg: add BUILD_BUG_ON() for string tables
git bisect good ad18ad1fce6f241a9cbd4adfd6b16c9283181e39
# bad: [aa7e7cbfa43b74f6faef04ff730b5098544a4f77] mm/compaction: enhance tracepoint output for compaction begin/end
git bisect bad aa7e7cbfa43b74f6faef04ff730b5098544a4f77
# bad: [a40d0d2cf21e2714e9a6c842085148c938bf36ab] mm: memcontrol: remove unnecessary soft limit tree node test
git bisect bad a40d0d2cf21e2714e9a6c842085148c938bf36ab
# good: [e987aa804213c2d0c7f583639d868c7629ae479e] oom: add helpers for setting and clearing TIF_MEMDIE
git bisect good e987aa804213c2d0c7f583639d868c7629ae479e
# good: [af52cb6dc98bd833d4d15fe8eafc4a3e1f17951d] sysrq: convert printk to pr_* equivalent
git bisect good af52cb6dc98bd833d4d15fe8eafc4a3e1f17951d
# good: [61e257724ea22eb85488e7209f594106ca57258a] mm: cma: fix totalcma_pages to include DT defined CMA regions
git bisect good 61e257724ea22eb85488e7209f594106ca57258a
# first bad commit: [a40d0d2cf21e2714e9a6c842085148c938bf36ab] mm: memcontrol: remove unnecessary soft limit tree node test

If there is anything I can do to help debugging, please let me know.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
