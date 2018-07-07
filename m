Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5100B6B0003
	for <linux-mm@kvack.org>; Sat,  7 Jul 2018 02:01:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w21-v6so640187wmc.6
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 23:01:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u1-v6sor4821671wri.78.2018.07.06.23.01.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 23:01:56 -0700 (PDT)
Date: Sat, 7 Jul 2018 08:01:53 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2] mm/sparse.c: fix error path in sparse_add_one_section
Message-ID: <20180707060153.GA13141@techadventures.net>
References: <20180706190658.6873-1-ross.zwisler@linux.intel.com>
 <20180706223358.742-1-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180706223358.742-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: pasha.tatashin@oracle.com, linux-nvdimm@lists.01.org, bhe@redhat.com, Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, osalvador@suse.de

On Fri, Jul 06, 2018 at 04:33:58PM -0600, Ross Zwisler wrote:
> The following commit in -next:
> 
> commit 054620849110 ("mm/sparse.c: make sparse_init_one_section void and
> remove check")
> 
> changed how the error handling in sparse_add_one_section() works.
> 
> Previously sparse_index_init() could return -EEXIST, and the function would
> continue on happily.  'ret' would get unconditionally overwritten by the
> result from sparse_init_one_section() and the error code after the 'out:'
> label wouldn't be triggered.
> 
> With the above referenced commit, though, an -EEXIST error return from
> sparse_index_init() now takes us through the function and into the error
> case after 'out:'.  This eventually causes a kernel BUG, probably because
> we've just freed a memory section that we successfully set up and marked as
> present:
> 
>   BUG: unable to handle kernel paging request at ffffea0005000080
>   RIP: 0010:memmap_init_zone+0x154/0x1cf
> 
>   Call Trace:
>    move_pfn_range_to_zone+0x168/0x180
>    devm_memremap_pages+0x29b/0x480
>    pmem_attach_disk+0x1ae/0x6c0 [nd_pmem]
>    ? devm_memremap+0x79/0xb0
>    nd_pmem_probe+0x7e/0xa0 [nd_pmem]
>    nvdimm_bus_probe+0x6e/0x160 [libnvdimm]
>    driver_probe_device+0x310/0x480
>    __device_attach_driver+0x86/0x100
>    ? __driver_attach+0x110/0x110
>    bus_for_each_drv+0x6e/0xb0
>    __device_attach+0xe2/0x160
>    device_initial_probe+0x13/0x20
>    bus_probe_device+0xa6/0xc0
>    device_add+0x41b/0x660
>    ? lock_acquire+0xa3/0x210
>    nd_async_device_register+0x12/0x40 [libnvdimm]
>    async_run_entry_fn+0x3e/0x170
>    process_one_work+0x230/0x680
>    worker_thread+0x3f/0x3b0
>    kthread+0x12f/0x150
>    ? process_one_work+0x680/0x680
>    ? kthread_create_worker_on_cpu+0x70/0x70
>    ret_from_fork+0x3a/0x50
> 
> Fix this by clearing 'ret' back to 0 if sparse_index_init() returns
> -EEXIST.  This restores the previous behavior.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>
-- 
Oscar Salvador
SUSE L3
