Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 151496B0260
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 09:13:54 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r144so45231098wme.0
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:13:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5si3188406wmg.133.2017.01.26.06.13.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 06:13:52 -0800 (PST)
Date: Thu, 26 Jan 2017 15:13:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170126141349.GN6590@dhcp22.suse.cz>
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
 <588907AA.1020704@iogearbox.net>
 <20170126074354.GB8456@dhcp22.suse.cz>
 <5889C331.7020101@iogearbox.net>
 <20170126100802.GF6590@dhcp22.suse.cz>
 <5889DEA3.7040106@iogearbox.net>
 <20170126115833.GI6590@dhcp22.suse.cz>
 <5889F52E.7030602@iogearbox.net>
 <20170126134004.GM6590@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126134004.GM6590@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On Thu 26-01-17 14:40:04, Michal Hocko wrote:
> On Thu 26-01-17 14:10:06, Daniel Borkmann wrote:
> > On 01/26/2017 12:58 PM, Michal Hocko wrote:
> > > On Thu 26-01-17 12:33:55, Daniel Borkmann wrote:
> > > > On 01/26/2017 11:08 AM, Michal Hocko wrote:
> > > [...]
> > > > > If you disagree I can drop the bpf part of course...
> > > > 
> > > > If we could consolidate these spots with kvmalloc() eventually, I'm
> > > > all for it. But even if __GFP_NORETRY is not covered down to all
> > > > possible paths, it kind of does have an effect already of saying
> > > > 'don't try too hard', so would it be harmful to still keep that for
> > > > now? If it's not, I'd personally prefer to just leave it as is until
> > > > there's some form of support by kvmalloc() and friends.
> > > 
> > > Well, you can use kvmalloc(size, GFP_KERNEL|__GFP_NORETRY). It is not
> > > disallowed. It is not _supported_ which means that if it doesn't work as
> > > you expect you are on your own. Which is actually the situation right
> > > now as well. But I still think that this is just not right thing to do.
> > > Even though it might happen to work in some cases it gives a false
> > > impression of a solution. So I would rather go with
> > 
> > Hmm. 'On my own' means, we could potentially BUG somewhere down the
> > vmalloc implementation, etc, presumably? So it might in-fact be
> > harmful to pass that, right?
> 
> No it would mean that it might eventually hit the behavior which you are
> trying to avoid - in other words it may invoke OOM killer even though
> __GFP_NORETRY means giving up before any system wide disruptive actions
> a re taken.

I will separate both bpf and netfilter hunks into its own patch with the
clarification. Does the following look better?
---
