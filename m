Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7DA6B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 05:20:53 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y10so650775wgg.0
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 02:20:52 -0800 (PST)
Received: from mail-ea0-x231.google.com (mail-ea0-x231.google.com [2a00:1450:4013:c01::231])
        by mx.google.com with ESMTPS id cn2si12254348wid.3.2013.11.28.02.20.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 02:20:51 -0800 (PST)
Received: by mail-ea0-f177.google.com with SMTP id n15so5553401ead.36
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 02:20:51 -0800 (PST)
Date: Thu, 28 Nov 2013 11:20:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcg: do not declare OOM from __GFP_NOFAIL
 allocations
Message-ID: <20131128102049.GF2761@dhcp22.suse.cz>
References: <1385140676-5677-1-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.02.1311261658170.21003@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311261931210.5973@chino.kir.corp.google.com>
 <20131127163916.GB3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271336220.9222@chino.kir.corp.google.com>
 <20131127225340.GE3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271526080.22848@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311271526080.22848@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 27-11-13 15:34:24, David Rientjes wrote:
> On Wed, 27 Nov 2013, Johannes Weiner wrote:
> 
> > > We don't give __GFP_NOFAIL allocations access to memory reserves in the 
> > > page allocator and we do call the oom killer for them so that a process is 
> > > killed so that memory is freed.  Why do we have a different policy for 
> > > memcg?
> > 
> > Oh boy, that's the epic story we dealt with all throughout the last
> > merge window... ;-)
> > 
> > __GFP_NOFAIL allocations might come in with various filesystem locks
> > held that could prevent an OOM victim from exiting, so a loop around
> > the OOM killer in an allocation context is prone to loop endlessly.
> > 
> 
> Ok, so let's forget about GFP_KERNEL | __GFP_NOFAIL since anything doing 
> __GFP_FS should not be holding such locks, we have some of those in the 
> drivers code and that makes sense that they are doing GFP_KERNEL.
> 
> Focusing on the GFP_NOFS | __GFP_NOFAIL allocations in the filesystem 
> code, the kernel oom killer independent of memcg never gets called because 
> !__GFP_FS and they'll simply loop around the page allocator forever.
> 
> In the past, Andrew has expressed the desire to get rid of __GFP_NOFAIL 
> entirely since it's flawed when combined with GFP_NOFS (and GFP_KERNEL | 
> __GFP_NOFAIL could simply be reimplemented in the caller) because of the 
> reason you point out in addition to making it very difficult in the page 
> allocator to free memory independent of memcg.
> 
> So I'm wondering if we should just disable the oom killer in memcg for 
> __GFP_NOFAIL as you've done here, but not bypass to the root memcg and 
> just allow them to spin?  I think we should be focused on the fixing the 
> callers rather than breaking memcg isolation.

What if the callers simply cannot deal with the allocation failure?
84235de394d97 (fs: buffer: move allocation failure loop into the
allocator) describes one such case when __getblk_slow tries desperately
to grow buffers relying on the reclaim to free something. As there might
be no reclaim going on we are screwed.

That being said, while I do agree with you that we should strive for
isolation as much as possible there are certain cases when this is
impossible to achieve without seeing much worse consequences. For now,
we hope that __GFP_NOFAIL is used very scarcely.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
