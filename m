Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 23A0A6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 11:26:55 -0400 (EDT)
Received: by wijp15 with SMTP id p15so19528354wij.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:26:54 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id jd10si2199791wjb.208.2015.08.25.08.26.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 08:26:53 -0700 (PDT)
Received: by wijp15 with SMTP id p15so19527707wij.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:26:53 -0700 (PDT)
Date: Tue, 25 Aug 2015 17:26:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
Message-ID: <20150825152650.GI6285@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com>
 <20150821081745.GG23723@dhcp22.suse.cz>
 <201508212229.GIC00036.tVFMQLOOFJOFSH@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1508241404380.32561@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1508241404380.32561@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, oleg@redhat.com, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 24-08-15 14:10:10, David Rientjes wrote:
> On Fri, 21 Aug 2015, Tetsuo Handa wrote:
> 
> > Why can't we think about choosing more OOM victims instead of granting access
> > to memory reserves?
> > 
> 
> We have no indication of which thread is holding a mutex that would need 
> to be killed, so we'd be randomly killing processes waiting for forward 
> progress.  A worst-case scenario would be the thread is OOM_DISABLE and we 
> kill every process on the system needlessly.  This problem obviously 
> occurs often enough that killing all userspace isnt going to be a viable 
> solution.
> 
> > Also, SysRq might not be usable under OOM because workqueues can get stuck.
> > The panic_on_oom_timeout was first proposed using a workqueue but was
> > updated to use a timer because there is no guarantee that workqueues work
> > as expected under OOM.
> > 
> 
> I don't know anything about a panic_on_oom_timeout,

You were CCed on the discussion
http://lkml.kernel.org/r/20150609170310.GA8990%40dhcp22.suse.cz

> but panicking would 
> only be a reasonable action if memory reserves were fully depleted.  That 
> could easily be dealt with in the page allocator so there's no timeout 
> involved.

As noted in other email. Just depletion is not a good indicator. The
system can still make a forward progress even when reserves are
depleted.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
