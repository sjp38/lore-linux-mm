Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D92A26B1ECF
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 08:58:49 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id v21-v6so3486689wrc.2
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 05:58:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g40-v6sor3849874wrd.15.2018.08.21.05.58.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 05:58:48 -0700 (PDT)
Date: Tue, 21 Aug 2018 14:58:46 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH] mm: Fix comment for NODEMASK_ALLOC
Message-ID: <20180821125846.GB9489@techadventures.net>
References: <20180820085516.9687-1-osalvador@techadventures.net>
 <20180820142440.1f9ccbebefc5d617c881b41e@linux-foundation.org>
 <20180821121734.GA29735@dhcp22.suse.cz>
 <20180821123024.GA9489@techadventures.net>
 <20180821125156.GB29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180821125156.GB29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, joe@perches.com, arnd@arndb.de, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 21, 2018 at 02:51:56PM +0200, Michal Hocko wrote:
> On Tue 21-08-18 14:30:24, Oscar Salvador wrote:
> > On Tue, Aug 21, 2018 at 02:17:34PM +0200, Michal Hocko wrote:
> > > We do have CONFIG_NODES_SHIFT=10 in our SLES kernels for quite some
> > > time (around SLE11-SP3 AFAICS).
> > > 
> > > Anyway, isn't NODES_ALLOC over engineered a bit? Does actually even do
> > > larger than 1024 NUMA nodes? This would be 128B and from a quick glance
> > > it seems that none of those functions are called in deep stacks. I
> > > haven't gone through all of them but a patch which checks them all and
> > > removes NODES_ALLOC would be quite nice IMHO.
> > 
> > No, maximum we can get is 1024 NUMA nodes.
> > I checked this when writing another patch [1], and since having gone
> > through all archs Kconfigs, CONFIG_NODES_SHIFT=10 is the limit.
> > 
> > NODEMASK_ALLOC gets only called from:
> > 
> > - unregister_mem_sect_under_nodes() (not anymore after [1])
> > - __nr_hugepages_store_common (This does not seem to have a deep stack, we could use a normal nodemask_t)
> > 
> > But is also used for NODEMASK_SCRATCH (mainly used for mempolicy):
> 
> mempolicy code should be a shallow stack as well. Mostly the syscall
> entry.

Ok, then I could give it a try and see if we can get rid of NODEMASK_ALLOC in there
as well.

-- 
Oscar Salvador
SUSE L3
