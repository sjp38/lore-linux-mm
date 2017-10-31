Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C26566B0253
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 09:52:13 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 134so43127553ioo.22
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 06:52:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 198si1482679iou.189.2017.10.31.06.52.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 06:52:12 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Try last second allocation before and after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171031121032.lm3wxx3l5tkpo2ni@dhcp22.suse.cz>
	<201710312142.DBB81723.FOOFJMQLStFVOH@I-love.SAKURA.ne.jp>
	<20171031124855.rszis5gefbxwriiz@dhcp22.suse.cz>
	<201710312213.BDB35457.MtFJOQVLOFSOHF@I-love.SAKURA.ne.jp>
	<20171031132259.irkladqbucz2qa3g@dhcp22.suse.cz>
In-Reply-To: <20171031132259.irkladqbucz2qa3g@dhcp22.suse.cz>
Message-Id: <201710312251.HBH43789.QVOFOtLFFSOHJM@I-love.SAKURA.ne.jp>
Date: Tue, 31 Oct 2017 22:51:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> On Tue 31-10-17 22:13:05, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 31-10-17 21:42:23, Tetsuo Handa wrote:
> > > > > While both have some merit, the first reason is mostly historical
> > > > > because we have the explicit locking now and it is really unlikely that
> > > > > the memory would be available right after we have given up trying.
> > > > > Last attempt allocation makes some sense of course but considering that
> > > > > the oom victim selection is quite an expensive operation which can take
> > > > > a considerable amount of time it makes much more sense to retry the
> > > > > allocation after the most expensive part rather than before. Therefore
> > > > > move the last attempt right before we are trying to kill an oom victim
> > > > > to rule potential races when somebody could have freed a lot of memory
> > > > > in the meantime. This will reduce the time window for potentially
> > > > > pre-mature OOM killing considerably.
> > > > 
> > > > But this is about "doing last second allocation attempt after selecting
> > > > an OOM victim". This is not about "allowing OOM victims to try ALLOC_OOM
> > > > before selecting next OOM victim" which is the actual problem I'm trying
> > > > to deal with.
> > > 
> > > then split it into two. First make the general case and then add a more
> > > sophisticated on top. Dealing with multiple issues at once is what makes
> > > all those brain cells suffer.
> > 
> > I'm failing to understand. I was dealing with single issue at once.
> > The single issue is "MMF_OOM_SKIP prematurely prevents OOM victims from trying
> > ALLOC_OOM before selecting next OOM victims". Then, what are the general case and
> > a more sophisticated? I wonder what other than "MMF_OOM_SKIP should allow OOM
> > victims to try ALLOC_OOM for once before selecting next OOM victims" can exist...
> 
> Try to think little bit out of your very specific and borderline usecase
> and it will become obvious. ALLOC_OOM is a trivial update on top of
> moving get_page_from_freelist to oom_kill_process which is a more
> generic race window reducer.

So, you meant "doing last second allocation attempt after selecting an OOM victim"
as the general case and "using ALLOC_OOM at last second allocation attempt" as a
more sophisticated. Then, you won't object conditionally switching ALLOC_WMARK_HIGH
and ALLOC_OOM for last second allocation attempt, will you?

But doing ALLOC_OOM for last second allocation attempt from out_of_memory() involve
duplicating code (e.g. rebuilding zone list). What is your preferred approach?
Duplicate relevant code? Use get_page_from_freelist() without rebuilding the zone list?
Use __alloc_pages_nodemask() ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
