Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C96A66B0006
	for <linux-mm@kvack.org>; Thu, 31 May 2018 14:41:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l6-v6so17298791wrn.17
        for <linux-mm@kvack.org>; Thu, 31 May 2018 11:41:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a63-v6si1018418ede.197.2018.05.31.11.41.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 May 2018 11:41:07 -0700 (PDT)
Date: Thu, 31 May 2018 20:41:04 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
Message-ID: <20180531184104.GT15278@dhcp22.suse.cz>
References: <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp>
 <20180528132410.GD27180@dhcp22.suse.cz>
 <201805290605.DGF87549.LOVFMFJQSOHtFO@I-love.SAKURA.ne.jp>
 <1126233373.5118805.1527600426174.JavaMail.zimbra@redhat.com>
 <f3d58cbd-29ca-7a23-69e0-59690b9cd4fb@i-love.sakura.ne.jp>
 <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com>
 <20180530104637.GC27180@dhcp22.suse.cz>
 <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com>
 <20180530123826.GF27180@dhcp22.suse.cz>
 <20180531152225.2ck6ach4lma4zeim@armageddon.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180531152225.2ck6ach4lma4zeim@armageddon.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Chunyu Hu <chuhu@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, Akinobu Mita <akinobu.mita@gmail.com>

On Thu 31-05-18 16:22:26, Catalin Marinas wrote:
> Hi Michal,
> 
> I'm catching up with this thread.
> 
> On Wed, May 30, 2018 at 02:38:26PM +0200, Michal Hocko wrote:
> > On Wed 30-05-18 07:42:59, Chunyu Hu wrote:
> > > From: "Michal Hocko" <mhocko@suse.com>
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
> create_object() indeed gets the originating gfp but it only cares
> whether it was GFP_KERNEL or GFP_ATOMIC. gfp_kmemleak_mask() masks out
> all the other flags when allocating a struct kmemleak_object (and adds
> some of its own).
> 
> This has worked ok so far. There is a higher risk of GFP_ATOMIC
> allocations failing but I haven't seen issues with kmemleak unless you
> run it under heavy memory pressure (and kmemleak just disables itself).
> With fault injection, such pressure is simulated with the side effect of
> rendering kmemleak unusable.
> 
> Kmemleak could implement its own allocation mechanism (maybe even
> skipping the slab altogether) but I feel it's overkill just to cope with
> the specific case of fault injection. Also, it's not easy to figure out
> how to balance such pool and it may end up calling alloc_pages() which
> in turn can inject a fault.
> 
> Could we tweak gfp_kmemleak_mask() to still pass __GFP_NOFAIL but in a
> compatible way (e.g. by setting __GFP_DIRECT_RECLAIM) when fault
> injection is enabled?
> 
> Otherwise, I'd prefer some per-thread temporary fault injection
> disabling.

Well, there are two issues (which boil down to the one in the end) here.
Fault injection or a GFP_NOWAIT or any other weaker than GFP_KERNEL
context is something to care about. A weaker allocation context can and
will lead to kmemleak meta data allocation failures regardless of the
fault injection. The way how those objects are allocated directly in the
allacator context makes this really hard and inherently subtle. I can
see only two ways around. Either you have a placeholder for "this object
is not tracked so do not throw false positives" or have a preallocated
pool to use if the direct context allocation failes for whatever reason.
Abusing __GFP_NOFAIL is simply a crude hack which will lead to all kind
of problems.
-- 
Michal Hocko
SUSE Labs
