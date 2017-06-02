Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 795806B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 03:29:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d15so3539815wme.13
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 00:29:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l19si21007624eda.22.2017.06.02.00.28.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 00:28:59 -0700 (PDT)
Date: Fri, 2 Jun 2017 09:28:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/9] mm: introduce kv[mz]alloc helpers
Message-ID: <20170602072855.GB29840@dhcp22.suse.cz>
References: <20170306103032.2540-1-mhocko@kernel.org>
 <20170306103032.2540-2-mhocko@kernel.org>
 <20170602071718.zk3ujm64xesoqyrr@sasha-lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170602071718.zk3ujm64xesoqyrr@sasha-lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Andreas Dilger <adilger@dilger.ca>, Vlastimil Babka <vbabka@suse.cz>

On Fri 02-06-17 07:17:22, Sasha Levin wrote:
> On Mon, Mar 06, 2017 at 11:30:24AM +0100, Michal Hocko wrote:
> > +void *kvmalloc_node(size_t size, gfp_t flags, int node)
> > +{
> > +	gfp_t kmalloc_flags = flags;
> > +	void *ret;
> > +
> > +	/*
> > +	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
> > +	 * so the given set of flags has to be compatible.
> > +	 */
> > +	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
> 
> Hm, there are quite a few locations in the kernel that do something like:
> 
> 	__vmalloc(len, GFP_NOFS, PAGE_KERNEL);
> 
> According to your patch, vmalloc can't really do GFP_NOFS, right?

Yes. It is quite likely that they will just work because the hardcoded
GFP_KERNEL inside the vmalloc path is in unlikely paths (page table
allocations for example) but yes they are broken. I didn't convert some
places which opencode the kvmalloc with GFP_NOFS because I strongly
_believe_ that the GFP_NOFS should be revisited, checked whether it is
needed, documented if so and then memalloc_nofs__{save,restore} be used
for the scope which is reclaim recursion unsafe. This would turn all
those vmalloc users to the default GFP_KERNEL and still do the right
thing.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
