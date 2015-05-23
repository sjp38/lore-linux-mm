Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id DAC6D829A8
	for <linux-mm@kvack.org>; Sat, 23 May 2015 11:35:07 -0400 (EDT)
Received: by oige141 with SMTP id e141so33188896oig.1
        for <linux-mm@kvack.org>; Sat, 23 May 2015 08:35:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e8si3411564obo.53.2015.05.23.08.35.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 23 May 2015 08:35:06 -0700 (PDT)
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150429144031.GB31341@dhcp22.suse.cz>
	<201504300227.JCJ81217.FHOLSQVOFFJtMO@I-love.SAKURA.ne.jp>
	<20150429183135.GH31341@dhcp22.suse.cz>
	<201504301844.CFE13027.FOMtJHQOFSOFVL@I-love.SAKURA.ne.jp>
	<20150430142534.GA16964@dhcp22.suse.cz>
In-Reply-To: <20150430142534.GA16964@dhcp22.suse.cz>
Message-Id: <201505232342.GAG17682.QJOFOVLHOtSFFM@I-love.SAKURA.ne.jp>
Date: Sat, 23 May 2015 23:42:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: david@fromorbit.com, hannes@cmpxchg.org, akpm@linux-foundation.org, aarcange@redhat.com, rientjes@google.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 30-04-15 18:44:25, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > I mean we should eventually fail all the allocation types but GFP_NOFS
> > > is coming from _carefully_ handled code paths which is an easier starting
> > > point than a random code path in the kernel/drivers. So can we finally
> > > move at least in this direction?
> > 
> > I agree that all the allocation types can fail unless GFP_NOFAIL is given.
> > But I also expect that all the allocation types should not fail unless
> > order > PAGE_ALLOC_COSTLY_ORDER or GFP_NORETRY is given or chosen as an OOM
> > victim.
> 
> Yeah, let's keep shooting our feet and then look for workarounds to deal
> with it...
>  
> > We already experienced at Linux 3.19 what happens if !__GFP_FS allocations
> > fails. out_of_memory() is called by pagefault_out_of_memory() when 0x2015a
> > (!__GFP_FS) allocation failed.
> 
> I have posted a patch to deal with this
> (http://marc.info/?l=linux-mm&m=142770374521952&w=2). There is no real
> reason to do the GFP_NOFS from the page fault context just because the
> mapping _always_ insists on it. Page fault simply _has_ to be GFP_FS
> safe, we are badly broken otherwise. That patch should go in hand with
> GFP_NOFS might fail one. I haven't posted it yet because I was waiting
> for the merge window to close.
> 
Converting page fault allocations from GFP_NOFS to GFP_KERNEL is a different
problem for me. My concern is that failing/stalling GFP_NOFS/GFP_NOIO
allocations are more dangerous than GFP_KERNEL allocations.

> > This looks to me that !__GFP_FS allocations
> > are effectively OOM killer context. It is not fair to kill the thread which
> > triggered a page fault, for that thread may not be using so much memory
> > (unfair from memory usage point of view) or that thread may be global init
> > (unfair because killing the entire system than survive by killing somebody).
> 
> Why would we kill the faulting process?
> 
We can see that processes are killed by SIGBUS if we allow memory allocations
by page faults to fail, can't we? I didn't catch what your question is.

> > Also, failing the GFP_NOFS/GFP_NOIO allocations which are not triggered by
> > a page fault generally causes more damage (e.g. taking filesystem error
> > action) than survive by killing somebody. Therefore, I think we should not
> > hesitate invoking the OOM killer for !__GFP_FS allocation.
> 
> No, we should fix those places and use proper gfp flags rather than
> pretend that the problem doesn't exist and deal with all the side
> effectes.

Do you think we can identify and fix such places and _backport_ them before
customers bother us with unexplained hang up?

As Andrew Morton picked up from 1 to 7 of this series, I reposted timeout based
OOM killing patch at http://marc.info/?l=linux-mm&m=143239200805478&w=2 .
Please check and point out what I'm misunderstanding.

> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
