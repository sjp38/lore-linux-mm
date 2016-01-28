Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id C91E86B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 18:40:33 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id 128so31687091wmz.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 15:40:33 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y142si3642640wmd.54.2016.01.28.15.40.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 15:40:32 -0800 (PST)
Date: Thu, 28 Jan 2016 18:40:18 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: why do we do ALLOC_WMARK_HIGH before going out_of_memory
Message-ID: <20160128234018.GA5530@cmpxchg.org>
References: <20160128163802.GA15953@dhcp22.suse.cz>
 <20160128190204.GJ12228@redhat.com>
 <20160128201123.GB621@dhcp22.suse.cz>
 <20160128211240.GA4163@cmpxchg.org>
 <20160128215514.GF621@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160128215514.GF621@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jan 28, 2016 at 10:55:15PM +0100, Michal Hocko wrote:
> On Thu 28-01-16 16:12:40, Johannes Weiner wrote:
> > On Thu, Jan 28, 2016 at 09:11:23PM +0100, Michal Hocko wrote:
> > > On Thu 28-01-16 20:02:04, Andrea Arcangeli wrote:
> > > > It's not immediately apparent if there is a new OOM killer upstream
> > > > logic that would prevent the risk of a second OOM killer invocation
> > > > despite another OOM killing already happened while we were stuck in
> > > > reclaim. In absence of that, the high wmark check would be still
> > > > needed.
> > > 
> > > Well, my oom detection rework [1] strives to make the OOM detection more
> > > robust and the retry logic performs the watermark check. So I think the
> > > last attempt is no longer needed after that patch. I will then remove
> > > it.
> > 
> > Hm? I don't have the same conclusion from what Andrea said.
> > 
> > When you have many allocations racing at the same time, they can all
> > enter __alloc_pages_may_oom() in quick succession. We don't want a
> > cavalcade of OOM kills when one could be enough, so we have to make
> > sure that in between should_alloc_retry() giving up and acquiring the
> > OOM lock nobody else already issued a kill and released enough memory.
> > 
> > It's a race window that gets yanked wide open when hundreds of threads
> > race in __alloc_pages_may_oom(). Your patches don't fix that, AFAICS.
> 
> Only one task would be allowed to go out_of_memory and all the rest will
> simply fail on oom_lock trylock and return with NULL. Or am I missing
> your point?

Just picture it with mutex_lock() instead of mutex_trylock() and it
becomes obvious why you have to do a locked check before the kill.

The race window is much smaller with the trylock of course, but given
enough threads it's possible that one of the other contenders would
acquire the trylock right after the first task drops it:

first task:                     204th task:
!reclaim                        !reclaim
!should_alloc_retry             !should_alloc_retry
oom_trylock
out_of_memory
oom_unlock
                                oom_trylock
                                out_of_memory // likely unnecessary

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
