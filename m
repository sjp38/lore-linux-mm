Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7016B0007
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 10:12:05 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n4-v6so490528edr.5
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:12:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h9-v6si5165366edl.176.2018.07.23.07.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 07:12:03 -0700 (PDT)
Date: Mon, 23 Jul 2018 16:12:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180723141202.GG31229@dhcp22.suse.cz>
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
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807201321040.231119@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, gthelen@google.com

On Fri 20-07-18 13:28:56, David Rientjes wrote:
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
> is reached.  The common ancestor is needed to enforce a single memory 
> limit but allow for processes to be constrained separately with other 
> controllers. 

I think you misunderstood the proposed semantic. oom.group is a property
of any (including inter-node) memcg. Once set all the processes in its
domain are killed in one go because they are considered indivisible
workload. Note how this doesn't tell anything about _how_ we select
a victim. That is not important and an in fact an implementation
detail. All we care about is that a selected victim is a part of an
indivisible workload and we have to tear down all of it. Future
extensions can talk more about how we select the victim but the
fundamental property of a group to be indivisible workload or a group of
semi raleted processes is a 0/1 IMHO.

Now there still are questions to iron out for that model. E.g. should
we allow to make a subtree of oom.group == 1 to be group == 0? In other
words something would be indivisible workload for one OOM context while
it is not for more restrictive OOM scope. If yes, then what is the
usecase?
-- 
Michal Hocko
SUSE Labs
