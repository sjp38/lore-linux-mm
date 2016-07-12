Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 414096B0261
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 02:49:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so6234436wme.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 23:49:08 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id i196si3204910wmg.24.2016.07.11.23.49.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 23:49:06 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id i5so11370019wmg.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 23:49:06 -0700 (PDT)
Date: Tue, 12 Jul 2016 08:49:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160712064905.GA14586@dhcp22.suse.cz>
References: <57837CEE.1010609@redhat.com>
 <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com>
 <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 11-07-16 11:43:02, Mikulas Patocka wrote:
[...]
> The general problem is that the memory allocator does 16 retries to 
> allocate a page and then triggers the OOM killer (and it doesn't take into 
> account how much swap space is free or how many dirty pages were really 
> swapped out while it waited).

Well, that is not how it works exactly. We retry as long as there is a
reclaim progress (at least one page freed) back off only if the
reclaimable memory can exceed watermks which is scaled down in 16
retries. The overal size of free swap is not really that important if we
cannot swap out like here due to complete memory reserves depletion:
https://okozina.fedorapeople.org/bugs/swap_on_dmcrypt/vmlog-1462458369-00000/sample-00011/dmesg:
[   90.491276] Node 0 DMA free:0kB min:60kB low:72kB high:84kB active_anon:4096kB inactive_anon:4636kB active_file:212kB inactive_file:280kB unevictable:488kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:488kB dirty:276kB writeback:4636kB mapped:476kB shmem:12kB slab_reclaimable:204kB slab_unreclaimable:4700kB kernel_stack:48kB pagetables:120kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:61132 all_unreclaimable? yes
[   90.491283] lowmem_reserve[]: 0 977 977 977
[   90.491286] Node 0 DMA32 free:0kB min:3828kB low:4824kB high:5820kB active_anon:423820kB inactive_anon:424916kB active_file:17996kB inactive_file:21800kB unevictable:20724kB isolated(anon):384kB isolated(file):0kB present:1032184kB managed:1001260kB mlocked:20724kB dirty:25236kB writeback:49972kB mapped:23076kB shmem:1364kB slab_reclaimable:13796kB slab_unreclaimable:43008kB kernel_stack:2816kB pagetables:7320kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:5635400 all_unreclaimable? yes

Look at the amount of free memory. It is completely depleted. So it
smells like a process which has access to memory reserves has consumed
all of it. I suspect a __GFP_MEMALLOC resp. PF_MEMALLOC from softirq
context user which went off the leash.

> So, it could prematurely trigger OOM killer on any slow swapping device 
> (including dm-crypt). Michal Hocko reworked the OOM killer in the patch 
> 0a0337e0d1d134465778a16f5cbea95086e8e9e0, but it still has the flaw that 
> it triggers OOM if there is plenty of free swap space free.
> 
> Michal, would you accept a change to the OOM killer, to prevent it from 
> triggerring when there is free swap space?

No this doesn't sound like a proper solution. The current decision
logic, as explained above relies on the feedback from the reclaim. A
free swap space doesn't really mean we can make a forward progress.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
