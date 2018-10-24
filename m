Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14D7D6B0006
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 11:08:44 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f8-v6so1996536pgo.16
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 08:08:44 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g40-v6si4960046plb.237.2018.10.24.08.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 08:08:42 -0700 (PDT)
Message-ID: <40b17814b2a65531c5059e52a61c8f41b9603904.camel@linux.intel.com>
Subject: Re: [mm PATCH v3 4/6] mm: Move hot-plug specific memory init into
 separate functions and optimize
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Wed, 24 Oct 2018 08:08:41 -0700
In-Reply-To: <20181024123640.GF18839@dhcp22.suse.cz>
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
	 <20181015202716.2171.7284.stgit@localhost.localdomain>
	 <20181017091824.GL18839@dhcp22.suse.cz>
	 <d9011108-4099-58dc-8b8c-110c5f2a3674@linux.intel.com>
	 <20181024123640.GF18839@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Wed, 2018-10-24 at 14:36 +0200, Michal Hocko wrote:
> On Wed 17-10-18 08:26:20, Alexander Duyck wrote:
> [...]
> > With that said I am also wondering if a possible solution to the
> > complaints
> > you had would be to look at just exporting the __init_pageblock
> > function
> > later and moving the call to memmap_init_zone_device out to the
> > memremap or
> > hotplug code when Dan gets the refactoring for HMM and memremap all
> > sorted
> > out.
> 
> Why cannot we simply provide a constructor for each page by the
> caller if there are special requirements? we currently have alt_map
> to do struct page allocation but nothing really prevents to make it
> more generic and control both allocation and initialization whatever
> suits a specific usecase. I really do not want make special cases
> here and there.

The advantage to the current __init_pageblock function is that we end
up constructing everything we are going to write outside of the main
loop and then are focused only on init.

If we end up having to call a per page constructor that is going to
slow things down. For example just that reserved bit setting was adding
something like 4 seconds to the init time for the system. By allowing
it to be configured as a part of the flags outside of the loop I was
able to avoid taking that performance hit.

- Alex
