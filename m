Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7A56B0491
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:44:12 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k80so12309852wrc.15
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 15:44:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u19si2522041wrg.502.2017.08.17.15.44.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 15:44:10 -0700 (PDT)
Date: Thu, 17 Aug 2017 15:44:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] swap: choose swap device according to numa node
Message-Id: <20170817154408.66c37d2d84eccdb102b9e04c@linux-foundation.org>
In-Reply-To: <20170816024439.GA10925@aaronlu.sh.intel.com>
References: <20170814053130.GD2369@aaronlu.sh.intel.com>
	<20170814163337.92c9f07666645366af82aba2@linux-foundation.org>
	<20170815054944.GF2369@aaronlu.sh.intel.com>
	<20170815150947.9b7ccea78c5ea28ae88ba87f@linux-foundation.org>
	<20170816024439.GA10925@aaronlu.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Huang Ying <ying.huang@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>

On Wed, 16 Aug 2017 10:44:40 +0800 Aaron Lu <aaron.lu@intel.com> wrote:

> 
> If the system has more than one swap device and swap device has the node
> information, we can make use of this information to decide which swap
> device to use in get_swap_pages() to get better performance.
> 
> The current code uses a priority based list, swap_avail_list, to decide
> which swap device to use and if multiple swap devices share the same
> priority, they are used round robin.  This patch changes the previous
> single global swap_avail_list into a per-numa-node list, i.e.  for each
> numa node, it sees its own priority based list of available swap devices.
> Swap device's priority can be promoted on its matching node's
> swap_avail_list.
> 
> The current swap device's priority is set as: user can set a >=0 value, or
> the system will pick one starting from -1 then downwards.  The priority
> value in the swap_avail_list is the negated value of the swap device's due
> to plist being sorted from low to high.  The new policy doesn't change the
> semantics for priority >=0 cases, the previous starting from -1 then
> downwards now becomes starting from -2 then downwards and -1 is reserved
> as the promoted value.
> 
> ...
>
> +static int __init swapfile_init(void)
> +{
> +	int nid;
> +
> +	swap_avail_heads = kmalloc(nr_node_ids * sizeof(struct plist_head), GFP_KERNEL);

I suppose we should use kmalloc_array(), as someone wrote it for us.

--- a/mm/swapfile.c~swap-choose-swap-device-according-to-numa-node-v2-fix
+++ a/mm/swapfile.c
@@ -3700,7 +3700,8 @@ static int __init swapfile_init(void)
 {
 	int nid;
 
-	swap_avail_heads = kmalloc(nr_node_ids * sizeof(struct plist_head), GFP_KERNEL);
+	swap_avail_heads = kmalloc_array(nr_node_ids, sizeof(struct plist_head),
+					 GFP_KERNEL);
 	if (!swap_avail_heads) {
 		pr_emerg("Not enough memory for swap heads, swap is disabled\n");
 		return -ENOMEM;

> +	if (!swap_avail_heads) {
> +		pr_emerg("Not enough memory for swap heads, swap is disabled\n");

checkpatch tells us that the "Not enough memory" is a bit redundant, as
the memory allocator would have already warned.  So it's sufficient to
additionally say only "swap is disabled" here.  But it's hardly worth
changing.

> +		return -ENOMEM;
> +	}
> +
> +	for_each_node(nid)
> +		plist_head_init(&swap_avail_heads[nid]);
> +
> +	return 0;
> +}
> +subsys_initcall(swapfile_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
