Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6D19C6B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 17:53:46 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id v15so3554965bkz.28
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 14:53:45 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id yv6si12246561bkb.81.2013.11.27.14.53.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 14:53:45 -0800 (PST)
Date: Wed, 27 Nov 2013 17:53:40 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcg: do not declare OOM from __GFP_NOFAIL
 allocations
Message-ID: <20131127225340.GE3556@cmpxchg.org>
References: <1385140676-5677-1-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.02.1311261658170.21003@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311261931210.5973@chino.kir.corp.google.com>
 <20131127163916.GB3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271336220.9222@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311271336220.9222@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Nov 27, 2013 at 01:38:59PM -0800, David Rientjes wrote:
> On Wed, 27 Nov 2013, Johannes Weiner wrote:
> 
> > > Ah, this is because of 3168ecbe1c04 ("mm: memcg: use proper memcg in limit 
> > > bypass") which just bypasses all of these allocations and charges the root 
> > > memcg.  So if allocations want to bypass memcg isolation they just have to 
> > > be __GFP_NOFAIL?
> > 
> > I don't think we have another option.
> > 
> 
> We don't give __GFP_NOFAIL allocations access to memory reserves in the 
> page allocator and we do call the oom killer for them so that a process is 
> killed so that memory is freed.  Why do we have a different policy for 
> memcg?

Oh boy, that's the epic story we dealt with all throughout the last
merge window... ;-)

__GFP_NOFAIL allocations might come in with various filesystem locks
held that could prevent an OOM victim from exiting, so a loop around
the OOM killer in an allocation context is prone to loop endlessly.

Because of this, I changed memcg to never invoke OOM kills from the
allocation context anymore but save it for the end of the page fault
handler.  __GFP_NOFAIL allocations can not fail and thus do not reach
the end of the page fault, so no OOM kill invocation possible.

Arguably, the page allocator should also just return NULL and leave
OOM killing to pagefault_out_of_memory(), but it's much less likely to
get stuck since the overall system has more chances of producing free
memory even without an OOM kill than a memcg with a single process and
no swap for example.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
