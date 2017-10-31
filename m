Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 496416B0038
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 09:23:01 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z96so9843424wrb.21
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 06:23:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1si1667867wrc.147.2017.10.31.06.23.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 06:23:00 -0700 (PDT)
Date: Tue, 31 Oct 2017 14:22:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Try last second allocation before and after
 selecting an OOM victim.
Message-ID: <20171031132259.irkladqbucz2qa3g@dhcp22.suse.cz>
References: <20171030141815.lk76bfetmspf7f4x@dhcp22.suse.cz>
 <201710311940.FDJ52199.OHMtSFVFOJLOQF@I-love.SAKURA.ne.jp>
 <20171031121032.lm3wxx3l5tkpo2ni@dhcp22.suse.cz>
 <201710312142.DBB81723.FOOFJMQLStFVOH@I-love.SAKURA.ne.jp>
 <20171031124855.rszis5gefbxwriiz@dhcp22.suse.cz>
 <201710312213.BDB35457.MtFJOQVLOFSOHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710312213.BDB35457.MtFJOQVLOFSOHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

On Tue 31-10-17 22:13:05, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 31-10-17 21:42:23, Tetsuo Handa wrote:
> > > > While both have some merit, the first reason is mostly historical
> > > > because we have the explicit locking now and it is really unlikely that
> > > > the memory would be available right after we have given up trying.
> > > > Last attempt allocation makes some sense of course but considering that
> > > > the oom victim selection is quite an expensive operation which can take
> > > > a considerable amount of time it makes much more sense to retry the
> > > > allocation after the most expensive part rather than before. Therefore
> > > > move the last attempt right before we are trying to kill an oom victim
> > > > to rule potential races when somebody could have freed a lot of memory
> > > > in the meantime. This will reduce the time window for potentially
> > > > pre-mature OOM killing considerably.
> > > 
> > > But this is about "doing last second allocation attempt after selecting
> > > an OOM victim". This is not about "allowing OOM victims to try ALLOC_OOM
> > > before selecting next OOM victim" which is the actual problem I'm trying
> > > to deal with.
> > 
> > then split it into two. First make the general case and then add a more
> > sophisticated on top. Dealing with multiple issues at once is what makes
> > all those brain cells suffer.
> 
> I'm failing to understand. I was dealing with single issue at once.
> The single issue is "MMF_OOM_SKIP prematurely prevents OOM victims from trying
> ALLOC_OOM before selecting next OOM victims". Then, what are the general case and
> a more sophisticated? I wonder what other than "MMF_OOM_SKIP should allow OOM
> victims to try ALLOC_OOM for once before selecting next OOM victims" can exist...

Try to think little bit out of your very specific and borderline usecase
and it will become obvious. ALLOC_OOM is a trivial update on top of
moving get_page_from_freelist to oom_kill_process which is a more
generic race window reducer.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
