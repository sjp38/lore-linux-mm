Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB0E6B20A5
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 16:52:02 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i68-v6so10345741pfb.9
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 13:52:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r138-v6si14661483pfc.202.2018.08.21.13.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 13:52:01 -0700 (PDT)
Date: Tue, 21 Aug 2018 13:51:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix comment for NODEMASK_ALLOC
Message-Id: <20180821135159.63b77492f44c21ad203cd7b1@linux-foundation.org>
In-Reply-To: <20180821123024.GA9489@techadventures.net>
References: <20180820085516.9687-1-osalvador@techadventures.net>
	<20180820142440.1f9ccbebefc5d617c881b41e@linux-foundation.org>
	<20180821121734.GA29735@dhcp22.suse.cz>
	<20180821123024.GA9489@techadventures.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Michal Hocko <mhocko@kernel.org>, tglx@linutronix.de, joe@perches.com, arnd@arndb.de, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Tue, 21 Aug 2018 14:30:24 +0200 Oscar Salvador <osalvador@techadventures.net> wrote:

> On Tue, Aug 21, 2018 at 02:17:34PM +0200, Michal Hocko wrote:
> > We do have CONFIG_NODES_SHIFT=10 in our SLES kernels for quite some
> > time (around SLE11-SP3 AFAICS).
> > 
> > Anyway, isn't NODES_ALLOC over engineered a bit? Does actually even do
> > larger than 1024 NUMA nodes? This would be 128B and from a quick glance
> > it seems that none of those functions are called in deep stacks. I
> > haven't gone through all of them but a patch which checks them all and
> > removes NODES_ALLOC would be quite nice IMHO.
> 
> No, maximum we can get is 1024 NUMA nodes.
> I checked this when writing another patch [1], and since having gone
> through all archs Kconfigs, CONFIG_NODES_SHIFT=10 is the limit.
> 
> NODEMASK_ALLOC gets only called from:
> 
> - unregister_mem_sect_under_nodes() (not anymore after [1])
> - __nr_hugepages_store_common (This does not seem to have a deep stack, we could use a normal nodemask_t)
> 
> But is also used for NODEMASK_SCRATCH (mainly used for mempolicy):
> 
> struct nodemask_scratch {
> 	nodemask_t	mask1;
> 	nodemask_t	mask2;
> };
> 
> that would make 256 bytes in case CONFIG_NODES_SHIFT=10.

And that sole site could use an open-coded kmalloc.
