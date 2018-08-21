Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1914C6B1EB1
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 08:30:27 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c14-v6so2180215wmb.2
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 05:30:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p65-v6sor4202147wrc.66.2018.08.21.05.30.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 05:30:25 -0700 (PDT)
Date: Tue, 21 Aug 2018 14:30:24 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm: Fix comment for NODEMASK_ALLOC
Message-ID: <20180821123024.GA9489@techadventures.net>
References: <20180820085516.9687-1-osalvador@techadventures.net>
 <20180820142440.1f9ccbebefc5d617c881b41e@linux-foundation.org>
 <20180821121734.GA29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180821121734.GA29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, joe@perches.com, arnd@arndb.de, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 21, 2018 at 02:17:34PM +0200, Michal Hocko wrote:
> We do have CONFIG_NODES_SHIFT=10 in our SLES kernels for quite some
> time (around SLE11-SP3 AFAICS).
> 
> Anyway, isn't NODES_ALLOC over engineered a bit? Does actually even do
> larger than 1024 NUMA nodes? This would be 128B and from a quick glance
> it seems that none of those functions are called in deep stacks. I
> haven't gone through all of them but a patch which checks them all and
> removes NODES_ALLOC would be quite nice IMHO.

No, maximum we can get is 1024 NUMA nodes.
I checked this when writing another patch [1], and since having gone
through all archs Kconfigs, CONFIG_NODES_SHIFT=10 is the limit.

NODEMASK_ALLOC gets only called from:

- unregister_mem_sect_under_nodes() (not anymore after [1])
- __nr_hugepages_store_common (This does not seem to have a deep stack, we could use a normal nodemask_t)

But is also used for NODEMASK_SCRATCH (mainly used for mempolicy):

struct nodemask_scratch {
	nodemask_t	mask1;
	nodemask_t	mask2;
};

that would make 256 bytes in case CONFIG_NODES_SHIFT=10.
I am not familiar with mempolicy code, I am not sure if we can do without that and
figure out another way to achieve the same.

[1] https://patchwork.kernel.org/patch/10566673/#22179663 

-- 
Oscar Salvador
SUSE L3
