Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCB446B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 07:35:13 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 89-v6so13128501plb.18
        for <linux-mm@kvack.org>; Thu, 31 May 2018 04:35:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w73-v6si37953253pfd.19.2018.05.31.04.35.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 May 2018 04:35:11 -0700 (PDT)
Date: Thu, 31 May 2018 13:35:08 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
Message-ID: <20180531113508.GO15278@dhcp22.suse.cz>
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com>
 <201805290605.DGF87549.LOVFMFJQSOHtFO@I-love.SAKURA.ne.jp>
 <1126233373.5118805.1527600426174.JavaMail.zimbra@redhat.com>
 <f3d58cbd-29ca-7a23-69e0-59690b9cd4fb@i-love.sakura.ne.jp>
 <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com>
 <20180530104637.GC27180@dhcp22.suse.cz>
 <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com>
 <20180530123826.GF27180@dhcp22.suse.cz>
 <2074740225.5769475.1527763882580.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2074740225.5769475.1527763882580.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chunyu Hu <chuhu@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, catalin marinas <catalin.marinas@arm.com>, Akinobu Mita <akinobu.mita@gmail.com>

On Thu 31-05-18 06:51:22, Chunyu Hu wrote:
> 
> 
> ----- Original Message -----
> > From: "Michal Hocko" <mhocko@suse.com>
> > To: "Chunyu Hu" <chuhu@redhat.com>
> > Cc: "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org,
> > "catalin marinas" <catalin.marinas@arm.com>, "Akinobu Mita" <akinobu.mita@gmail.com>
> > Sent: Wednesday, May 30, 2018 8:38:26 PM
> > Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
> > 
> > On Wed 30-05-18 07:42:59, Chunyu Hu wrote:
> > > 
> > > ----- Original Message -----
> > > > From: "Michal Hocko" <mhocko@suse.com>
> > > > To: "Chunyu Hu" <chuhu@redhat.com>
> > > > Cc: "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>,
> > > > malat@debian.org, dvyukov@google.com, linux-mm@kvack.org,
> > > > "catalin marinas" <catalin.marinas@arm.com>
> > > > Sent: Wednesday, May 30, 2018 6:46:37 PM
> > > > Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
> > > > 
> > > > On Wed 30-05-18 05:35:37, Chunyu Hu wrote:
> > > > [...]
> > > > > I'm trying to reuse the make_it_fail field in task for fault injection.
> > > > > As
> > > > > adding
> > > > > an extra memory alloc flag is not thought so good,  I think adding task
> > > > > flag
> > > > > is either?
> > > > 
> > > > Yeah, task flag will be reduced to KMEMLEAK enabled configurations
> > > > without an additional maint. overhead. Anyway, you should really think
> > > > about how to guarantee trackability for atomic allocation requests. You
> > > > cannot simply assume that GFP_NOWAIT will succeed. I guess you really
> > > 
> > > Sure. While I'm using task->make_it_fail, I'm still in the direction of
> > > making kmemleak avoid fault inject with task flag instead of page alloc
> > > flag.
> > > 
> > > > want to have a pre-populated pool of objects for those requests. The
> > > > obvious question is how to balance such a pool. It ain't easy to track
> > > > memory by allocating more memory...
> > > 
> > > This solution is going to make kmemleak trace really nofail. We can think
> > > later.
> > > 
> > > while I'm thinking about if fault inject can be disabled via flag in task.
> > > 
> > > Actually, I'm doing something like below, the disable_fault_inject() is
> > > just setting a flag in task->make_it_fail. But this will depend on if
> > > fault injection accept a change like this. CCing Akinobu
> > 
> > You still seem to be missing my point I am afraid (or I am ;). So say
> > that you want to track a GFP_NOWAIT allocation request. So create_object
> > will get called with that gfp mask and no matter what you try here your
> > tracking object will be allocated in a weak allocation context as well
> > and disable kmemleak. So it only takes a more heavy memory pressure and
> > the tracing is gone...
> 
> Michal,
> 
> Thank you for the good suggestion. You mean GFP_NOWAIT still can make create_object
> fail and as a result kmemleak disable itself. So it's not so useful, just like
> the current __GFP_NOFAIL usage in create_object. 
> 
> In the first thread, we discussed this. and that time you suggested we have 
> fault injection disabled when kmemleak is working and suggested per task way.
> so my head has been stuck in that point. While now you gave a better suggestion
> that why not we pre allocate a urgent pool for kmemleak objects. After thinking
> for a while, I got  your point, it's a good way for improving kmemleak to make
> it can tolerate light allocation failure. And catalin mentioned that we have
> one option that use the early_log array as urgent pool, which has the similar
> ideology.
> 
> Basing on your suggestions, I tried to draft this, what does it look to you? 
> another strong alloc mask and an extra thread for fill the pool, which containts
> 1M objects in a frequency of 100 ms. If first kmem_cache_alloc failed, then
> get a object from the pool. 

I am not really familiar with kmemleak code base to judge the
implementation. Could you be more specific about the highlevel design
please? Who is the producer and how does it sync with consumers?
-- 
Michal Hocko
SUSE Labs
