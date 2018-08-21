Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8FF6B1EC4
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 08:52:00 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id q29-v6so1956541edd.0
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 05:52:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2-v6si2598404edt.286.2018.08.21.05.51.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 05:51:59 -0700 (PDT)
Date: Tue, 21 Aug 2018 14:51:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Fix comment for NODEMASK_ALLOC
Message-ID: <20180821125156.GB29735@dhcp22.suse.cz>
References: <20180820085516.9687-1-osalvador@techadventures.net>
 <20180820142440.1f9ccbebefc5d617c881b41e@linux-foundation.org>
 <20180821121734.GA29735@dhcp22.suse.cz>
 <20180821123024.GA9489@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180821123024.GA9489@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, joe@perches.com, arnd@arndb.de, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Tue 21-08-18 14:30:24, Oscar Salvador wrote:
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

mempolicy code should be a shallow stack as well. Mostly the syscall
entry.

-- 
Michal Hocko
SUSE Labs
