Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7375C6B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 10:25:39 -0400 (EDT)
Received: by wgen6 with SMTP id n6so64276785wge.3
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 07:25:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id by11si264013wib.105.2015.04.30.07.25.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 07:25:37 -0700 (PDT)
Date: Thu, 30 Apr 2015 16:25:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
Message-ID: <20150430142534.GA16964@dhcp22.suse.cz>
References: <201504290050.FDE18274.SOJVtFLOMOQFFH@I-love.SAKURA.ne.jp>
 <20150429125506.GB7148@cmpxchg.org>
 <20150429144031.GB31341@dhcp22.suse.cz>
 <201504300227.JCJ81217.FHOLSQVOFFJtMO@I-love.SAKURA.ne.jp>
 <20150429183135.GH31341@dhcp22.suse.cz>
 <201504301844.CFE13027.FOMtJHQOFSOFVL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201504301844.CFE13027.FOMtJHQOFSOFVL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, hannes@cmpxchg.org, akpm@linux-foundation.org, aarcange@redhat.com, rientjes@google.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 30-04-15 18:44:25, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > I mean we should eventually fail all the allocation types but GFP_NOFS
> > is coming from _carefully_ handled code paths which is an easier starting
> > point than a random code path in the kernel/drivers. So can we finally
> > move at least in this direction?
> 
> I agree that all the allocation types can fail unless GFP_NOFAIL is given.
> But I also expect that all the allocation types should not fail unless
> order > PAGE_ALLOC_COSTLY_ORDER or GFP_NORETRY is given or chosen as an OOM
> victim.

Yeah, let's keep shooting our feet and then look for workarounds to deal
with it...
 
> We already experienced at Linux 3.19 what happens if !__GFP_FS allocations
> fails. out_of_memory() is called by pagefault_out_of_memory() when 0x2015a
> (!__GFP_FS) allocation failed.

I have posted a patch to deal with this
(http://marc.info/?l=linux-mm&m=142770374521952&w=2). There is no real
reason to do the GFP_NOFS from the page fault context just because the
mapping _always_ insists on it. Page fault simply _has_ to be GFP_FS
safe, we are badly broken otherwise. That patch should go in hand with
GFP_NOFS might fail one. I haven't posted it yet because I was waiting
for the merge window to close.

> This looks to me that !__GFP_FS allocations
> are effectively OOM killer context. It is not fair to kill the thread which
> triggered a page fault, for that thread may not be using so much memory
> (unfair from memory usage point of view) or that thread may be global init
> (unfair because killing the entire system than survive by killing somebody).

Why would we kill the faulting process?

> Also, failing the GFP_NOFS/GFP_NOIO allocations which are not triggered by
> a page fault generally causes more damage (e.g. taking filesystem error
> action) than survive by killing somebody. Therefore, I think we should not
> hesitate invoking the OOM killer for !__GFP_FS allocation.

No, we should fix those places and use proper gfp flags rather than
pretend that the problem doesn't exist and deal with all the side
effectes.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
