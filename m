Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 001A06B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 07:53:00 -0400 (EDT)
Received: by iods203 with SMTP id s203so5622344iod.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 04:53:00 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id p1si1729874igy.59.2015.08.19.04.52.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 04:52:59 -0700 (PDT)
Received: by igbjg10 with SMTP id jg10so102705518igb.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 04:52:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1439781546-7217-4-git-send-email-jiang.liu@linux.intel.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
	<1439781546-7217-4-git-send-email-jiang.liu@linux.intel.com>
Date: Wed, 19 Aug 2015 06:52:59 -0500
Message-ID: <CAPp3RGoo3ZPTApwezua01Adjt1JaBraCTUCF0BcN=SKJfQO0iQ@mail.gmail.com>
Subject: Re: [Patch V3 3/9] sgi-xp: Replace cpu_to_node() with cpu_to_mem() to
 support memoryless node
From: Robin Holt <robinmholt@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Cliff Whickman <cpw@sgi.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, x86@kernel.org

On Sun, Aug 16, 2015 at 10:19 PM, Jiang Liu <jiang.liu@linux.intel.com> wrote:
> Function xpc_create_gru_mq_uv() allocates memory with __GFP_THISNODE
> flag set, which may cause permanent memory allocation failure on
> memoryless node. So replace cpu_to_node() with cpu_to_mem() to better
> support memoryless node. For node with memory, cpu_to_mem() is the same
> as cpu_to_node().
>
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  drivers/misc/sgi-xp/xpc_uv.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
> index 95c894482fdd..9210981c0d5b 100644
> --- a/drivers/misc/sgi-xp/xpc_uv.c
> +++ b/drivers/misc/sgi-xp/xpc_uv.c
> @@ -238,7 +238,7 @@ xpc_create_gru_mq_uv(unsigned int mq_size, int cpu, char *irq_name,
>
>         mq->mmr_blade = uv_cpu_to_blade_id(cpu);
>
> -       nid = cpu_to_node(cpu);
> +       nid = cpu_to_mem(cpu);

I would recommend rejecting this.  First, SGI's UV system does not and
can not support memory-less nodes.  Additionally the hardware _REALLY_
wants the memory to be local to the CPU.  We will register this memory
region with the node firmware.  That will set the hardware up to watch
this memory block and raise an IRQ targeting the registered CPU when
anything is written into the memory block.  This is all part of how
cross-partition communications expects to work.

Additionally, the interrupt handler will read the memory region, so
having node-local memory is extremely helpful.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
