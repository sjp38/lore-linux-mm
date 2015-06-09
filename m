Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C096E6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 08:36:11 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so14319445pdb.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:36:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h13si8812941pdk.53.2015.06.09.05.36.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 05:36:10 -0700 (PDT)
Subject: Re: oom: How to handle !__GFP_FS exception?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
	<alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com>
	<20150605111302.GB26113@dhcp22.suse.cz>
	<201506061551.BHH48489.QHFOMtFLSOFOJV@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1506081252050.13272@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1506081252050.13272@chino.kir.corp.google.com>
Message-Id: <201506092048.BII73411.MOVLQOHJFFFSOt@I-love.SAKURA.ne.jp>
Date: Tue, 9 Jun 2015 20:48:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: mhocko@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes wrote:
> On Sat, 6 Jun 2015, Tetsuo Handa wrote:
> 
> > For me, !__GFP_FS allocations not calling out_of_memory() _forever_ is a
> > violation of the user policy.
> > 
> 
> I agree that we need work in this area to prevent livelocks that rely on 
> the contexts of other allocators to make forward progress, but let's be 
> clear that panicking the system is not the appropriate response.  It's 
> nice and convenient to say we should repurpose panic_on_oom to solve 
> livelocks because it triggers a fast reboot in your configuration, but we, 
> and certainly others, can't tolerate reboots when the kernel just gives up 
> and the majority of the time these situations do resolve themselves.
> 
> I think the appropriate place to be attacking this problem is in the page 
> allocator, which is responsible for the page allocations in the context of 
> the gfp flags given to it, and not the oom killer.  The oom killer is just 
> supposed to pick a process, send it a SIGKILL, and give it a reasonable 
> expectation of being able to exit.
> 
> > If kswapd found nothing more to reclaim and/or kswapd cannot continue
> > reclaiming due to lock dependency, can't we consider as out of memory
> > because we already tried to reclaim memory which would have been done by
> > __GFP_FS allocations?
> > 
> > Why do we do "!__GFP_FS allocations do not call out_of_memory() because
> > they have very limited reclaim ability"? Both GFP_NOFS and GFP_NOIO
> > allocations will wake up kswapd due to !__GFP_NO_KSWAPD, doesn't it?
> > 
> 
> The !__GFP_FS exception is historic because the oom killer would trigger 
> waaay too often if it were removed simply because it doesn't have a great 
> chance of allowing reclaim to succeed.  Instead, we rely on external 
> memory freeing or other parallel allocators being able to reclaim memory.  
> What happens when there is no external freeing, nothing else is trying to 
> reclaim, or nothing else is able to reclaim?  Yeah, that's the big 
> problem.  In my opinion, there's three ways of attacking it: (1) 
> preallocation so we are less dependent on the page allocator in these 
> contexts, (2) memory reserves in extraordinary circumstances to allow 
> forward progress (it's already tunable by min_free_kbytes), and (3) 
> eventual page allocation failure when neither of these succeed.
> 
According to my observations (as posted at
http://marc.info/?l=linux-mm&m=143239200805478 ), (3) is dangerous because
it can potentially kill critical processes including global init process.
Killing a process by invoking the OOM killer sounds safer than (3).

Regarding (2), how can we selectively allow blocking process to access
memory reserves? Since we don't know the dependency, we can't identify the
process which should be allowed to access memory reserves. If we allow all
processes to access memory reserves, unrelated processes could deplete the
memory reserves while the blocking process is waiting for a lock (either in
killable or unkillable state). What we need to do to make forward progress
is not always to allow access to memory reserves. Sometimes making locks
killable (as posted at http://marc.info/?l=linux-mm&m=142408937117294 )
helps more.

Regarding (1), it would help but insufficient because (2) and (3) unlikely
work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
