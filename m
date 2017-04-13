Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0998C6B03BB
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 09:05:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k14so6256785wrc.16
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 06:05:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w38si26343839wrc.14.2017.04.13.06.05.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Apr 2017 06:05:26 -0700 (PDT)
Subject: Re: [PATCH 4/9] mm, memory_hotplug: get rid of is_zone_device_section
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-5-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9e379e57-b700-0b48-6e45-a5f6e3cc9010@suse.cz>
Date: Thu, 13 Apr 2017 15:05:24 +0200
MIME-Version: 1.0
In-Reply-To: <20170410110351.12215-5-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@gmail.com>

On 04/10/2017 01:03 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> device memory hotplug hooks into regular memory hotplug only half way.
> It needs memory sections to track struct pages but there is no
> need/desire to associate those sections with memory blocks and export
> them to the userspace via sysfs because they cannot be onlined anyway.
> 
> This is currently expressed by for_device argument to arch_add_memory
> which then makes sure to associate the given memory range with
> ZONE_DEVICE. register_new_memory then relies on is_zone_device_section
> to distinguish special memory hotplug from the regular one. While this
> works now, later patches in this series want to move __add_zone outside
> of arch_add_memory path so we have to come up with something else.
> 
> Add want_memblock down the __add_pages path and use it to control
> whether the section->memblock association should be done. arch_add_memory
> then just trivially want memblock for everything but for_device hotplug.
> 
> remove_memory_section doesn't need is_zone_device_section either. We can
> simply skip all the memblock specific cleanup if there is no memblock
> for the given section.
> 
> This shouldn't introduce any functional change.
> 
> Cc: Dan Williams <dan.j.williams@gmail.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

For the fixed version:

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
