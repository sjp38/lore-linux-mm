Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE6986B0510
	for <linux-mm@kvack.org>; Thu, 17 May 2018 12:49:52 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f23-v6so3452304wra.20
        for <linux-mm@kvack.org>; Thu, 17 May 2018 09:49:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x40-v6si1467072edx.299.2018.05.17.09.49.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 May 2018 09:49:51 -0700 (PDT)
Date: Thu, 17 May 2018 18:49:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
Message-ID: <20180517164947.GV12670@dhcp22.suse.cz>
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
 <20180517132109.GU12670@dhcp22.suse.cz>
 <20180517133629.GH23723@intel.com>
 <20180517135832.GI23723@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180517135832.GI23723@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 17-05-18 16:58:32, Ville Syrjala wrote:
> On Thu, May 17, 2018 at 04:36:29PM +0300, Ville Syrjala wrote:
> > On Thu, May 17, 2018 at 03:21:09PM +0200, Michal Hocko wrote:
> > > On Thu 17-05-18 15:59:59, Ville Syrjala wrote:
> > > > From: Ville Syrjala <ville.syrjala@linux.intel.com>
> > > > 
> > > > This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
> > > > 
> > > > Make x86 with HIGHMEM=y and CMA=y boot again.
> > > 
> > > Is there any bug report with some more details? It is much more
> > > preferable to fix the issue rather than to revert the whole thing
> > > right away.
> > 
> > The machine I have in front of me right now didn't give me anything.
> > Black screen, and netconsole was silent. No serial port on this
> > machine unfortunately.
> 
> Booted on another machine with serial:

Could you provide your .config please?

[...]
> [    0.000000] cma: Reserved 4 MiB at 0x0000000037000000
[...]
> [    0.000000] BUG: Bad page state in process swapper  pfn:377fe
> [    0.000000] page:f53effc0 count:0 mapcount:-127 mapping:00000000 index:0x0

OK, so this looks the be the source of the problem. -128 would be a
buddy page but I do not see anything that would set the counter to -127
and the real map count updates shouldn't really happen that early.

Maybe CONFIG_DEBUG_VM and CONFIG_DEBUG_HIGHMEM will tell us more.

> [    0.000000] flags: 0x80000000()
> [    0.000000] raw: 80000000 00000000 00000000 ffffff80 00000000 00000100 00000200 00000001
> [    0.000000] page dumped because: nonzero mapcount
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.17.0-rc5-elk+ #145
> [    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
> [    0.000000] Call Trace:
> [    0.000000]  dump_stack+0x60/0x96
> [    0.000000]  bad_page+0x9a/0x100
> [    0.000000]  free_pages_check_bad+0x3f/0x60
> [    0.000000]  free_pcppages_bulk+0x29d/0x5b0
> [    0.000000]  free_unref_page_commit+0x84/0xb0
> [    0.000000]  free_unref_page+0x3e/0x70
> [    0.000000]  __free_pages+0x1d/0x20
> [    0.000000]  free_highmem_page+0x19/0x40
> [    0.000000]  add_highpages_with_active_regions+0xab/0xeb
> [    0.000000]  set_highmem_pages_init+0x66/0x73
> [    0.000000]  mem_init+0x1b/0x1d7
> [    0.000000]  start_kernel+0x17a/0x363
> [    0.000000]  i386_start_kernel+0x95/0x99
> [    0.000000]  startup_32_smp+0x164/0x168

-- 
Michal Hocko
SUSE Labs
