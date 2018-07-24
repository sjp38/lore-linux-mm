Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92F256B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 10:43:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g5-v6so1913095edp.1
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 07:43:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2-v6si758391edl.104.2018.07.24.07.43.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 07:43:56 -0700 (PDT)
Date: Tue, 24 Jul 2018 16:43:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180724144351.GR28386@dhcp22.suse.cz>
References: <20180723141748.GH31229@dhcp22.suse.cz>
 <20180723150929.GD1934745@devbig577.frc2.facebook.com>
 <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
 <20180724133110.GJ1934745@devbig577.frc2.facebook.com>
 <20180724135022.GO28386@dhcp22.suse.cz>
 <20180724135528.GK1934745@devbig577.frc2.facebook.com>
 <20180724142554.GQ28386@dhcp22.suse.cz>
 <20180724142820.GL1934745@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724142820.GL1934745@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

On Tue 24-07-18 07:28:20, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jul 24, 2018 at 04:25:54PM +0200, Michal Hocko wrote:
[...]
> > So can we get back to workloads and shape the semantic on top of that
> > please?
> 
> I didn't realize we were that off track.  Don't both map to what we
> were discussing almost perfectly?

If yes, then I do not see it ;) Mostly because panic_on_oom doesn't have
any scope. It is all or nothing thing. You can only control whether
memcg OOMs should be considered or not because this is inherently
dangerous to be the case by default.

oom_group has a scope and that scope is exactly what we are trying to
find a proper semantic for. And especially what to do if descendants in
the hierarchy disagree with parent(s). While I do not see a sensible
configuration where the scope of the OOM should define the workload is
indivisible I would like to prevent from "carved in stone" semantic that
couldn't be changed later.

So IMHO the best option would be to simply inherit the group_oom to
children. This would allow users to do their weird stuff but the default
configuration would be consistent.

A more restrictive variant would be to disallow changing children to
mismatch the parent oom_group == 1. This would have a slight advantage
that those users would get back to us with their usecases and we can
either loose the restriction or explain that what they are doing is
questionable and help with a more appropriate configuration.
-- 
Michal Hocko
SUSE Labs
