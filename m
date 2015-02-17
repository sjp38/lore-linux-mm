Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 04A516B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 11:33:20 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id l15so34835505wiw.5
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 08:33:18 -0800 (PST)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id na14si26568545wic.105.2015.02.17.08.33.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 08:33:17 -0800 (PST)
Received: by mail-wi0-f180.google.com with SMTP id h11so35192135wiw.1
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 08:33:16 -0800 (PST)
Date: Tue, 17 Feb 2015 17:33:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150217163314.GH32017@dhcp22.suse.cz>
References: <20141220223504.GI15665@dastard>
 <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
 <20141229181937.GE32618@dhcp22.suse.cz>
 <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
 <20141230112158.GA15546@dhcp22.suse.cz>
 <201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, torvalds@linux-foundation.org

On Mon 16-02-15 20:23:16, Tetsuo Handa wrote:
[...]
> (1) Make several locks killable.
> 
>   On Linux 3.19, running below command line as an unprivileged user
>   on a system with 4 CPUs / 2GB RAM / no swap can make the system unusable.
> 
>   $ for i in `seq 1 100`; do dd if=/dev/zero of=/tmp/file bs=104857600 count=100 & done
> 
[...]
>   This is because the OOM killer happily tries to kill a process which is
>   blocked at unkillable mutex_lock(). If locks shown above were killable,
>   we can reduce the possibility of getting stuck.
> 
>   I didn't check whether it has livelocked or not. But too slow to wait is
>   not acceptable.

Well, you are beating your machine to death so you can hardly get any
time guarantee. It would be nice to have a better feedback mechanism to
know when to back off and fail the allocation attempt which might be
blocking OOM victim to pass away. This is extremely tricky because we
shouldn't be too eager to fail just because of a sudden memory pressure.

>   Oh, why every thread trying to allocate memory has to repeat
>   the loop that might defer somebody who can make progress if CPU time was
>   given?

I guess you are talking about direct reclaim and the whole priority
loop? Well, this is what I was talking above. Sometimes we really have
to go down to low priorities and basically scan the world in order to
find something reclaimable. If we bail out too early we might see pre
mature allocation failures and which could lead to reduced QoS.

>   I wish only somebody like kswapd repeats the loop on behalf of all
>   threads waiting at memory allocation slowpath...

This is the case when the kswapd is _able_ to cope with the memory
pressure.

[...]
> (3) Replace kmalloc() with kmalloc_nofail() and kmalloc_noretry().
> 
>   Currently small allocations are implicitly treated like __GFP_NOFAIL
>   unless TIF_MEMDIE is set. But silently changing small allocations like
>   __GFP_NORETRY will cause obscure bugs. If TIF_MEMDIE timeout is implemented,
>   we will no longer worry about unkillable tasks which is retrying forever at
>   memory allocation; instead we kill more OOM victims and satisfy the request.

I think this is a bad approach. GFP_KERNEL != __GFP_NORETRY and we
should treat it like that. Killing more victims is a bad solution
because it doesn't guarantee any progress (just look at your example of hundreds
processes with large RSS hammering the same file - you would have to
kill all of them at once).
Besides that any timeout solution is prone to unexpected delays due to
reasons which are not related to the allocation latency.

>   Therefore, we could introduce kmalloc_nofail(size, gfp) which does
>   kmalloc(size, gfp | __GFP_NOFAIL) (i.e. invoke the OOM killer) and
>   kmalloc_noretry(size, gfp) which does kmalloc(size, gfp | __GFP_NORETRY)
>   (i.e. do not invoke the OOM killer), and switch from kmalloc() to either
>   kmalloc_noretry() or kmalloc_nofail().

This sounds like a major overkill. We already have gfp flags for that.
What would this buy us?

>   Those who are doing smaller than
>   PAGE_SIZE bytes allocations would wish to switch from kmalloc() to
>   kmalloc_nofail() and eliminate untested memory allocation failure paths.

nofail allocations should be discouraged and used only if any other
measure would fail.

>   Those who are well prepared for memory allocation failures would wish to
>   switch from kmalloc() to kmalloc_noretry(). Eventually, kmalloc() which is
>   implicitly treating small allocations like __GFP_NOFAIL and invoking the
>   OOM killer will be abolished.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
