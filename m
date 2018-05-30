Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA2656B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 08:38:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x18-v6so14775093wrl.21
        for <linux-mm@kvack.org>; Wed, 30 May 2018 05:38:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v7-v6si633225edi.290.2018.05.30.05.38.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 May 2018 05:38:28 -0700 (PDT)
Date: Wed, 30 May 2018 14:38:26 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
Message-ID: <20180530123826.GF27180@dhcp22.suse.cz>
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com>
 <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp>
 <20180528132410.GD27180@dhcp22.suse.cz>
 <201805290605.DGF87549.LOVFMFJQSOHtFO@I-love.SAKURA.ne.jp>
 <1126233373.5118805.1527600426174.JavaMail.zimbra@redhat.com>
 <f3d58cbd-29ca-7a23-69e0-59690b9cd4fb@i-love.sakura.ne.jp>
 <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com>
 <20180530104637.GC27180@dhcp22.suse.cz>
 <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chunyu Hu <chuhu@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, catalin marinas <catalin.marinas@arm.com>, Akinobu Mita <akinobu.mita@gmail.com>

On Wed 30-05-18 07:42:59, Chunyu Hu wrote:
> 
> ----- Original Message -----
> > From: "Michal Hocko" <mhocko@suse.com>
> > To: "Chunyu Hu" <chuhu@redhat.com>
> > Cc: "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org,
> > "catalin marinas" <catalin.marinas@arm.com>
> > Sent: Wednesday, May 30, 2018 6:46:37 PM
> > Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
> > 
> > On Wed 30-05-18 05:35:37, Chunyu Hu wrote:
> > [...]
> > > I'm trying to reuse the make_it_fail field in task for fault injection. As
> > > adding
> > > an extra memory alloc flag is not thought so good,  I think adding task
> > > flag
> > > is either?
> > 
> > Yeah, task flag will be reduced to KMEMLEAK enabled configurations
> > without an additional maint. overhead. Anyway, you should really think
> > about how to guarantee trackability for atomic allocation requests. You
> > cannot simply assume that GFP_NOWAIT will succeed. I guess you really
> 
> Sure. While I'm using task->make_it_fail, I'm still in the direction of 
> making kmemleak avoid fault inject with task flag instead of page alloc flag.
> 
> > want to have a pre-populated pool of objects for those requests. The
> > obvious question is how to balance such a pool. It ain't easy to track
> > memory by allocating more memory...
> 
> This solution is going to make kmemleak trace really nofail. We can think
> later.
> 
> while I'm thinking about if fault inject can be disabled via flag in task.
> 
> Actually, I'm doing something like below, the disable_fault_inject() is
> just setting a flag in task->make_it_fail. But this will depend on if
> fault injection accept a change like this. CCing Akinobu 

You still seem to be missing my point I am afraid (or I am ;). So say
that you want to track a GFP_NOWAIT allocation request. So create_object
will get called with that gfp mask and no matter what you try here your
tracking object will be allocated in a weak allocation context as well
and disable kmemleak. So it only takes a more heavy memory pressure and
the tracing is gone...
-- 
Michal Hocko
SUSE Labs
