Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id EAD9F6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 11:01:13 -0400 (EDT)
Received: by wief7 with SMTP id f7so127576720wie.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 08:01:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f3si34418979wjq.54.2015.05.06.08.01.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 08:01:12 -0700 (PDT)
Date: Wed, 6 May 2015 11:00:58 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] gfp: add __GFP_NOACCOUNT
Message-ID: <20150506150058.GA4705@cmpxchg.org>
References: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
 <20150506115941.GH14550@dhcp22.suse.cz>
 <20150506131622.GA4629@cmpxchg.org>
 <20150506134620.GM14550@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150506134620.GM14550@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, May 06, 2015 at 03:46:20PM +0200, Michal Hocko wrote:
> On Wed 06-05-15 09:16:22, Johannes Weiner wrote:
> > On Wed, May 06, 2015 at 01:59:41PM +0200, Michal Hocko wrote:
> > > On Tue 05-05-15 12:45:42, Vladimir Davydov wrote:
> > > > Not all kmem allocations should be accounted to memcg. The following
> > > > patch gives an example when accounting of a certain type of allocations
> > > > to memcg can effectively result in a memory leak.
> > > 
> > > > This patch adds the __GFP_NOACCOUNT flag which if passed to kmalloc
> > > > and friends will force the allocation to go through the root
> > > > cgroup. It will be used by the next patch.
> > > 
> > > The name of the flag is way too generic. It is not clear that the
> > > accounting is KMEMCG related.
> > 
> > The memory controller is the (primary) component that accounts
> > physical memory allocations in the kernel, so I don't see how this
> > would be ambiguous in any way.
> 
> What if a high-level allocator wants to do some accounting as well?
> E.g. slab allocator accounts {un}reclaimable pages. It is a different
> thing because the accounting is per-cache rather than gfp based but I
> just wanted to point out that accounting is rather a wide term.

This is a concept we have discussed so many times before.  The more
generic or fundamental the functionality in its context, the more
generic the name.  The longer and more specific the name, the more
niche its functionality in that context.

See schedule().

See open().

Accounting is a broad term, but in the context of a physical memory
request I can not think of a more fundamental meaning of "do not
account" - without further qualification - then inhibiting what memcg
does: accounting the requested memory to the caller.

If some allocator would want to modify the accounting of a certain
*type* of memory, then that would be more specific, and a flag to
accomplish this would be expected to have a longer name.

One is a core feature of the VM, the other is a niche aspect of
another core feature of the VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
