Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E33EB8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:44:38 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id c11so5541046wrx.4
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 01:44:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j64-v6sor935479wmd.15.2018.09.28.01.44.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 01:44:35 -0700 (PDT)
Date: Fri, 28 Sep 2018 10:44:33 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20180928084433.GB25561@techadventures.net>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20180926075540.GD6278@dhcp22.suse.cz>
 <6f87a5d7-05e2-00f4-8568-bb3521869cea@linux.intel.com>
 <20180927110926.GE6278@dhcp22.suse.cz>
 <20180927122537.GA20378@techadventures.net>
 <20180927131329.GI6278@dhcp22.suse.cz>
 <20180928081224.GA25561@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180928081224.GA25561@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Fri, Sep 28, 2018 at 10:12:24AM +0200, Oscar Salvador wrote:
> Although I am not sure about leaving memmap_init_zone unprotected.
> For the normal memory, that is not a problem since the memblock's lock
> protects us from touching the same pages at the same time in online/offline_pages,
> but for HMM/devm the story is different.
> 
> I am totally unaware of HMM/devm, so I am not sure if its protected somehow.
> e.g: what happens if devm_memremap_pages and devm_memremap_pages_release are running
> at the same time for the same memory-range (with the assumption that the hotplug-lock
> does not protect move_pfn_range_to_zone anymore).

I guess that this could not happen since the device is not linked to devm_memremap_pages_release
until the end with:

devm_add_action(dev, devm_memremap_pages_release, pgmap)
-- 
Oscar Salvador
SUSE L3
