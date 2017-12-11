Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5080D6B0253
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 08:45:44 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id c9so10499320wrb.4
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 05:45:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d4si10703600wrf.458.2017.12.11.05.45.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Dec 2017 05:45:42 -0800 (PST)
Date: Mon, 11 Dec 2017 14:45:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND] x86/numa: move setting parsed numa node to
 num_add_memblk
Message-ID: <20171211134539.GF4779@dhcp22.suse.cz>
References: <1512123232-7263-1-git-send-email-zhongjiang@huawei.com>
 <20171211120304.GD4779@dhcp22.suse.cz>
 <5A2E8131.4000104@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A2E8131.4000104@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, minchan@kernel.org, vbabka@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 11-12-17 20:59:29, zhong jiang wrote:
> On 2017/12/11 20:03, Michal Hocko wrote:
> > On Fri 01-12-17 18:13:52, zhong jiang wrote:
> >> The acpi table are very much like user input. it is likely to
> >> introduce some unreasonable node in some architecture. but
> >> they do not ingore the node and bail out in time. it will result
> >> in unnecessary print.
> >> e.g  x86:  start is equal to end is a unreasonable node.
> >> numa_blk_memblk will fails but return 0.
> >>
> >> meanwhile, Arm64 node will double set it to "numa_node_parsed"
> >> after NUMA adds a memblk successfully.  but X86 is not. because
> >> numa_add_memblk is not set in X86.
> > I am sorry but I still fail to understand wht the actual problem is.
> > You said that x86 will print a message. Alright at least you know that
> > the platform provides a nonsense ACPI/SRAT? tables and you can complain.
> > But does the kernel misbehave? In what way?
>   From the view of  the following code , we should expect that the node is reasonable.
>   otherwise, if we only want to complain,  it should bail out in time after printing the
>   unreasonable message.
> 
>           node_set(node, numa_nodes_parsed);
> 
>         pr_info("SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]%s%s\n",
>                 node, pxm,
>                 (unsigned long long) start, (unsigned long long) end - 1,
>                 hotpluggable ? " hotplug" : "",
>                 ma->flags & ACPI_SRAT_MEM_NON_VOLATILE ? " non-volatile" : "");
> 
>         /* Mark hotplug range in memblock. */
>         if (hotpluggable && memblock_mark_hotplug(start, ma->length))
>                 pr_warn("SRAT: Failed to mark hotplug range [mem %#010Lx-%#010Lx] in memblock\n",
>                         (unsigned long long)start, (unsigned long long)end - 1);
> 
>         max_possible_pfn = max(max_possible_pfn, PFN_UP(end - 1));
> 
>         return 0;
> out_err_bad_srat:
>         bad_srat();
> 
>  In addition.  Arm64  will double set node to numa_nodes_parsed after add a memblk
> successfully.  Because numa_add_memblk will perform node_set(*, *).
> 
>          if (numa_add_memblk(node, start, end) < 0) {
>                 pr_err("SRAT: Failed to add memblk to node %u [mem %#010Lx-%#010Lx]\n",
>                        node, (unsigned long long) start,
>                        (unsigned long long) end - 1);
>                 goto out_err_bad_srat;
>         }
> 
>         node_set(node, numa_nodes_parsed);

I am sorry but I _do not_ understand how this answers my simple
question. You are describing the code flow which doesn't really explain
what is the _user_ or a _runtime_ visible effect. Anybody reading this
changelog will have to scratch his head to understand what the heck does
this fix and whether the patch needs to be considered for backporting.
See my point?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
