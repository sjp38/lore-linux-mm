Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id F03FE6B0253
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 12:45:09 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id i184so232488035ywb.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 09:45:09 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0137.outbound.protection.outlook.com. [104.47.1.137])
        by mx.google.com with ESMTPS id u18si2753261qta.65.2016.08.23.09.45.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 23 Aug 2016 09:45:09 -0700 (PDT)
Date: Tue, 23 Aug 2016 19:44:59 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH RESEND 8/8] af_unix: charge buffers to kmemcg
Message-ID: <20160823164459.GD1863@esperanza>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
 <fcfe6cae27a59fbc5e40145664b3cf085a560c68.1464079538.git.vdavydov@virtuozzo.com>
 <1464094926.5939.48.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160524163606.GB11150@esperanza>
 <CAPKp9uY9kFTqPT+9rkAcWACWrnE-FbGbuU=6mw715X6eCC4PVg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAPKp9uY9kFTqPT+9rkAcWACWrnE-FbGbuU=6mw715X6eCC4PVg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sudeep K N <sudeepholla.maillist@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev <netdev@vger.kernel.org>, x86@kernel.org, open list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Sudeep Holla <sudeep.holla@arm.com>

Hello,

On Tue, Aug 23, 2016 at 02:48:11PM +0100, Sudeep K N wrote:
> On Tue, May 24, 2016 at 5:36 PM, Vladimir Davydov
> <vdavydov@virtuozzo.com> wrote:
> > On Tue, May 24, 2016 at 06:02:06AM -0700, Eric Dumazet wrote:
> >> On Tue, 2016-05-24 at 11:49 +0300, Vladimir Davydov wrote:
> >> > Unix sockets can consume a significant amount of system memory, hence
> >> > they should be accounted to kmemcg.
> >> >
> >> > Since unix socket buffers are always allocated from process context,
> >> > all we need to do to charge them to kmemcg is set __GFP_ACCOUNT in
> >> > sock->sk_allocation mask.
> >>
> >> I have two questions :
> >>
> >> 1) What happens when a buffer, allocated from socket <A> lands in a
> >> different socket <B>, maybe owned by another user/process.
> >>
> >> Who owns it now, in term of kmemcg accounting ?
> >
> > We never move memcg charges. E.g. if two processes from different
> > cgroups are sharing a memory region, each page will be charged to the
> > process which touched it first. Or if two processes are working with the
> > same directory tree, inodes and dentries will be charged to the first
> > user. The same is fair for unix socket buffers - they will be charged to
> > the sender.
> >
> >>
> >> 2) Has performance impact been evaluated ?
> >
> > I ran netperf STREAM_STREAM with default options in a kmemcg on
> > a 4 core x 2 HT box. The results are below:
> >
> >  # clients            bandwidth (10^6bits/sec)
> >                     base              patched
> >          1      67643 +-  725      64874 +-  353    - 4.0 %
> >          4     193585 +- 2516     186715 +- 1460    - 3.5 %
> >          8     194820 +-  377     187443 +- 1229    - 3.7 %
> >
> > So the accounting doesn't come for free - it takes ~4% of performance.
> > I believe we could optimize it by using per cpu batching not only on
> > charge, but also on uncharge in memcg core, but that's beyond the scope
> > of this patch set - I'll take a look at this later.
> >
> > Anyway, if performance impact is found to be unacceptable, it is always
> > possible to disable kmem accounting at boot time (cgroup.memory=nokmem)
> > or not use memory cgroups at runtime at all (thanks to jump labels
> > there'll be no overhead even if they are compiled in).
> >
> 
> I started seeing almost 10% degradation in the hackbench score with v4.8-rc1
> Bisecting it resulted in this patch, i.e. Commit 3aa9799e1364 ("af_unix: charge
> buffers to kmemcg") in the mainline.
> 
> As per the commit log, it seems like that's expected but I was not sure about
> the margin. I also see the hackbench score is more inconsistent after this
> patch, but I may be wrong as that's based on limited observation.
> 
> Is this something we can ignore as hackbench is more synthetic compared
> to the gain this patch provides in some real workloads ?

AFAIU hackbench essentially measures the rate of sending data over a
unix socket back and forth between processes running on different cpus,
so it isn't a surprise that the patch resulted in a degradation, as it
makes every skb page allocation/deallocation inc/dec an atomic counter
inside memcg. The more processes/cpus running in the same cgroup are
involved in this test, the more significant the overhead of this atomic
counter is going to be.

The degradation is not unavoidable - it can be fixed by making kmem
charge/uncharge code use per-cpu batches. The infrastructure for this
already exists in memcontrol.c. If it were not for the legacy
mem_cgroup->kmem counter (which is actually useless and will be dropped
in cgroup v2), the issue would be pretty easy to fix. However, this
legacy counter makes a possible implementation quite messy, so I'd like
to postpone it until cgroup v2 has finally settled down.

Regarding your problem. As a workaround you can either start your
workload in the root memory cgroup or disable kmem accounting for memory
cgroups altogether (via cgroup.memory=nokmem boot option). If you find
the issue critical, I don't mind reverting the patch - we can always
re-apply it once per-cpu batches are implemented for kmem charges.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
