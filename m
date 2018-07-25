Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0D20E6B029A
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:00:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12-v6so2900186edi.12
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 05:00:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k28-v6si849094edj.250.2018.07.25.05.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 05:00:36 -0700 (PDT)
Date: Wed, 25 Jul 2018 14:00:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180725120035.GG28386@dhcp22.suse.cz>
References: <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
 <20180724133110.GJ1934745@devbig577.frc2.facebook.com>
 <20180724135022.GO28386@dhcp22.suse.cz>
 <20180724135528.GK1934745@devbig577.frc2.facebook.com>
 <20180724142554.GQ28386@dhcp22.suse.cz>
 <20180724142820.GL1934745@devbig577.frc2.facebook.com>
 <20180724144351.GR28386@dhcp22.suse.cz>
 <20180724144940.GN1934745@devbig577.frc2.facebook.com>
 <20180724155248.GA24429@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724155248.GA24429@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Tejun Heo <tj@kernel.org>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

On Tue 24-07-18 08:52:51, Roman Gushchin wrote:
> On Tue, Jul 24, 2018 at 07:49:40AM -0700, Tejun Heo wrote:
> > Hello, Michal.
> > 
> > On Tue, Jul 24, 2018 at 04:43:51PM +0200, Michal Hocko wrote:
> > > If yes, then I do not see it ;) Mostly because panic_on_oom doesn't have
> > > any scope. It is all or nothing thing. You can only control whether
> > > memcg OOMs should be considered or not because this is inherently
> > > dangerous to be the case by default.
> > 
> > Oh yeah, so, panic_on_oom is like group oom on the root cgroup, right?
> > If 1, it treats the whole system as a single unit and kills it no
> > matter the oom domain.  If 2, it only does so if the oom is not caused
> > by restrictions in subdomains.
> > 
> > > oom_group has a scope and that scope is exactly what we are trying to
> > > find a proper semantic for. And especially what to do if descendants in
> > > the hierarchy disagree with parent(s). While I do not see a sensible
> > > configuration where the scope of the OOM should define the workload is
> > > indivisible I would like to prevent from "carved in stone" semantic that
> > > couldn't be changed later.
> > 
> > And we can scope it down the same way down the cgroup hierarchy.
> > 
> > > So IMHO the best option would be to simply inherit the group_oom to
> > > children. This would allow users to do their weird stuff but the default
> > > configuration would be consistent.
> 
> I think, that the problem occurs because of the default value (0).
> 
> Let's imagine we can make default to 1.
> It means, that by default we kill the whole sub-tree up to the top-level
> cgroup, and it does guarantee consistency.
> If on some level userspace _knows_ how to handle OOM, it opts-out
> by setting oom.group to 0.

Apart that default group_oom is absolutely unacceptable as explained earlier.
I still fail to see how this makes situation any different. So say you know
that you are not group oom so what will happen now. As soon as well
check parents we are screwed the same way. Not to mention that a global
oom would mean killing the world basically...

-- 
Michal Hocko
SUSE Labs
