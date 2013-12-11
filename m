Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 18A956B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 19:11:44 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so4491451yha.21
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:11:43 -0800 (PST)
Received: from mail-yh0-x22a.google.com (mail-yh0-x22a.google.com [2607:f8b0:4002:c01::22a])
        by mx.google.com with ESMTPS id 41si15482264yhf.227.2013.12.10.16.11.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 16:11:43 -0800 (PST)
Received: by mail-yh0-f42.google.com with SMTP id z6so4523014yhz.15
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:11:42 -0800 (PST)
Date: Tue, 10 Dec 2013 16:11:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, page_alloc: make __GFP_NOFAIL really not fail
In-Reply-To: <20131210153909.8b4bfa1d643e5f8582eff7c9@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1312101559590.22701@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1312091355360.11026@chino.kir.corp.google.com> <20131209152202.df3d4051d7dc61ada7c420a9@linux-foundation.org> <alpine.DEB.2.02.1312101504120.22701@chino.kir.corp.google.com>
 <20131210153909.8b4bfa1d643e5f8582eff7c9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 10 Dec 2013, Andrew Morton wrote:

> > Heh, it's difficult to remove __GFP_NOFAIL when new users get added: 
> > 84235de394d9 ("fs: buffer: move allocation failure loop into the 
> > allocator") added a new user
> 
> That wasn't reeeeealy a new user - it was "convert an existing
> open-coded retry-for-ever loop".  Which is what __GFP_NOFAIL is for.
> 

No, it just looks like that's what it did.  find_or_create_page() in that 
function does an order-0 allocation which always implicitly __GFP_NOFAIL 
because of the should_alloc_retry() behavior.  So why does it need to add 
__GFP_NOFAIL there now?  Because it is now allowed to bypass memcg limits 
to the root memcg, which is new behavior with the patch.  It adds 
additional memcg powers that can't be duplicated in the caller, so now 
it's really become __GFP_BYPASS_MEMCG_LIMIT_ON_OOM for everything that was 
doing order-3 or smaller allocations, which should be all existing 
__GFP_NOFAIL users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
