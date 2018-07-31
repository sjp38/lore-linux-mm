Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 853AC6B000A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 03:28:36 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f8-v6so3184913eds.6
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 00:28:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o13-v6si4213356edh.418.2018.07.31.00.28.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 00:28:35 -0700 (PDT)
Date: Tue, 31 Jul 2018 09:28:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: post linux 4.4 vm oom kill, lockup and thrashing woes
Message-ID: <20180731072833.GD4557@dhcp22.suse.cz>
References: <20180710120755.3gmin4rogheqb3u5@schmorp.de>
 <20180710123222.GK14284@dhcp22.suse.cz>
 <20180717234549.4ng2expfkgaranuq@schmorp.de>
 <20180718083808.GR7193@dhcp22.suse.cz>
 <20180722233437.34e5ckq5pp24gsod@schmorp.de>
 <20180723125554.GE31229@dhcp22.suse.cz>
 <20180731034546.tro4gurwebmcpuqd@schmorp.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180731034546.tro4gurwebmcpuqd@schmorp.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Lehmann <schmorp@schmorp.de>
Cc: linux-mm@kvack.org

On Tue 31-07-18 05:45:46, Marc Lehmann wrote:
> On Mon, Jul 23, 2018 at 02:55:54PM +0200, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > Having more examples should help us to work with specific subsystems
> > on a more appropriate fix. Depending on large order allocations has
> > always been suboptimal if not outright wrong.
> 
> I think this is going into the wrong direction. First of all, keep in mind
> that I have to actively work against getting more examples, as I have to keep
> things running and will employ more and more workarounds.
> 
> More importantly, however, it's all good and well if the kernel fails
> high order allocations when it has to, and it's all well to try to "fix"
> them to not happen, but let's not forget the real problem, which is linux
> thrashing, freezing or killing unrelated processes when it has no reason
> to. specifically, if I have 32Gb ram and 30GB of page cache that isn't
> locked, then linux has no conceivable reason to not satisfy even a high-order
> allocation by moving some movable pages around.

This is what we are trying as hard as we can though.

> I tzhink the examples I provides should already give some insight, for
> example, doing a large mmap and faulting the pages in should not cause
> these pages to be so stubbornly locked as to cause the machine to freeze
> on a large alllocation, when it could "simply" drp a few gigabytes of
> (non-dirty!) shared file pages instead.

Yes we try to reclaim clean page cache quite agressively and a failing
compaction is a reason to reclaim even more. But the life is not as
simple. There might be different reasons why even a clean page cache is
not migratable. E.g. when those pages are pinned by the filesystems.

> It's possible that the post-4.4 vm changes are not the direct cause of this,
> but only caused a hitherto unproblematic behaviour to cause problems e.g.
> (totally made up) mmapped file data was freed in 4.4 simply because it tried
> harder, and in post-4.4 kernels the kernel prefers to lock up instead. Then
> the changes done in post-4.4 are not the cause of the problem, but simply the
> trigger, just as the higher order allocations of some subsystems are not the
> cause of the spurious oom kills, but simply the trigger.

Well, this is really hard to tell from the data I have seen. All I can
tell right now is that the system is fragmented heavily and there seems
to be a hard demand for high order requests which we simply do not fail
and rather go and oom kill. Is this good? Absolutely not but this is
something that is really hard to change. We have historical reasons why
non-costly (order smaller than 4) allocations basically never fail. This
is really hard to change. The general recommendation is to simply not do
that because it hurts. Sucks I know...

> Or, to put it bluntly, no matter how badly written kvm and/or the nvidia
> subsystem,s are, the kernel has no business killing mysql on my boxes when
> it has 95% of available memory. If this were by design, then linux should
> have the ability of keeping memory free for suich uses (something like
> min_free_kbytes) and not use memory for disk cache if this memory is then
> lost to other applications.

Yes we have min_free_kbytes but fragmentation sucks. You can try to
increase this value and it usually helps. But not unconditionally.

> And yes, if I see more "interesting" examples, I will of course tell you
> about them :)

It would be good to track why the compaction doesn't help. We have some
counters in /proc/vmstat so collecting this over time might get us some
clue. There are also some tracepoints which might tell us more.

In general though it is much preferable to reduce agreesive high order
memory requests.
-- 
Michal Hocko
SUSE Labs
