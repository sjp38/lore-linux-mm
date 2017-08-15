Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 42C606B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 08:26:26 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x43so1072345wrb.9
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:26:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x128si1184663wmg.251.2017.08.15.05.26.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 05:26:24 -0700 (PDT)
Date: Tue, 15 Aug 2017 14:26:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 oom_reaper races with writer
Message-ID: <20170815122621.GE29067@dhcp22.suse.cz>
References: <201708142251.v7EMp3j9081456@www262.sakura.ne.jp>
 <20170815084143.GB29067@dhcp22.suse.cz>
 <201708151006.v7FA6SxD079619@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708151006.v7FA6SxD079619@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 15-08-17 19:06:28, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 15-08-17 07:51:02, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > [...]
> > > > Were you able to reproduce with other filesystems?
> > > 
> > > Yes, I can reproduce this problem using both xfs and ext4 on 4.11.11-200.fc25.x86_64
> > > on Oracle VM VirtualBox on Windows.
> > 
> > Just a quick question.
> > http://lkml.kernel.org/r/201708112053.FIG52141.tHJSOQFLOFMFOV@I-love.SAKURA.ne.jp
> > mentioned next-20170811 kernel and this one 4.11. Your original report
> > as a reply to this thread
> > http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp
> > mentioned next-20170728. None of them seem to have this fix
> > http://lkml.kernel.org/r/20170807113839.16695-3-mhocko@kernel.org so let
> > me ask again. Have you seen an unexpected content written with that
> > patch applied?
> 
> No. All non-zero non-0xFF values are without that patch applied.
> I want to confirm that that patch actually fixes non-zero non-0xFF values
> (so that we can have better patch description for that patch).

OK, so I have clearly misunderstood you. I thought that you can still
see corrupted content with the patch _applied_. Now I see why I couldn't
reproduce this...

Now I also understand what you meant when asking for an explanation. I
can only speculate how we could end up with the non-zero page previously
but the closest match would be that the page got unmapped and reused by
a different path and a stalled tlb entry would leak the content. Such a
thing would happen if we freed the page _before_ we flushed the tlb
during unmap.

Considering that oom_reaper is relying on unmap_page_range which seems
to be doing the right thing wrt. flushing vs. freeing ordering (enforced
by the tlb_gather) I am wondering what else could go wrong but I vaguely
remember there were some races between THP and MADV_DONTNEED in the
past. Maybe we have hit an incarnation of something like that. Anyway
the oom_reaper doesn't try to be clever and it only calls to
unmap_page_range which should be safe from that context.

The primary bug here was that we allowed to refault an unmmaped memory
and that should be fixed by the patch AFAICS. If there are more issues
we should definitely track those down but those should be oom_reaper
independent because we really do not do anything special here.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
