Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 001966B0253
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 05:05:47 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so45686491wjb.5
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 02:05:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s131si2228311wmf.117.2017.01.27.02.05.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Jan 2017 02:05:46 -0800 (PST)
Date: Fri, 27 Jan 2017 11:05:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170127100544.GF4143@dhcp22.suse.cz>
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
 <588907AA.1020704@iogearbox.net>
 <20170126074354.GB8456@dhcp22.suse.cz>
 <5889C331.7020101@iogearbox.net>
 <20170126100802.GF6590@dhcp22.suse.cz>
 <5889DEA3.7040106@iogearbox.net>
 <20170126115833.GI6590@dhcp22.suse.cz>
 <5889F52E.7030602@iogearbox.net>
 <20170126134004.GM6590@dhcp22.suse.cz>
 <588A5D3C.4060605@iogearbox.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <588A5D3C.4060605@iogearbox.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On Thu 26-01-17 21:34:04, Daniel Borkmann wrote:
> On 01/26/2017 02:40 PM, Michal Hocko wrote:
[...]
> > But realistically, how big is this problem really? Is it really worth
> > it? You said this is an admin only interface and admin can kill the
> > machine by OOM and other means already.
> > 
> > Moreover and I should probably mention it explicitly, your d407bd25a204b
> > reduced the likelyhood of oom for other reason. kmalloc used GPF_USER
> > previously and with order > 0 && order <= PAGE_ALLOC_COSTLY_ORDER this
> > could indeed hit the OOM e.g. due to memory fragmentation. It would be
> > much harder to hit the OOM killer from vmalloc which doesn't issue
> > higher order allocation requests. Or have you ever seen the OOM killer
> > pointing to the vmalloc fallback path?
> 
> The case I was concerned about was from vmalloc() path, not kmalloc().
> That was where the stack trace indicating OOM pointed to. As an example,
> there could be really large allocation requests for maps where the map
> has pre-allocated memory for its elements. Thus, if we get to the point
> where we need to kill others due to shortage of mem for satisfying this,
> I'd much much rather prefer to just not let vmalloc() work really hard
> and fail early on instead. 

I see, but as already mentioned, chances are that by the time you get
close to the OOM somebody else will hit the OOM before the vmalloc path
manages to free the allocated memory.

> In my (crafted) test case, I was connected
> via ssh and it each time reliably killed my connection, which is really
> suboptimal.
> 
> F.e., I could also imagine a buggy or miscalculated map definition for
> a prog that is provisioned to multiple places, which then accidentally
> triggers this. Or if large on purpose, but we crossed the line, it
> could be handled more gracefully, f.e. I could imagine an option to
> falling back to a non-pre-allocated map flavor from the application
> loading the program. Trade-off for sure, but still allowing it to
> operate up to a certain extend. Granted, if vmalloc() succeeded without
> trying hard and we then OOM elsewhere, too bad, but we don't have much
> control over that one anyway, only about our own request. Reason I
> asked above was whether having __GFP_NORETRY in would be fatal
> somewhere down the path, but seems not as you say.
> 
> So to answer your second email with the bpf and netfilter hunks, why
> not replacing them with kvmalloc() and __GFP_NORETRY flag and add that
> big fat FIXME comment above there, saying explicitly that __GFP_NORETRY
> is not harmful though has only /partial/ effect right now and that full
> support needs to be implemented in future. That would still be better
> that not having it, imo, and the FIXME would make expectations clear
> to anyone reading that code.

Well, we can do that, I just would like to prevent from this (ab)use
if there is no _real_ and _sensible_ usecase for it. Having a real bug
report or a fallback mechanism you are mentioning above would justify
the (ab)use IMHO. But that abuse would be documented properly and have a
real reason to exist. That sounds like a better approach to me.

But if you absolutely _insist_ I can change that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
