Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D8ACF6B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 17:03:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d4-v6so1108595pfn.9
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 14:03:43 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id n16-v6si1529983pgl.596.2018.07.17.14.03.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 14:03:42 -0700 (PDT)
Subject: Re: [PATCH v2] mm: disallow mapping that conflict for
 devm_memremap_pages()
From: Dave Jiang <dave.jiang@intel.com>
References: <152909478401.50143.312364396244072931.stgit@djiang5-desk3.ch.intel.com>
Message-ID: <865f6e1e-1711-bcb9-b226-4eb0d091f700@intel.com>
Date: Tue, 17 Jul 2018 14:03:41 -0700
MIME-Version: 1.0
In-Reply-To: <152909478401.50143.312364396244072931.stgit@djiang5-desk3.ch.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, dan.j.williams@intel.com, elliott@hpe.com, linux-nvdimm@lists.01.org

Andrew, is it possible to pick up this patch? Thanks!

On 06/15/2018 01:33 PM, Dave Jiang wrote:
> When pmem namespaces created are smaller than section size, this can cause
> issue during removal and gpf was observed:
> 
> [ 249.613597] general protection fault: 0000 1 SMP PTI
> [ 249.725203] CPU: 36 PID: 3941 Comm: ndctl Tainted: G W
> 4.14.28-1.el7uek.x86_64 #2
> [ 249.745495] task: ffff88acda150000 task.stack: ffffc900233a4000
> [ 249.752107] RIP: 0010:__put_page+0x56/0x79
> [ 249.844675] Call Trace:
> [ 249.847410] devm_memremap_pages_release+0x155/0x23a
> [ 249.852953] release_nodes+0x21e/0x260
> [ 249.857138] devres_release_all+0x3c/0x48
> [ 249.861606] device_release_driver_internal+0x15c/0x207
> [ 249.867439] device_release_driver+0x12/0x14
> [ 249.872204] unbind_store+0xba/0xd8
> [ 249.876098] drv_attr_store+0x27/0x31
> [ 249.880186] sysfs_kf_write+0x3f/0x46
> [ 249.884266] kernfs_fop_write+0x10f/0x18b
> [ 249.888734] __vfs_write+0x3a/0x16d
> [ 249.892628] ? selinux_file_permission+0xe5/0x116
> [ 249.897881] ? security_file_permission+0x41/0xbb
> [ 249.903133] vfs_write+0xb2/0x1a1
> [ 249.906835] ? syscall_trace_enter+0x1ce/0x2b8
> [ 249.911795] SyS_write+0x55/0xb9
> [ 249.915397] do_syscall_64+0x79/0x1ae
> [ 249.919485] entry_SYSCALL_64_after_hwframe+0x3d/0x0
> 
> Add code to check whether we have mapping already in the same section and
> prevent additional mapping from created if that is the case.
> 
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>
> ---
> 
> v2: Change dev_warn() to dev_WARN() to provide helpful backtrace. (Robert E)
> 
>  kernel/memremap.c |   18 +++++++++++++++++-
>  1 file changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 5857267a4af5..a734b1747466 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -176,10 +176,27 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  	unsigned long pfn, pgoff, order;
>  	pgprot_t pgprot = PAGE_KERNEL;
>  	int error, nid, is_ram;
> +	struct dev_pagemap *conflict_pgmap;
>  
>  	align_start = res->start & ~(SECTION_SIZE - 1);
>  	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
>  		- align_start;
> +	align_end = align_start + align_size - 1;
> +
> +	conflict_pgmap = get_dev_pagemap(PHYS_PFN(align_start), NULL);
> +	if (conflict_pgmap) {
> +		dev_WARN(dev, "Conflicting mapping in same section\n");
> +		put_dev_pagemap(conflict_pgmap);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
> +	conflict_pgmap = get_dev_pagemap(PHYS_PFN(align_end), NULL);
> +	if (conflict_pgmap) {
> +		dev_WARN(dev, "Conflicting mapping in same section\n");
> +		put_dev_pagemap(conflict_pgmap);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
>  	is_ram = region_intersects(align_start, align_size,
>  		IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
>  
> @@ -199,7 +216,6 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  
>  	mutex_lock(&pgmap_lock);
>  	error = 0;
> -	align_end = align_start + align_size - 1;
>  
>  	foreach_order_pgoff(res, order, pgoff) {
>  		error = __radix_tree_insert(&pgmap_radix,
> 
