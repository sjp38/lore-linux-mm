Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47A656B026D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 10:49:44 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id 189-v6so2113675ybz.11
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 07:49:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z15-v6sor3009528ybk.28.2018.07.24.07.49.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 07:49:43 -0700 (PDT)
Date: Tue, 24 Jul 2018 07:49:40 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180724144940.GN1934745@devbig577.frc2.facebook.com>
References: <20180723150929.GD1934745@devbig577.frc2.facebook.com>
 <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
 <20180724133110.GJ1934745@devbig577.frc2.facebook.com>
 <20180724135022.GO28386@dhcp22.suse.cz>
 <20180724135528.GK1934745@devbig577.frc2.facebook.com>
 <20180724142554.GQ28386@dhcp22.suse.cz>
 <20180724142820.GL1934745@devbig577.frc2.facebook.com>
 <20180724144351.GR28386@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724144351.GR28386@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

Hello, Michal.

On Tue, Jul 24, 2018 at 04:43:51PM +0200, Michal Hocko wrote:
> If yes, then I do not see it ;) Mostly because panic_on_oom doesn't have
> any scope. It is all or nothing thing. You can only control whether
> memcg OOMs should be considered or not because this is inherently
> dangerous to be the case by default.

Oh yeah, so, panic_on_oom is like group oom on the root cgroup, right?
If 1, it treats the whole system as a single unit and kills it no
matter the oom domain.  If 2, it only does so if the oom is not caused
by restrictions in subdomains.

> oom_group has a scope and that scope is exactly what we are trying to
> find a proper semantic for. And especially what to do if descendants in
> the hierarchy disagree with parent(s). While I do not see a sensible
> configuration where the scope of the OOM should define the workload is
> indivisible I would like to prevent from "carved in stone" semantic that
> couldn't be changed later.

And we can scope it down the same way down the cgroup hierarchy.

> So IMHO the best option would be to simply inherit the group_oom to
> children. This would allow users to do their weird stuff but the default
> configuration would be consistent.

Persistent config inheritance is a big no no.  It really sucks because
it makes the inherited state sticky and there's no way of telling why
the current setting is the way it is without knowing the past
configurations of the hierarchy.  We actually had a pretty bad
incident due to memcg swappiness inheritance recently (top level
cgroups would inherit sysctl swappiness during boot before sysctl
initialized them and then post-boot it isn't clear why the settings
are the way they're).

Nothing in cgroup2 does persistent inheritance.  If something explicit
is necessary, we do .effective so that the effective config is clearly
visible.

> A more restrictive variant would be to disallow changing children to
> mismatch the parent oom_group == 1. This would have a slight advantage
> that those users would get back to us with their usecases and we can
> either loose the restriction or explain that what they are doing is
> questionable and help with a more appropriate configuration.

That's a nack too because across delegation, from a child pov, it
isn't clear why it can't change configs and it's also easy to
introduce a situation where a child can lock its ancestors out of
chanding their configs.

Thanks.

-- 
tejun
