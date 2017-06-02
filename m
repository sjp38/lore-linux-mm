Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA766B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 03:50:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b84so15337357wmh.0
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 00:50:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si20931267edd.256.2017.06.02.00.50.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 00:50:15 -0700 (PDT)
Date: Fri, 2 Jun 2017 09:50:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/9] mm: introduce kv[mz]alloc helpers
Message-ID: <20170602075012.GC29840@dhcp22.suse.cz>
References: <20170306103032.2540-1-mhocko@kernel.org>
 <20170306103032.2540-2-mhocko@kernel.org>
 <20170602071718.zk3ujm64xesoqyrr@sasha-lappy>
 <20170602072855.GB29840@dhcp22.suse.cz>
 <20170602074008.wctxj5il3rqnnpbf@sasha-lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170602074008.wctxj5il3rqnnpbf@sasha-lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Andreas Dilger <adilger@dilger.ca>, Vlastimil Babka <vbabka@suse.cz>

On Fri 02-06-17 07:40:12, Sasha Levin wrote:
> On Fri, Jun 02, 2017 at 09:28:56AM +0200, Michal Hocko wrote:
> > On Fri 02-06-17 07:17:22, Sasha Levin wrote:
> > > On Mon, Mar 06, 2017 at 11:30:24AM +0100, Michal Hocko wrote:
> > > > +void *kvmalloc_node(size_t size, gfp_t flags, int node)
> > > > +{
> > > > +	gfp_t kmalloc_flags = flags;
> > > > +	void *ret;
> > > > +
> > > > +	/*
> > > > +	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
> > > > +	 * so the given set of flags has to be compatible.
> > > > +	 */
> > > > +	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
> > > 
> > > Hm, there are quite a few locations in the kernel that do something like:
> > > 
> > > 	__vmalloc(len, GFP_NOFS, PAGE_KERNEL);
> > > 
> > > According to your patch, vmalloc can't really do GFP_NOFS, right?
> > 
> > Yes. It is quite likely that they will just work because the hardcoded
> > GFP_KERNEL inside the vmalloc path is in unlikely paths (page table
> > allocations for example) but yes they are broken. I didn't convert some
> > places which opencode the kvmalloc with GFP_NOFS because I strongly
> > _believe_ that the GFP_NOFS should be revisited, checked whether it is
> > needed, documented if so and then memalloc_nofs__{save,restore} be used
> > for the scope which is reclaim recursion unsafe. This would turn all
> > those vmalloc users to the default GFP_KERNEL and still do the right
> > thing.
> 
> While you haven't converted those paths, other folks have picked up
> on that:
> 
> 	commit beeeccca9bebcec386cc31c250cff8a06cf27034
> 	Author: Vinnie Magro <vmagro@fb.com>
> 	Date:   Thu May 25 12:18:02 2017 -0700
> 
> 	    btrfs: Use kvzalloc instead of kzalloc/vmalloc in alloc_bitmap
> 	[...]
> 
> Maybe we should make kvmalloc_node() fail non-GFP_KERNEL allocations
> rather than just warn on them to make this error more evident?

The above has been already discussed [1] and will be dropped with a more
appropriate alternative. I do not think we should be failing those,
though. Supported flags are documented and the warn on will tell that
something is clearly wrong.

>  I'm not sure how these warnings were missed during testing.

I suspect this conversion just hasn't been tested because it is an
"obvious cleanup"

[1] http://lkml.kernel.org/r/20170531063033.GC1795@yexl-desktop

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
