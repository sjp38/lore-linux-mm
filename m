Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA8D46B0008
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 03:06:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c1-v6so726741eds.15
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 00:06:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w37-v6si5275510edb.150.2018.11.02.00.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 00:05:59 -0700 (PDT)
Date: Fri, 2 Nov 2018 08:05:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory_hotplug: cond_resched in __remove_pages
Message-ID: <20181102070557.GO23921@dhcp22.suse.cz>
References: <20181031125840.23982-1-mhocko@kernel.org>
 <20181102035205.GG16399@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181102035205.GG16399@350D>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Johannes Thumshirn <jthumshirn@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 02-11-18 14:52:05, Balbir Singh wrote:
> On Wed, Oct 31, 2018 at 01:58:40PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > We have received a bug report that unbinding a large pmem (>1TB)
> > can result in a soft lockup:
> > [  380.339203] NMI watchdog: BUG: soft lockup - CPU#9 stuck for 23s! [ndctl:4365]
> > [...]
> > [  380.339316] Supported: Yes
> > [  380.339318] CPU: 9 PID: 4365 Comm: ndctl Not tainted 4.12.14-94.40-default #1 SLE12-SP4
> > [  380.339318] Hardware name: Intel Corporation S2600WFD/S2600WFD, BIOS SE5C620.86B.01.00.0833.051120182255 05/11/2018
> > [  380.339319] task: ffff9cce7d4410c0 task.stack: ffffbe9eb1bc4000
> > [  380.339325] RIP: 0010:__put_page+0x62/0x80
> > [  380.339326] RSP: 0018:ffffbe9eb1bc7d30 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff10
> > [  380.339327] RAX: 000040540081c0d3 RBX: ffffeb8f03557200 RCX: 000063af40000000
> > [  380.339328] RDX: 0000000000000002 RSI: ffff9cce75bff498 RDI: ffff9e4a76072ff8
> > [  380.339329] RBP: 0000000a43557200 R08: 0000000000000000 R09: ffffbe9eb1bc7bb0
> > [  380.339329] R10: ffffbe9eb1bc7d08 R11: 0000000000000000 R12: ffff9e194a22a0e0
> > [  380.339330] R13: ffff9cce7062fc10 R14: ffff9e194a22a0a0 R15: ffff9cce6559c0e0
> > [  380.339331] FS:  00007fd132368880(0000) GS:ffff9cce7ea40000(0000) knlGS:0000000000000000
> > [  380.339332] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  380.339332] CR2: 00000000020820a0 CR3: 000000017ef7a003 CR4: 00000000007606e0
> > [  380.339333] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > [  380.339334] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> > [  380.339334] PKRU: 55555554
> > [  380.339334] Call Trace:
> > [  380.339338]  devm_memremap_pages_release+0x152/0x260
> > [  380.339342]  release_nodes+0x18d/0x1d0
> > [  380.339347]  device_release_driver_internal+0x160/0x210
> > [  380.339350]  unbind_store+0xb3/0xe0
> > [  380.339355]  kernfs_fop_write+0x102/0x180
> > [  380.339358]  __vfs_write+0x26/0x150
> > [  380.339363]  ? security_file_permission+0x3c/0xc0
> > [  380.339364]  vfs_write+0xad/0x1a0
> > [  380.339366]  SyS_write+0x42/0x90
> > [  380.339370]  do_syscall_64+0x74/0x150
> > [  380.339375]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
> > [  380.339377] RIP: 0033:0x7fd13166b3d0
> > 
> > It has been reported on an older (4.12) kernel but the current upstream
> > code doesn't cond_resched in the hot remove code at all and the given
> > range to remove might be really large. Fix the issue by calling cond_resched
> > once per memory section.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/memory_hotplug.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 7e6509a53d79..1d87724fa558 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -587,6 +587,7 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> >  	for (i = 0; i < sections_to_remove; i++) {
> >  		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
> >  
> > +		cond_resched();
> >  		ret = __remove_section(zone, __pfn_to_section(pfn), map_offset,
> >  				altmap);
> >  		map_offset = 0;
> 
> Quick math tells me we're doing less than 44GiB's per second of offlining then?
> 
> Here is a quick untested patch that might help with the speed as well
> 
> In hot remove, we try to clear poisoned pages, but
> a small optimization to check if num_poisoned_pages
> is 0 helps remove the iteration through nr_pages.
> 
> NOTE: We can make num_poisoned_pages counter per
> section and speed this up even more in case we
> do have some poisoned pages

yes this makes sense. Could you post a proper patch so that this doesn't
get lost in this thread?
-- 
Michal Hocko
SUSE Labs
