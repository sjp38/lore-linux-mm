Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3583C6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 10:56:41 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so34879671lfi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 07:56:41 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id z9si28501557wmz.5.2016.07.13.07.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 07:56:40 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id o80so73478522wme.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 07:56:39 -0700 (PDT)
Date: Wed, 13 Jul 2016 16:56:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160713145638.GM28723@dhcp22.suse.cz>
References: <57837CEE.1010609@redhat.com>
 <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com>
 <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp>
 <20160713133955.GK28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 13-07-16 10:18:35, Mikulas Patocka wrote:
> 
> 
> On Wed, 13 Jul 2016, Michal Hocko wrote:
> 
> > [CC David]
> > 
> > > > It is caused by the commit f9054c70d28bc214b2857cf8db8269f4f45a5e23. 
> > > > Prior to this commit, mempool allocations set __GFP_NOMEMALLOC, so 
> > > > they never exhausted reserved memory. With this commit, mempool 
> > > > allocations drop __GFP_NOMEMALLOC, so they can dig deeper (if the 
> > > > process has PF_MEMALLOC, they can bypass all limits).
> > > 
> > > I wonder whether commit f9054c70d28bc214 ("mm, mempool: only set 
> > > __GFP_NOMEMALLOC if there are free elements") is doing correct thing. 
> > > It says
> > > 
> > >     If an oom killed thread calls mempool_alloc(), it is possible that 
> > > it'll
> > >     loop forever if there are no elements on the freelist since
> > >     __GFP_NOMEMALLOC prevents it from accessing needed memory reserves in
> > >     oom conditions.
> > 
> > I haven't studied the patch very deeply so I might be missing something
> > but from a quick look the patch does exactly what the above says.
> > 
> > mempool_alloc used to inhibit ALLOC_NO_WATERMARKS by default. David has
> > only changed that to allow ALLOC_NO_WATERMARKS if there are no objects
> > in the pool and so we have no fallback for the default __GFP_NORETRY
> > request.
> 
> The swapper core sets the flag PF_MEMALLOC and calls generic_make_request 
> to submit the swapping bio to the block driver. The device mapper driver 
> uses mempools for all its I/O processing.

OK, this is the part I have missed. I didn't realize that the swapout
path, which is indeed PF_MEMALLOC, can get down to blk code which uses
mempools. A quick code travers shows that at least
	make_request_fn = blk_queue_bio
	blk_queue_bio
	  get_request
	    __get_request

might do that. And in that case I agree that the above mentioned patch
has unintentional side effects and should be re-evaluated. David, what
do you think? An obvious fixup would be considering TIF_MEMDIE in
mempool_alloc explicitly.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
