Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id A2AC86B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:48:22 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id z83-v6so824514ywg.3
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 13:48:22 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id c16-v6si645421ywa.301.2018.07.20.13.48.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 13:48:21 -0700 (PDT)
Date: Fri, 20 Jul 2018 13:47:54 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180720204746.GA23478@castle.DHCP.thefacebook.com>
References: <20180713231630.GB17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
 <20180717173844.GB14909@castle.DHCP.thefacebook.com>
 <20180717194945.GM7193@dhcp22.suse.cz>
 <20180717200641.GB18762@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807171329200.12251@chino.kir.corp.google.com>
 <20180717205221.GA19862@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807200126540.119737@chino.kir.corp.google.com>
 <20180720112131.GX72677@devbig577.frc2.facebook.com>
 <alpine.DEB.2.21.1807201321040.231119@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807201321040.231119@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, gthelen@google.com

On Fri, Jul 20, 2018 at 01:28:56PM -0700, David Rientjes wrote:
> On Fri, 20 Jul 2018, Tejun Heo wrote:
> 
> > > process chosen for oom kill.  I know that you care about the latter.  My 
> > > *only* suggestion was for the tunable to take a string instead of a 
> > > boolean so it is extensible for future use.  This seems like something so 
> > > trivial.
> > 
> > So, I'd much prefer it as boolean.  It's a fundamentally binary
> > property, either handle the cgroup as a unit when chosen as oom victim
> > or not, nothing more.
> 
> With the single hierarchy mandate of cgroup v2, the need arises to 
> separate processes from a single job into subcontainers for use with 
> controllers other than mem cgroup.  In that case, we have no functionality 
> to oom kill all processes in the subtree.
> 
> A boolean can kill all processes attached to the victim's mem cgroup, but 
> cannot kill all processes in a subtree if the limit of a common ancestor 
> is reached.

Why so?

Once again my proposal:
as soon as the OOM killer selected a victim task,
we'll look at the victim task's memory cgroup.
If memory.oom.group is not set, we're done.
Otherwise let's traverse the memory cgroup tree up to
the OOMing cgroup (or root) as long as memory.oom.group is set.
Kill the last cgroup entirely (including all children).

Please, note:
we do not look at memory.oom.group of the OOMing cgroup,
we're looking at the memcg of the victim task.

If this model doesn't work well for you case,
please, describe it on an example. I'm not sure
I understand your problem anymore.

Thanks!
