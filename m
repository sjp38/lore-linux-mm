Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9D296B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 03:13:12 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i68-v6so904336pfb.9
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 00:13:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c17-v6sor934430pgi.295.2018.08.08.00.13.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 00:13:11 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg, oom: be careful about races when warning about no reclaimable task
Date: Wed,  8 Aug 2018 09:12:59 +0200
Message-Id: <20180808071301.12478-1-mhocko@kernel.org>
In-Reply-To: <20180808064414.GA27972@dhcp22.suse.cz>
References: <20180808064414.GA27972@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 08-08-18 08:44:14, Michal Hocko wrote:
> On Tue 07-08-18 16:54:25, Johannes Weiner wrote:
[...]
> > What the global OOM killer does in that situation is dump the header
> > anyway:
> > 
> > 	/* Found nothing?!?! Either we hang forever, or we panic. */
> > 	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
> > 		dump_header(oc, NULL);
> > 		panic("Out of memory and no killable processes...\n");
> > 	}
> > 
> > I think that would make sense here as well - without the panic,
> > obviously, but we can add our own pr_err() line following the header.
> > 
> > That gives us the exact memory situation of the cgroup and who is
> > trying to allocate and from what context, but in a format that is
> > known to users without claiming right away that it's a kernel issue.
> 
> I was considering doing that initially but then decided that warning is
> less noisy and still a good "let us know" trigger. It doesn't give us
> the whole picture which is obviously a downside but we would at least
> know that something is going south one have the trace to who that might
> be should this be a bug rather than a misconfiguration.
> 
> But I do not mind doing dump_header as well. Care to send a patch?

OK, so I found few spare cycles and here is what I came up with. The
first patch fixes the spurious warning and I have separated the check
and added a comment as you asked. The second patch replaces warning with
oom report.

Does that look better?
