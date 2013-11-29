Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4FDFE6B0035
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 18:46:20 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so7103190yhz.8
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 15:46:20 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id r46si29821392yhm.297.2013.11.29.15.46.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Nov 2013 15:46:19 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so7199917yha.12
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 15:46:18 -0800 (PST)
Date: Fri, 29 Nov 2013 15:46:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: memcg: do not declare OOM from __GFP_NOFAIL
 allocations
In-Reply-To: <20131128102049.GF2761@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1311291543400.22413@chino.kir.corp.google.com>
References: <1385140676-5677-1-git-send-email-hannes@cmpxchg.org> <alpine.DEB.2.02.1311261658170.21003@chino.kir.corp.google.com> <alpine.DEB.2.02.1311261931210.5973@chino.kir.corp.google.com> <20131127163916.GB3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271336220.9222@chino.kir.corp.google.com> <20131127225340.GE3556@cmpxchg.org> <alpine.DEB.2.02.1311271526080.22848@chino.kir.corp.google.com> <20131128102049.GF2761@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 28 Nov 2013, Michal Hocko wrote:

> > Ok, so let's forget about GFP_KERNEL | __GFP_NOFAIL since anything doing 
> > __GFP_FS should not be holding such locks, we have some of those in the 
> > drivers code and that makes sense that they are doing GFP_KERNEL.
> > 
> > Focusing on the GFP_NOFS | __GFP_NOFAIL allocations in the filesystem 
> > code, the kernel oom killer independent of memcg never gets called because 
> > !__GFP_FS and they'll simply loop around the page allocator forever.
> > 
> > In the past, Andrew has expressed the desire to get rid of __GFP_NOFAIL 
> > entirely since it's flawed when combined with GFP_NOFS (and GFP_KERNEL | 
> > __GFP_NOFAIL could simply be reimplemented in the caller) because of the 
> > reason you point out in addition to making it very difficult in the page 
> > allocator to free memory independent of memcg.
> > 
> > So I'm wondering if we should just disable the oom killer in memcg for 
> > __GFP_NOFAIL as you've done here, but not bypass to the root memcg and 
> > just allow them to spin?  I think we should be focused on the fixing the 
> > callers rather than breaking memcg isolation.
> 
> What if the callers simply cannot deal with the allocation failure?
> 84235de394d97 (fs: buffer: move allocation failure loop into the
> allocator) describes one such case when __getblk_slow tries desperately
> to grow buffers relying on the reclaim to free something. As there might
> be no reclaim going on we are screwed.
> 

My suggestion is to spin, not return NULL.  Bypassing to the root memcg 
can lead to a system oom condition whereas if memcg weren't involved at 
all the page allocator would just spin (because of !__GFP_FS).

> That being said, while I do agree with you that we should strive for
> isolation as much as possible there are certain cases when this is
> impossible to achieve without seeing much worse consequences. For now,
> we hope that __GFP_NOFAIL is used very scarcely.

If that's true, why not bypass the per-zone min watermarks in the page 
allocator as well to allow these allocations to succeed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
