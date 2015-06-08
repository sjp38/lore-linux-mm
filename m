Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4286B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 15:58:48 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so70278611igb.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:58:47 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id ny7si4707590icb.19.2015.06.08.12.58.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 12:58:47 -0700 (PDT)
Received: by igbpi8 with SMTP id pi8so67616973igb.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:58:47 -0700 (PDT)
Date: Mon, 8 Jun 2015 12:58:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is
 configured
In-Reply-To: <201506061551.BHH48489.QHFOMtFLSOFOJV@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1506081252050.13272@chino.kir.corp.google.com>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com> <20150605111302.GB26113@dhcp22.suse.cz> <201506061551.BHH48489.QHFOMtFLSOFOJV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 6 Jun 2015, Tetsuo Handa wrote:

> For me, !__GFP_FS allocations not calling out_of_memory() _forever_ is a
> violation of the user policy.
> 

I agree that we need work in this area to prevent livelocks that rely on 
the contexts of other allocators to make forward progress, but let's be 
clear that panicking the system is not the appropriate response.  It's 
nice and convenient to say we should repurpose panic_on_oom to solve 
livelocks because it triggers a fast reboot in your configuration, but we, 
and certainly others, can't tolerate reboots when the kernel just gives up 
and the majority of the time these situations do resolve themselves.

I think the appropriate place to be attacking this problem is in the page 
allocator, which is responsible for the page allocations in the context of 
the gfp flags given to it, and not the oom killer.  The oom killer is just 
supposed to pick a process, send it a SIGKILL, and give it a reasonable 
expectation of being able to exit.

> If kswapd found nothing more to reclaim and/or kswapd cannot continue
> reclaiming due to lock dependency, can't we consider as out of memory
> because we already tried to reclaim memory which would have been done by
> __GFP_FS allocations?
> 
> Why do we do "!__GFP_FS allocations do not call out_of_memory() because
> they have very limited reclaim ability"? Both GFP_NOFS and GFP_NOIO
> allocations will wake up kswapd due to !__GFP_NO_KSWAPD, doesn't it?
> 

The !__GFP_FS exception is historic because the oom killer would trigger 
waaay too often if it were removed simply because it doesn't have a great 
chance of allowing reclaim to succeed.  Instead, we rely on external 
memory freeing or other parallel allocators being able to reclaim memory.  
What happens when there is no external freeing, nothing else is trying to 
reclaim, or nothing else is able to reclaim?  Yeah, that's the big 
problem.  In my opinion, there's three ways of attacking it: (1) 
preallocation so we are less dependent on the page allocator in these 
contexts, (2) memory reserves in extraordinary circumstances to allow 
forward progress (it's already tunable by min_free_kbytes), and (3) 
eventual page allocation failure when neither of these succeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
