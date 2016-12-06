Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9302D6B025E
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 03:34:45 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xy5so68538036wjc.0
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 00:34:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c63si2678813wmf.97.2016.12.06.00.34.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Dec 2016 00:34:44 -0800 (PST)
Date: Tue, 6 Dec 2016 09:34:42 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: use vmalloc fallback path for certain memcg
 allocations
Message-ID: <20161206083442.GB18664@dhcp22.suse.cz>
References: <1480554981-195198-1-git-send-email-astepanov@cloudlinux.com>
 <03a17767-1322-3466-a1f1-dba2c6862be4@suse.cz>
 <20161202091933.GD6830@dhcp22.suse.cz>
 <20161202065417.GB358195@stepanov.centos7>
 <20161205052325.GA30758@dhcp22.suse.cz>
 <20161205140932.GC8045@osiris>
 <20161205141928.GM30758@dhcp22.suse.cz>
 <20161202221510.GB536156@stepanov.centos7>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202221510.GB536156@stepanov.centos7>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anatoly Stepanov <astepanov@cloudlinux.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, akpm@linux-foundation.org, vdavydov.dev@gmail.com, umka@cloudlinux.com, panda@cloudlinux.com, vmeshkov@cloudlinux.com

On Sat 03-12-16 01:15:10, Anatoly Stepanov wrote:
> On Mon, Dec 05, 2016 at 03:19:29PM +0100, Michal Hocko wrote:
> > On Mon 05-12-16 15:09:33, Heiko Carstens wrote:
> > > On Mon, Dec 05, 2016 at 06:23:26AM +0100, Michal Hocko wrote:
> > > > > > 
> > > > > > 	ret = kzalloc(size, gfp_mask);
> > > > > > 	if (ret)
> > > > > > 		return ret;
> > > > > > 	return vzalloc(size);
> > > > > > 
> > > > > 
> > > > > > I also do not like memcg_alloc helper name. It suggests we are
> > > > > > allocating a memcg while it is used for cache arrays and slab LRUS.
> > > > > > Anyway this pattern is quite widespread in the kernel so I would simply
> > > > > > suggest adding kvmalloc function instead.
> > > > > 
> > > > > Agreed, it would be nice to have a generic call.
> > > > > I would suggest an impl. like this:
> > > > > 
> > > > > void *kvmalloc(size_t size)
> > > > 
> > > > gfp_t gfp_mask should be a parameter as this should be a generic helper.
> > > > 
> > > > > {
> > > > > 	gfp_t gfp_mask = GFP_KERNEL;
> > > > 
> > > > 
> > > > > 	void *ret;
> > > > > 
> > > > >  	if (size > PAGE_SIZE)
> > > > >  		gfp_mask |= __GFP_NORETRY | __GFP_NOWARN;
> > > > > 
> > > > > 
> > > > > 	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
> > > > > 		ret = kzalloc(size, gfp_mask);
> > > > > 		if (ret)
> > > > > 			return ret;
> > > > > 	}
> > > > 
> > > > No, please just do as suggested above. Tweak the gfp_mask for higher
> > > > order requests and do kmalloc first with vmalloc as a  fallback.
> > > 
> > > You may simply use the slightly different and open-coded variant within
> > > fs/seq_file.c:seq_buf_alloc(). That one got a lot of testing in the
> > > meantime...
> > 
> > Yeah. I would just add WARN_ON((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
> > to catch users who might want to rely on GFP_NOFS, GFP_NOWAIT or other
> > restricted requests because vmalloc cannot cope with those properly.
> 
> What about __vmalloc(size, gfp, prot)? I guess it's fine with theese

Not really. Parts of the vmalloc allocator still use hardcoded
GFP_KERNEL AFAIR.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
