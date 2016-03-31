Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id DD9126B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 05:30:14 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id r72so132804475wmg.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 02:30:14 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id 11si4908712wmd.115.2016.03.31.02.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 02:30:13 -0700 (PDT)
Received: by mail-wm0-f45.google.com with SMTP id r72so132803897wmg.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 02:30:13 -0700 (PDT)
Date: Thu, 31 Mar 2016 11:30:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] oom, but there is enough memory
Message-ID: <20160331093011.GC27831@dhcp22.suse.cz>
References: <56FCEAD0.9080806@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56FCEAD0.9080806@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 31-03-16 17:16:00, Xishi Qiu wrote:
> It triggers a lot of ooms, but there is enough memory(many large blocks).
> And at last "Kernel panic - not syncing: Out of memory and no killable processes..."
> 
> I find almost the every call trace include "pagefault_out_of_memory" and "gfp_mask=0x0".
> If it does oom, why not it triger in mm core path? 

It seems that somebody in the page fault path has returned with
VM_FAULT_OOM without invoking the page allocator and kept returning the
same error until there is nothing killable and so the oom killer panics.

[...]
> <4>[63651.040374s][pid:2912,cpu3,sh]DMA free:550600kB min:5244kB low:27580kB high:28892kB active_anon:343060kB inactive_anon:1224kB active_file:107596kB inactive_file:465156kB unevictable:1040kB isolated(anon):0kB isolated(file):0kB present:2016252kB managed:1720040kB mlocked:1040kB dirty:40kB writeback:0kB mapped:200420kB shmem:1312kB slab_reclaimable:27048kB slab_unreclaimable:73300kB kernel_stack:15248kB pagetables:14484kB unstable:0kB bounce:0kB free_cma:30896kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no

This is rather weird. DMA zone with 2GB? What kind of architecture is
this?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
