Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7A7A6B025F
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:11:39 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u25so91512333qtb.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:11:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n185si2394953qkd.242.2016.07.13.08.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 08:11:38 -0700 (PDT)
Date: Wed, 13 Jul 2016 11:11:32 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <20160713145638.GM28723@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
References: <57837CEE.1010609@redhat.com> <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com> <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com> <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com> <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com> <2d5e1f84-e886-7b98-cb11-170d7104fd13@I-love.SAKURA.ne.jp> <20160713133955.GK28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713145638.GM28723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Wed, 13 Jul 2016, Michal Hocko wrote:

> On Wed 13-07-16 10:18:35, Mikulas Patocka wrote:
> > 
> > 
> > On Wed, 13 Jul 2016, Michal Hocko wrote:
> > 
> > > [CC David]
> > > 
> > > > > It is caused by the commit f9054c70d28bc214b2857cf8db8269f4f45a5e23. 
> > > > > Prior to this commit, mempool allocations set __GFP_NOMEMALLOC, so 
> > > > > they never exhausted reserved memory. With this commit, mempool 
> > > > > allocations drop __GFP_NOMEMALLOC, so they can dig deeper (if the 
> > > > > process has PF_MEMALLOC, they can bypass all limits).
> > > > 
> > > > I wonder whether commit f9054c70d28bc214 ("mm, mempool: only set 
> > > > __GFP_NOMEMALLOC if there are free elements") is doing correct thing. 
> > > > It says
> > > > 
> > > >     If an oom killed thread calls mempool_alloc(), it is possible that 
> > > > it'll
> > > >     loop forever if there are no elements on the freelist since
> > > >     __GFP_NOMEMALLOC prevents it from accessing needed memory reserves in
> > > >     oom conditions.
> > > 
> > > I haven't studied the patch very deeply so I might be missing something
> > > but from a quick look the patch does exactly what the above says.
> > > 
> > > mempool_alloc used to inhibit ALLOC_NO_WATERMARKS by default. David has
> > > only changed that to allow ALLOC_NO_WATERMARKS if there are no objects
> > > in the pool and so we have no fallback for the default __GFP_NORETRY
> > > request.
> > 
> > The swapper core sets the flag PF_MEMALLOC and calls generic_make_request 
> > to submit the swapping bio to the block driver. The device mapper driver 
> > uses mempools for all its I/O processing.
> 
> OK, this is the part I have missed. I didn't realize that the swapout
> path, which is indeed PF_MEMALLOC, can get down to blk code which uses
> mempools. A quick code travers shows that at least
> 	make_request_fn = blk_queue_bio
> 	blk_queue_bio
> 	  get_request
> 	    __get_request
> 
> might do that. And in that case I agree that the above mentioned patch
> has unintentional side effects and should be re-evaluated. David, what
> do you think? An obvious fixup would be considering TIF_MEMDIE in
> mempool_alloc explicitly.

What are the real problems that f9054c70d28bc214b2857cf8db8269f4f45a5e23 
tries to fix?

Do you have a stacktrace where it deadlocked, or was just a theoretical 
consideration?

Mempool users generally (except for some flawed cases like fs_bio_set) do 
not require memory to proceed. So if you just loop in mempool_alloc, the 
processes that exhasted the mempool reserve will eventually return objects 
to the mempool and you should proceed.

If you can't proceed, it is a bug in the code that uses the mempool.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
