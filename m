Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C27B96B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 12:20:12 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v78so45650161qkl.10
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 09:20:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b134si13843672qkg.144.2017.04.10.09.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 09:20:11 -0700 (PDT)
Date: Mon, 10 Apr 2017 12:20:02 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 4/9] mm, memory_hotplug: get rid of is_zone_device_section
Message-ID: <20170410162002.GA31356@redhat.com>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-5-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170410110351.12215-5-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@gmail.com>

On Mon, Apr 10, 2017 at 01:03:46PM +0200, Michal Hocko wrote:
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
> ---

[...]

> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 342332f29364..1570b3eea493 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -493,7 +493,7 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
>  }
>  
>  static int __meminit __add_section(int nid, struct zone *zone,
> -					unsigned long phys_start_pfn)
> +					unsigned long phys_start_pfn, bool want_memblock)
>  {
>  	int ret;
>  
> @@ -510,7 +510,10 @@ static int __meminit __add_section(int nid, struct zone *zone,
>  	if (ret < 0)
>  		return ret;
>  
> -	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
> +	if (want_memblock)
> +		ret = register_new_memory(nid, __pfn_to_section(phys_start_pfn));
> +
> +	return ret;
>  }

The above is wrong for ZONE_DEVICE sparse_add_one_section() will return a
positive value (on success) thus ret > 0 and other function in the hotplug
path will interpret positive value as an error.

I suggest something like:
	if (!want_memblock)
		return 0;

	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
}

instead (also avoid a > 80 columns warning message).

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
