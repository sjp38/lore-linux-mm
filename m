Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 149208E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 09:13:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b21-v6so3012184edt.18
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 06:13:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w10-v6si103652ejq.58.2018.09.27.06.13.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 06:13:32 -0700 (PDT)
Date: Thu, 27 Sep 2018 15:13:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20180927131329.GI6278@dhcp22.suse.cz>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20180926075540.GD6278@dhcp22.suse.cz>
 <6f87a5d7-05e2-00f4-8568-bb3521869cea@linux.intel.com>
 <20180927110926.GE6278@dhcp22.suse.cz>
 <20180927122537.GA20378@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180927122537.GA20378@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Thu 27-09-18 14:25:37, Oscar Salvador wrote:
> On Thu, Sep 27, 2018 at 01:09:26PM +0200, Michal Hocko wrote:
> > > So there were a few things I wasn't sure we could pull outside of the
> > > hotplug lock. One specific example is the bits related to resizing the pgdat
> > > and zone. I wanted to avoid pulling those bits outside of the hotplug lock.
> > 
> > Why would that be a problem. There are dedicated locks for resizing.
> 
> True is that move_pfn_range_to_zone() manages the locks for pgdat/zone resizing,
> but it also takes care of calling init_currently_empty_zone() in case the zone is empty.
> Could not that be a problem if we take move_pfn_range_to_zone() out of the lock?

I would have to double check but is the hotplug lock really serializing
access to the state initialized by init_currently_empty_zone? E.g.
zone_start_pfn is a nice example of a state that is used outside of the
lock. zone's free lists are similar. So do we really need the hoptlug
lock? And more broadly, what does the hotplug lock is supposed to
serialize in general. A proper documentation would surely help to answer
these questions. There is way too much of "do not touch this code and
just make my particular hack" mindset which made the whole memory
hotplug a giant pile of mess. We really should start with some proper
engineering here finally.
-- 
Michal Hocko
SUSE Labs
