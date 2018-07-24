Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A71F6B026B
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:26:45 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b9-v6so2918621pla.19
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 06:26:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5-v6si10886839pgg.84.2018.07.24.06.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 06:26:44 -0700 (PDT)
Date: Tue, 24 Jul 2018 15:26:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180724132640.GL28386@dhcp22.suse.cz>
References: <20180717194945.GM7193@dhcp22.suse.cz>
 <20180717200641.GB18762@castle.DHCP.thefacebook.com>
 <20180718081230.GP7193@dhcp22.suse.cz>
 <20180718152846.GA6840@castle.DHCP.thefacebook.com>
 <20180719073843.GL7193@dhcp22.suse.cz>
 <20180719170543.GA21770@castle.DHCP.thefacebook.com>
 <20180723141748.GH31229@dhcp22.suse.cz>
 <20180723150929.GD1934745@devbig577.frc2.facebook.com>
 <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724130836.GH1934745@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

On Tue 24-07-18 06:08:36, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jul 24, 2018 at 09:32:30AM +0200, Michal Hocko wrote:
[...]
> > > There's no reason to put any
> > > restrictions on what each cgroup can configure.  The only thing which
> > > matters is is that the effective behavior is what the highest in the
> > > ancestry configures, and, at the system level, it'd conceptually map
> > > to panic_on_oom.
> > 
> > Hmm, so do we inherit group_oom? If not, how do we prevent from
> > unexpected behavior?
> 
> Hmm... I guess we're debating two options here.  Please consider the
> following hierarchy.
> 
>       R
>       |
>       A (group oom == 1)
>      / \
>     B   C
>     |
>     D
> 
> 1. No matter what B, C or D sets, as long as A sets group oom, any oom
>    kill inside A's subtree kills the entire subtree.
> 
> 2. A's group oom policy applies iff the source of the OOM is either at
>    or above A - ie. iff the OOM is system-wide or caused by memory.max
>    of A.
> 
> In #1, it doesn't matter what B, C or D sets, so it's kinda moot to
> discuss whether they inherit A's setting or not.  A's is, if set,
> always overriding.  In #2, what B, C or D sets matters if they also
> set their own memory.max, so there's no reason for them to inherit
> anything.
> 
> I'm actually okay with either option.  #2 is more flexible than #1 but
> given that this is a cgroup owned property which is likely to be set
> on per-application basis, #1 is likely good enough.
> 
> IIRC, we did #2 in the original implementation and the simplified one
> is doing #1, right?

No, we've been discussing #2 unless I have misunderstood something.
I find it rather non-intuitive that a property outside of the oom domain
controls the behavior inside the domain. I will keep thinking about that
though.
-- 
Michal Hocko
SUSE Labs
