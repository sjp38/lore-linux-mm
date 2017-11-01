Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE786280254
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:37:22 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id t101so8741785ioe.0
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:37:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i141si1313226ita.33.2017.11.01.08.37.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 08:37:21 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Try last second allocation before and after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171031141034.bg25xbo5cyfafnyp@dhcp22.suse.cz>
	<201711012058.CIF81791.OQOFHFLOFMSJtV@I-love.SAKURA.ne.jp>
	<20171101124601.aqk3ayjp643ifdw3@dhcp22.suse.cz>
	<201711012338.AGB30781.JHOMFQFVSFtOLO@I-love.SAKURA.ne.jp>
	<20171101144845.tey4ozou44tfpp3g@dhcp22.suse.cz>
In-Reply-To: <20171101144845.tey4ozou44tfpp3g@dhcp22.suse.cz>
Message-Id: <201711020037.CAI17621.FtLFOFMOJOHSVQ@I-love.SAKURA.ne.jp>
Date: Thu, 2 Nov 2017 00:37:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> > Does "that comment" refer to
> > 
> >   Elaborating the comment: the reason for the high wmark is to reduce
> >   the likelihood of livelocks and be sure to invoke the OOM killer, if
> >   we're still under pressure and reclaim just failed. The high wmark is
> >   used to be sure the failure of reclaim isn't going to be ignored. If
> >   using the min wmark like you propose there's risk of livelock or
> >   anyway of delayed OOM killer invocation.
> > 
> > part? Then, I know it is not about gfp flags.
> > 
> > But how can OOM livelock happen when the last second allocation does not
> > wait for memory reclaim (because __GFP_DIRECT_RECLAIM is masked) ?
> > The last second allocation shall return immediately, and we will call
> > out_of_memory() if the last second allocation failed.
> 
> I think Andrea just wanted to say that we do want to invoke OOM killer
> and resolve the memory pressure rather than keep looping in the
> reclaim/oom path just because there are few pages allocated and freed in
> the meantime.

I see. Then, that motivation no longer applies to current code, except

> 
> [...]
> > > I am not sure such a scenario matters all that much because it assumes
> > > that the oom victim doesn't really free much memory [1] (basically less than
> > > HIGH-MIN). Most OOM situation simply have a memory hog consuming
> > > significant amount of memory.
> > 
> > The OOM killer does not always kill a memory hog consuming significant amount
> > of memory. The OOM killer kills a process with highest OOM score (and instead
> > one of its children if any). I don't think that assuming an OOM victim will free
> > memory enough to succeed ALLOC_WMARK_HIGH is appropriate.
> 
> OK, so let's agree to disagree. I claim that we shouldn't care all that
> much. If any of the current heuristics turns out to lead to killing too
> many tasks then we should simply remove it rather than keep bloating an
> already complex code with more and more kluges.

using ALLOC_WMARK_HIGH might cause more OOM-killing than ALLOC_WMARK_MIN.

Thanks for clarification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
