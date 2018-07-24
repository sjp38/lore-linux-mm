Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA266B0005
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:08:40 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id c8-v6so2006638ybi.19
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 06:08:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t6-v6sor2607015ywg.25.2018.07.24.06.08.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 06:08:39 -0700 (PDT)
Date: Tue, 24 Jul 2018 06:08:36 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180724130836.GH1934745@devbig577.frc2.facebook.com>
References: <20180717173844.GB14909@castle.DHCP.thefacebook.com>
 <20180717194945.GM7193@dhcp22.suse.cz>
 <20180717200641.GB18762@castle.DHCP.thefacebook.com>
 <20180718081230.GP7193@dhcp22.suse.cz>
 <20180718152846.GA6840@castle.DHCP.thefacebook.com>
 <20180719073843.GL7193@dhcp22.suse.cz>
 <20180719170543.GA21770@castle.DHCP.thefacebook.com>
 <20180723141748.GH31229@dhcp22.suse.cz>
 <20180723150929.GD1934745@devbig577.frc2.facebook.com>
 <20180724073230.GE28386@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724073230.GE28386@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

Hello,

On Tue, Jul 24, 2018 at 09:32:30AM +0200, Michal Hocko wrote:
> > I'd find the cgroup closest to the root which has the oom group set
> > and kill the entire subtree.
> 
> Yes, this is what we have been discussing. In fact it would match the
> behavior which is still sitting in the mmotm tree where we compare
> groups.

Yeah, I'd too.  Everyone except David seems to agree that that's a
good enough approach for now.

> > There's no reason to put any
> > restrictions on what each cgroup can configure.  The only thing which
> > matters is is that the effective behavior is what the highest in the
> > ancestry configures, and, at the system level, it'd conceptually map
> > to panic_on_oom.
> 
> Hmm, so do we inherit group_oom? If not, how do we prevent from
> unexpected behavior?

Hmm... I guess we're debating two options here.  Please consider the
following hierarchy.

      R
      |
      A (group oom == 1)
     / \
    B   C
    |
    D

1. No matter what B, C or D sets, as long as A sets group oom, any oom
   kill inside A's subtree kills the entire subtree.

2. A's group oom policy applies iff the source of the OOM is either at
   or above A - ie. iff the OOM is system-wide or caused by memory.max
   of A.

In #1, it doesn't matter what B, C or D sets, so it's kinda moot to
discuss whether they inherit A's setting or not.  A's is, if set,
always overriding.  In #2, what B, C or D sets matters if they also
set their own memory.max, so there's no reason for them to inherit
anything.

I'm actually okay with either option.  #2 is more flexible than #1 but
given that this is a cgroup owned property which is likely to be set
on per-application basis, #1 is likely good enough.

IIRC, we did #2 in the original implementation and the simplified one
is doing #1, right?

Thanks.

-- 
tejun
