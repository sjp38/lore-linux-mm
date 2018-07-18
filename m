Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E10796B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 15:23:29 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u130-v6so2433021pgc.0
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 12:23:29 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b2-v6si3627444plx.88.2018.07.18.12.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 12:23:27 -0700 (PDT)
Subject: Re: [PATCH v2] mm: disallow mapping that conflict for
 devm_memremap_pages()
References: <152909478401.50143.312364396244072931.stgit@djiang5-desk3.ch.intel.com>
 <x49efg04cx8.fsf@segfault.boston.devel.redhat.com>
From: Dave Jiang <dave.jiang@intel.com>
Message-ID: <83f4c2d1-7867-5f7c-1181-86e97b36e5d3@intel.com>
Date: Wed, 18 Jul 2018 12:23:17 -0700
MIME-Version: 1.0
In-Reply-To: <x49efg04cx8.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org



On 07/18/2018 11:27 AM, Jeff Moyer wrote:
> Hi, Dave,
> 
> Dave Jiang <dave.jiang@intel.com> writes:
> 
>> When pmem namespaces created are smaller than section size, this can cause
>> issue during removal and gpf was observed:
>>
>> [ 249.613597] general protection fault: 0000 1 SMP PTI
>> [ 249.725203] CPU: 36 PID: 3941 Comm: ndctl Tainted: G W
>> 4.14.28-1.el7uek.x86_64 #2
>> [ 249.745495] task: ffff88acda150000 task.stack: ffffc900233a4000
>> [ 249.752107] RIP: 0010:__put_page+0x56/0x79
>> [ 249.844675] Call Trace:
>> [ 249.847410] devm_memremap_pages_release+0x155/0x23a
>> [ 249.852953] release_nodes+0x21e/0x260
>> [ 249.857138] devres_release_all+0x3c/0x48
>> [ 249.861606] device_release_driver_internal+0x15c/0x207
>> [ 249.867439] device_release_driver+0x12/0x14
>> [ 249.872204] unbind_store+0xba/0xd8
>> [ 249.876098] drv_attr_store+0x27/0x31
>> [ 249.880186] sysfs_kf_write+0x3f/0x46
>> [ 249.884266] kernfs_fop_write+0x10f/0x18b
>> [ 249.888734] __vfs_write+0x3a/0x16d
>> [ 249.892628] ? selinux_file_permission+0xe5/0x116
>> [ 249.897881] ? security_file_permission+0x41/0xbb
>> [ 249.903133] vfs_write+0xb2/0x1a1
>> [ 249.906835] ? syscall_trace_enter+0x1ce/0x2b8
>> [ 249.911795] SyS_write+0x55/0xb9
>> [ 249.915397] do_syscall_64+0x79/0x1ae
>> [ 249.919485] entry_SYSCALL_64_after_hwframe+0x3d/0x0
>>
>> Add code to check whether we have mapping already in the same section and
>> prevent additional mapping from created if that is the case.
>>
>> Signed-off-by: Dave Jiang <dave.jiang@intel.com>
>> ---
>>
>> v2: Change dev_warn() to dev_WARN() to provide helpful backtrace. (Robert E)
> 
> OK, I can reproduce the issue.  What I don't like about your patch is
> that you can still get yourself into trouble.  Just create a namespace
> with a size that isn't aligned to 128MB, and then all further
> create-namespace operations will fail.  The only "fix" is to delete the
> odd-sized namespace and try again.  And that warning message doesn't
> really help the administrator to figure this out.
> 
> Why can't we simply round up to the next section automatically?  Either
> that, or have the kernel export a minimum namespace size of 128MB, and
> have ndctl enforce it?  I know we had some requests for 4MB namespaces,
> but it doesn't sound like those will be very useful if they're going to
> waste 124MB of space.
> 
> Or, we could try to fix this problem of having multiple namespace
> co-exist in the same memblock section.  That seems like the most obvious
> fix, but there must be a reason you didn't pursue it.
> 
> Dave, what do you think is the most viable option?

I know Dan has plans to fix the problem and he has some patches I
believe. But I didn't get a chance to talk to him about this before he
left for his sabbatical. This patch is meant to bandaid the kernel oops
until we can fix the issue properly. But that will need to wait until
Dan is back.

> 
> Cheers,
> Jeff
> 
> 
>>  kernel/memremap.c |   18 +++++++++++++++++-
>>  1 file changed, 17 insertions(+), 1 deletion(-)
>>
>> diff --git a/kernel/memremap.c b/kernel/memremap.c
>> index 5857267a4af5..a734b1747466 100644
>> --- a/kernel/memremap.c
>> +++ b/kernel/memremap.c
>> @@ -176,10 +176,27 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>>  	unsigned long pfn, pgoff, order;
>>  	pgprot_t pgprot = PAGE_KERNEL;
>>  	int error, nid, is_ram;
>> +	struct dev_pagemap *conflict_pgmap;
>>  
>>  	align_start = res->start & ~(SECTION_SIZE - 1);
>>  	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
>>  		- align_start;
>> +	align_end = align_start + align_size - 1;
>> +
>> +	conflict_pgmap = get_dev_pagemap(PHYS_PFN(align_start), NULL);
>> +	if (conflict_pgmap) {
>> +		dev_WARN(dev, "Conflicting mapping in same section\n");
>> +		put_dev_pagemap(conflict_pgmap);
>> +		return ERR_PTR(-ENOMEM);
>> +	}
>> +
>> +	conflict_pgmap = get_dev_pagemap(PHYS_PFN(align_end), NULL);
>> +	if (conflict_pgmap) {
>> +		dev_WARN(dev, "Conflicting mapping in same section\n");
>> +		put_dev_pagemap(conflict_pgmap);
>> +		return ERR_PTR(-ENOMEM);
>> +	}
>> +
>>  	is_ram = region_intersects(align_start, align_size,
>>  		IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
>>  
>> @@ -199,7 +216,6 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>>  
>>  	mutex_lock(&pgmap_lock);
>>  	error = 0;
>> -	align_end = align_start + align_size - 1;
>>  
>>  	foreach_order_pgoff(res, order, pgoff) {
>>  		error = __radix_tree_insert(&pgmap_radix,
>>
>> _______________________________________________
>> Linux-nvdimm mailing list
>> Linux-nvdimm@lists.01.org
>> https://lists.01.org/mailman/listinfo/linux-nvdimm
