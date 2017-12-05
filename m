Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B62626B0273
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 04:46:41 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e70so9014wmc.6
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 01:46:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h38si13212ede.369.2017.12.05.01.46.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 01:46:40 -0800 (PST)
Date: Tue, 5 Dec 2017 10:46:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2] mm: check pfn_valid first in zero_resv_unavail
Message-ID: <20171205094638.q7kyfuijt7e2ztth@dhcp22.suse.cz>
References: <20171201095048.GA3084@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201095048.GA3084@dhcp-128-65.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: linux-kernel@vger.kernel.org, pasha.tatashin@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri 01-12-17 17:50:48, Dave Young wrote:
> With latest kernel I get below bug while testing kdump:
> [    0.000000] BUG: unable to handle kernel paging request at ffffea00034b1040
> [    0.000000] IP: zero_resv_unavail+0xbd/0x126
> [    0.000000] PGD 37b98067 P4D 37b98067 PUD 37b97067 PMD 0 
> [    0.000000] Oops: 0002 [#1] SMP
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.15.0-rc1+ #316
> [    0.000000] Hardware name: LENOVO 20ARS1BJ02/20ARS1BJ02, BIOS GJET92WW (2.42 ) 03/03/2017
> [    0.000000] task: ffffffff81a0e4c0 task.stack: ffffffff81a00000
> [    0.000000] RIP: 0010:zero_resv_unavail+0xbd/0x126
> [    0.000000] RSP: 0000:ffffffff81a03d88 EFLAGS: 00010006
> [    0.000000] RAX: 0000000000000000 RBX: ffffea00034b1040 RCX: 0000000000000010
> [    0.000000] RDX: 0000000000000000 RSI: 0000000000000092 RDI: ffffea00034b1040
> [    0.000000] RBP: 00000000000d2c41 R08: 00000000000000c0 R09: 0000000000000a0d
> [    0.000000] R10: 0000000000000002 R11: 0000000000007f01 R12: ffffffff81a03d90
> [    0.000000] R13: ffffea0000000000 R14: 0000000000000063 R15: 0000000000000062
> [    0.000000] FS:  0000000000000000(0000) GS:ffffffff81c73000(0000) knlGS:0000000000000000
> [    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.000000] CR2: ffffea00034b1040 CR3: 0000000037609000 CR4: 00000000000606b0
> [    0.000000] Call Trace:
> [    0.000000]  ? free_area_init_nodes+0x640/0x664
> [    0.000000]  ? zone_sizes_init+0x58/0x72
> [    0.000000]  ? setup_arch+0xb50/0xc6c
> [    0.000000]  ? start_kernel+0x64/0x43d
> [    0.000000]  ? secondary_startup_64+0xa5/0xb0
> [    0.000000] Code: c1 e8 0c 48 39 d8 76 27 48 89 de 48 c1 e3 06 48 c7 c7 7a 87 79 81 e8 b0 c0 3e ff 4c 01 eb b9 10 00 00 00 31 c0 48 89 df 49 ff c6 <f3> ab eb bc 6a 00 49 
> c7 c0 f0 93 d1 81 31 d2 83 ce ff 41 54 49 
> [    0.000000] RIP: zero_resv_unavail+0xbd/0x126 RSP: ffffffff81a03d88
> [    0.000000] CR2: ffffea00034b1040
> [    0.000000] ---[ end trace f5ba9e8f73c7ee26 ]---
> 
> This is introduced with commit a4a3ede2132a ("mm: zero reserved and
> unavailable struct pages")
> 
> The reason is some efi reserved boot ranges is not reported in E820 ram.
> In my case it is a bgrt buffer:
> efi: mem00: [Boot Data          |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC] range=[0x00000000d2c41000-0x00000000d2c85fff] (0MB)

I am still confused. Could you clarify why does efi code reserve this
range when it is not backed by any real memory?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
