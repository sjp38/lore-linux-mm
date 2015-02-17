Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 157F46B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 08:16:28 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id n12so18795031wgh.1
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 05:16:27 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hj1si23033833wib.62.2015.02.17.05.16.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 05:16:26 -0800 (PST)
Date: Tue, 17 Feb 2015 08:16:18 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150217131618.GA14778@phnom.home.cmpxchg.org>
References: <20141229181937.GE32618@dhcp22.suse.cz>
 <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
 <20141230112158.GA15546@dhcp22.suse.cz>
 <201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
 <20150216154201.GA27295@phnom.home.cmpxchg.org>
 <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

On Tue, Feb 17, 2015 at 08:57:05PM +0900, Tetsuo Handa wrote:
> Johannes Weiner wrote:
> > On Mon, Feb 16, 2015 at 08:23:16PM +0900, Tetsuo Handa wrote:
> > >   (2) Implement TIF_MEMDIE timeout.
> > 
> > How about something like this?  This should solve the deadlock problem
> > in the page allocator, but it would also simplify the memcg OOM killer
> > and allow its use by in-kernel faults again.
> 
> Yes, basic idea would be same with
> http://marc.info/?l=linux-mm&m=142002495532320&w=2 .
> 
> But Michal and David do not like the timeout approach.
> http://marc.info/?l=linux-mm&m=141684783713564&w=2
> http://marc.info/?l=linux-mm&m=141686814824684&w=2

I'm open to suggestions, but we can't just stick our heads in the sand
and pretend that these are just unrelated bugs.  They're not.  As long
as it's legal to enter the allocator with *anything* that can prevent
another random task in the system from making progress, we have this
deadlock potential.  One side has to give up, and it can't be the page
allocator because it has to support __GFP_NOFAIL allocations, which
are usually exactly the allocations that are buried in hard-to-unwind
state that is likely to trip up exiting OOM victims.

The alternative would be lock dependency tracking, but I'm not sure it
can be realistically done for production environments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
