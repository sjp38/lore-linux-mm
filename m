Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id C115C6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 18:41:56 -0400 (EDT)
Received: by ieclw1 with SMTP id lw1so23075999iec.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 15:41:56 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id rt10si2397672igb.38.2015.06.09.15.41.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 15:41:56 -0700 (PDT)
Received: by ieclw1 with SMTP id lw1so23075913iec.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 15:41:56 -0700 (PDT)
Date: Tue, 9 Jun 2015 15:41:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oom: How to handle !__GFP_FS exception?
In-Reply-To: <201506092048.BII73411.MOVLQOHJFFFSOt@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1506091529020.30516@chino.kir.corp.google.com>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com> <20150605111302.GB26113@dhcp22.suse.cz> <201506061551.BHH48489.QHFOMtFLSOFOJV@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1506081252050.13272@chino.kir.corp.google.com> <201506092048.BII73411.MOVLQOHJFFFSOt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 9 Jun 2015, Tetsuo Handa wrote:

> > The !__GFP_FS exception is historic because the oom killer would trigger 
> > waaay too often if it were removed simply because it doesn't have a great 
> > chance of allowing reclaim to succeed.  Instead, we rely on external 
> > memory freeing or other parallel allocators being able to reclaim memory.  
> > What happens when there is no external freeing, nothing else is trying to 
> > reclaim, or nothing else is able to reclaim?  Yeah, that's the big 
> > problem.  In my opinion, there's three ways of attacking it: (1) 
> > preallocation so we are less dependent on the page allocator in these 
> > contexts, (2) memory reserves in extraordinary circumstances to allow 
> > forward progress (it's already tunable by min_free_kbytes), and (3) 
> > eventual page allocation failure when neither of these succeed.
> > 
> According to my observations (as posted at
> http://marc.info/?l=linux-mm&m=143239200805478 ), (3) is dangerous because
> it can potentially kill critical processes including global init process.
> Killing a process by invoking the OOM killer sounds safer than (3).
> 

Wow, that's a long changelog :)  I tried my best to look through it and 
http://marc.info/?l=linux-kernel&m=142676304911566 to find where init 
could possibly be killed and it references being killed by SIGBUS at 
pagefault?  I'm not sure how that could be possible since mm_fault_error() 
should be handling VM_FAULT_OOM if any page allocation returns NULL in the 
page fault path.  If that's not being set appropriately (VM_FAULT_OOM on 
page allocation failure), are there stack traces that indicate where that 
might be?  Perhaps this was testing of a patch that was not upstream?

Being killed by SIGBUS certainly should not be the result of the page 
allocator returning NULL, but perhaps I'm missing some failure path that 
never happens because the allocator infinite loop never returns NULL 
today.  Trying option (3), in combination with the others, will 
undoubtedly yield some breakage because of bad failure handling that 
hasn't been exercised before, but this one seems preventable.

> Regarding (2), how can we selectively allow blocking process to access
> memory reserves? Since we don't know the dependency, we can't identify the
> process which should be allowed to access memory reserves. If we allow all
> processes to access memory reserves, unrelated processes could deplete the
> memory reserves while the blocking process is waiting for a lock (either in
> killable or unkillable state). What we need to do to make forward progress
> is not always to allow access to memory reserves. Sometimes making locks
> killable (as posted at http://marc.info/?l=linux-mm&m=142408937117294 )
> helps more.
> 

Yeah, I'm all too familiar with this scenario in the memcg world 
unfortunately.  The only solution that I've come up with, and implemented 
for our kernels to test the theory, is to allow access to memory reserves 
(or for memcg, overcharge) if an allocation continually loops due to the 
oom killer being deferred as a result of a pending oom victim.  Basically, 
my patch causes out_of_memory() to return a pointer to the task_struct of 
the process that we're waiting to exit and the page allocator continually 
checks to ensure it is the same and then when a configurable threshold is 
reached, it gives access to memory reserves.  The thread holding the mutex 
that the oom victim wants will eventually allocate due to this and 
hopefully make forward progress.  The system grinds to a halt if you're 
too conservative in this approach with regards to detecting the infinite 
oom killer deferral.  (How many iterations do you consider to be stall?  
Do you set ALLOC_HIGH | ALLOC_HARDER?  Do you set ALLOC_NO_WATERMARKS?)

> Regarding (1), it would help but insufficient because (2) and (3) unlikely
> work.
> 

Option (1) is somewhat independent of the others and fixable if we find 
situations where memory allocation can be done prior to holding a 
potentially contended mutex.  We hope that nobody is needlessly holding a 
contended mutex while allocating, and that seems to be the case most 
often.  However, there may still be situations where it happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
