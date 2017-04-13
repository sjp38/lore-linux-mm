Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 595CE6B03BF
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 10:05:21 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o21so6459735wrb.9
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 07:05:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h141si13239672wmd.152.2017.04.13.07.05.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Apr 2017 07:05:19 -0700 (PDT)
Subject: Re: [PATCH 5/9] mm, memory_hotplug: split up register_one_node
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-6-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a06d1e36-f8ae-c8c5-dd2c-e535cf740ed6@suse.cz>
Date: Thu, 13 Apr 2017 16:05:17 +0200
MIME-Version: 1.0
In-Reply-To: <20170410110351.12215-6-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/10/2017 01:03 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Memory hotplug (add_memory_resource) has to reinitialize node
> infrastructure if the node is offline (one which went through the
> complete add_memory(); remove_memory() cycle). That involves node
> registration to the kobj infrastructure (register_node), the proper
> association with cpus (register_cpu_under_node) and finally creation of
> node<->memblock symlinks (link_mem_sections).
> 
> The last part requires to know node_start_pfn and node_spanned_pages
> which we currently have but a leter patch will postpone this
> initialization to the onlining phase which happens later. In fact we do
> not need to rely on the early pgdat initialization even now because the
> currently hot added pfn range is currently known.
> 
> Split register_one_node into core which does all the common work for
> the boot time NUMA initialization and the hotplug (__register_one_node).
> register_one_node keeps the full initialization while hotplug calls
> __register_one_node and manually calls link_mem_sections for the proper
> range.
> 
> This shouldn't introduce any functional change.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

nit:
> @@ -1387,7 +1387,22 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
>  	node_set_online(nid);
>  
>  	if (new_node) {
> -		ret = register_one_node(nid);
> +		unsigned long start_pfn = start >> PAGE_SHIFT;
> +		unsigned long nr_pages = size >> PAGE_SHIFT;
> +
> +		ret = __register_one_node(nid);
> +		if (ret)
> +			goto register_fail;
> +
> +		/*
> +		 * link memory sections under this node. This is already
> +		 * done when creatig memory section in register_new_memory
> +		 * but that depends to have the node registered so offline
> +		 * nodes have to go through register_node.
> +		 * TODO clean up this mess.

Is this a work-in-progress or final TODO? :)

> +		 */
> +		ret = link_mem_sections(nid, start_pfn, nr_pages);
> +register_fail:
>  		/*
>  		 * If sysfs file of new node can't create, cpu on the node
>  		 * can't be hot-added. There is no rollback way now.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
