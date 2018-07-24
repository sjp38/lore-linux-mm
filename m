Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F2C226B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 11:53:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r9-v6so1988993edh.14
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 08:53:09 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id z9-v6si1472666edm.201.2018.07.24.08.53.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 08:53:08 -0700 (PDT)
Date: Tue, 24 Jul 2018 08:52:51 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180724155248.GA24429@castle>
References: <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
 <20180724133110.GJ1934745@devbig577.frc2.facebook.com>
 <20180724135022.GO28386@dhcp22.suse.cz>
 <20180724135528.GK1934745@devbig577.frc2.facebook.com>
 <20180724142554.GQ28386@dhcp22.suse.cz>
 <20180724142820.GL1934745@devbig577.frc2.facebook.com>
 <20180724144351.GR28386@dhcp22.suse.cz>
 <20180724144940.GN1934745@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180724144940.GN1934745@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

On Tue, Jul 24, 2018 at 07:49:40AM -0700, Tejun Heo wrote:
> Hello, Michal.
> 
> On Tue, Jul 24, 2018 at 04:43:51PM +0200, Michal Hocko wrote:
> > If yes, then I do not see it ;) Mostly because panic_on_oom doesn't have
> > any scope. It is all or nothing thing. You can only control whether
> > memcg OOMs should be considered or not because this is inherently
> > dangerous to be the case by default.
> 
> Oh yeah, so, panic_on_oom is like group oom on the root cgroup, right?
> If 1, it treats the whole system as a single unit and kills it no
> matter the oom domain.  If 2, it only does so if the oom is not caused
> by restrictions in subdomains.
> 
> > oom_group has a scope and that scope is exactly what we are trying to
> > find a proper semantic for. And especially what to do if descendants in
> > the hierarchy disagree with parent(s). While I do not see a sensible
> > configuration where the scope of the OOM should define the workload is
> > indivisible I would like to prevent from "carved in stone" semantic that
> > couldn't be changed later.
> 
> And we can scope it down the same way down the cgroup hierarchy.
> 
> > So IMHO the best option would be to simply inherit the group_oom to
> > children. This would allow users to do their weird stuff but the default
> > configuration would be consistent.

I think, that the problem occurs because of the default value (0).

Let's imagine we can make default to 1.
It means, that by default we kill the whole sub-tree up to the top-level
cgroup, and it does guarantee consistency.
If on some level userspace _knows_ how to handle OOM, it opts-out
by setting oom.group to 0.

E.g. systemd _knows_ that services working in systems slice are
independent and knows how to detect that they are dead and restart.
So, it sets system.slice/memory.oom.group to 0.
