Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA5276B0005
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:28:59 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id s3-v6so8199333plp.21
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 13:28:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j70-v6sor744210pgd.368.2018.07.20.13.28.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 13:28:58 -0700 (PDT)
Date: Fri, 20 Jul 2018 13:28:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
In-Reply-To: <20180720112131.GX72677@devbig577.frc2.facebook.com>
Message-ID: <alpine.DEB.2.21.1807201321040.231119@chino.kir.corp.google.com>
References: <20180713230545.GA17467@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807131608530.218060@chino.kir.corp.google.com> <20180713231630.GB17467@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
 <20180717173844.GB14909@castle.DHCP.thefacebook.com> <20180717194945.GM7193@dhcp22.suse.cz> <20180717200641.GB18762@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1807171329200.12251@chino.kir.corp.google.com> <20180717205221.GA19862@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807200126540.119737@chino.kir.corp.google.com> <20180720112131.GX72677@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, gthelen@google.com

On Fri, 20 Jul 2018, Tejun Heo wrote:

> > process chosen for oom kill.  I know that you care about the latter.  My 
> > *only* suggestion was for the tunable to take a string instead of a 
> > boolean so it is extensible for future use.  This seems like something so 
> > trivial.
> 
> So, I'd much prefer it as boolean.  It's a fundamentally binary
> property, either handle the cgroup as a unit when chosen as oom victim
> or not, nothing more.

With the single hierarchy mandate of cgroup v2, the need arises to 
separate processes from a single job into subcontainers for use with 
controllers other than mem cgroup.  In that case, we have no functionality 
to oom kill all processes in the subtree.

A boolean can kill all processes attached to the victim's mem cgroup, but 
cannot kill all processes in a subtree if the limit of a common ancestor 
is reached.  The common ancestor is needed to enforce a single memory 
limit but allow for processes to be constrained separately with other 
controllers. 

So if group oom takes on a boolean type, then we mandate that all 
processes to be killed must share the same cgroup which cannot always be 
done.  Thus, I was suggesting that group oom can also configure for 
subtree killing when the limit of a shared ancestor is reached.  This is 
unique only to non-leaf cgroups.  So non-leaf and leaf cgroups have 
mutually exclusive group oom settings; if we have two tunables, which this 
would otherwise require, the setting of one would always be irrelevant 
based on non-leaf or leaf.
