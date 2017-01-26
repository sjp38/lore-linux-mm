Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1C86B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 05:08:06 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c206so44039647wme.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 02:08:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u66si1349947wrc.269.2017.01.26.02.08.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 02:08:04 -0800 (PST)
Date: Thu, 26 Jan 2017 11:08:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170126100802.GF6590@dhcp22.suse.cz>
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
 <588907AA.1020704@iogearbox.net>
 <20170126074354.GB8456@dhcp22.suse.cz>
 <5889C331.7020101@iogearbox.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5889C331.7020101@iogearbox.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On Thu 26-01-17 10:36:49, Daniel Borkmann wrote:
> On 01/26/2017 08:43 AM, Michal Hocko wrote:
> > On Wed 25-01-17 21:16:42, Daniel Borkmann wrote:
[...]
> > > I assume that kvzalloc() is still the same from [1], right? If so, then
> > > it would unfortunately (partially) reintroduce the issue that was fixed.
> > > If you look above at flags, they're also passed to __vmalloc() to not
> > > trigger OOM in these situations I've experienced.
> > 
> > Pushing __GFP_NORETRY to __vmalloc doesn't have the effect you might
> > think it would. It can still trigger the OOM killer becauset the flags
> > are no propagated all the way down to all allocations requests (e.g.
> > page tables). This is the same reason why GFP_NOFS is not supported in
> > vmalloc.
> 
> Ok, good to know, is that somewhere clearly documented (like for the
> case with kmalloc())?

I am afraid that we really suck on this front. I will add something.

> If not, could we do that for non-mm folks, or
> at least add a similar WARN_ON_ONCE() as you did for kvmalloc() to make
> it obvious to users that a given flag combination is not supported all
> the way down?

I am not sure that triggering a warning that somebody has used
__GFP_NOWARN is very helpful ;). I also do not think that covering all the
supported flags is really feasible. Most of them will not have bad side
effects. I have added the warning because this API is new and I wanted
to catch new abusers. Old ones would have to die slowly.

> > > This is effectively the
> > > same requirement as in other networking areas f.e. that 5bad87348c70
> > > ("netfilter: x_tables: avoid warn and OOM killer on vmalloc call") has.
> > > In your comment in kvzalloc() you eventually say that some of the above
> > > modifiers are not supported. So there would be two options, i) just leave
> > > out the kvzalloc() chunk for BPF area to avoid the merge conflict and tackle
> > > it later (along with similar code from 5bad87348c70), or ii) implement
> > > support for these modifiers as well to your original set. I guess it's not
> > > too urgent, so we could also proceed with i) if that is easier for you to
> > > proceed (I don't mind either way).
> > 
> > Could you clarify why the oom killer in vmalloc matters actually?
> 
> For both mentioned commits, (privileged) user space can potentially
> create large allocation requests, where we thus switch to vmalloc()
> flavor eventually and then OOM starts killing processes to try to
> satisfy the allocation request. This is bad, because we want the
> request to just fail instead as it's non-critical and f.e. not kill
> ssh connection et al. Failing is totally fine in this case, whereas
> triggering OOM is not.

I see your intention but does it really make any real difference?
Consider you would back off right before you would have OOMed. Any
parallel request would just hit the OOM for you. You are (almost) never
doing an allocation in an isolation.

> In my testing, __GFP_NORETRY did satisfy this
> just fine, but as you say it seems it's not enough.

Yeah, ptes have been most probably popullated already.

> Given there are
> multiple places like these in the kernel, could we instead add an
> option such as __GFP_NOOOM, or just make __GFP_NORETRY supported?

As said above I do not really think that suppressing the OOM killer
makes any difference because it might be just somebody else doing that
for you. Also the OOM killer is the MM internal implementation "detail"
users shouldn't really care. I agree that callers should have a way to
say they do not want to try really hard and that is not that simple
for vmalloc unfortunatelly. The main problem here is that gfp mask
propagation is not that easy to fix without a lot of code churn as some
of those hardcoded allocation requests are deep in call chains.

I know this sucks and it would be great to support __GFP_NORETRY to
[k]vmalloc and maybe we will get there eventually. But for the mean time
I really think that using kvmalloc wherever possible is much better than
open coded variants whith expectations which do not hold sometimes.

If you disagree I can drop the bpf part of course...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
