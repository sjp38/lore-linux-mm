Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB71D6B026C
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 08:40:07 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id yr2so39779493wjc.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 05:40:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 57si2077466wrv.17.2017.01.26.05.40.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 05:40:06 -0800 (PST)
Date: Thu, 26 Jan 2017 14:40:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170126134004.GM6590@dhcp22.suse.cz>
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
 <588907AA.1020704@iogearbox.net>
 <20170126074354.GB8456@dhcp22.suse.cz>
 <5889C331.7020101@iogearbox.net>
 <20170126100802.GF6590@dhcp22.suse.cz>
 <5889DEA3.7040106@iogearbox.net>
 <20170126115833.GI6590@dhcp22.suse.cz>
 <5889F52E.7030602@iogearbox.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5889F52E.7030602@iogearbox.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On Thu 26-01-17 14:10:06, Daniel Borkmann wrote:
> On 01/26/2017 12:58 PM, Michal Hocko wrote:
> > On Thu 26-01-17 12:33:55, Daniel Borkmann wrote:
> > > On 01/26/2017 11:08 AM, Michal Hocko wrote:
> > [...]
> > > > If you disagree I can drop the bpf part of course...
> > > 
> > > If we could consolidate these spots with kvmalloc() eventually, I'm
> > > all for it. But even if __GFP_NORETRY is not covered down to all
> > > possible paths, it kind of does have an effect already of saying
> > > 'don't try too hard', so would it be harmful to still keep that for
> > > now? If it's not, I'd personally prefer to just leave it as is until
> > > there's some form of support by kvmalloc() and friends.
> > 
> > Well, you can use kvmalloc(size, GFP_KERNEL|__GFP_NORETRY). It is not
> > disallowed. It is not _supported_ which means that if it doesn't work as
> > you expect you are on your own. Which is actually the situation right
> > now as well. But I still think that this is just not right thing to do.
> > Even though it might happen to work in some cases it gives a false
> > impression of a solution. So I would rather go with
> 
> Hmm. 'On my own' means, we could potentially BUG somewhere down the
> vmalloc implementation, etc, presumably? So it might in-fact be
> harmful to pass that, right?

No it would mean that it might eventually hit the behavior which you are
trying to avoid - in other words it may invoke OOM killer even though
__GFP_NORETRY means giving up before any system wide disruptive actions
a re taken.

> 
> > diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> > index 8697f43cf93c..a6dc4d596f14 100644
> > --- a/kernel/bpf/syscall.c
> > +++ b/kernel/bpf/syscall.c
> > @@ -53,6 +53,11 @@ void bpf_register_map_type(struct bpf_map_type_list *tl)
> > 
> >   void *bpf_map_area_alloc(size_t size)
> >   {
> > +	/*
> > +	 * FIXME: we would really like to not trigger the OOM killer and rather
> > +	 * fail instead. This is not supported right now. Please nag MM people
> > +	 * if these OOM start bothering people.
> > +	 */
> 
> Ok, I know this is out of scope for this series, but since i) this
> is _not_ the _only_ spot right now which has such a construct and ii)
> I am already kind of nagging a bit ;), my question would be, what
> would it take to start supporting it?

propagate gfp mask all the way down from vmalloc to all places which
might allocate down the path and especially page table allocation
function are PITA because they are really deep. This is a lot of work...

But realistically, how big is this problem really? Is it really worth
it? You said this is an admin only interface and admin can kill the
machine by OOM and other means already.

Moreover and I should probably mention it explicitly, your d407bd25a204b
reduced the likelyhood of oom for other reason. kmalloc used GPF_USER
previously and with order > 0 && order <= PAGE_ALLOC_COSTLY_ORDER this
could indeed hit the OOM e.g. due to memory fragmentation. It would be
much harder to hit the OOM killer from vmalloc which doesn't issue
higher order allocation requests. Or have you ever seen the OOM killer
pointing to the vmalloc fallback path?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
