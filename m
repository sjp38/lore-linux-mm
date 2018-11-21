Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 397FC6B228F
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 19:01:52 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so4450993plr.8
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 16:01:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y40-v6sor52924606pla.26.2018.11.20.16.01.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 16:01:49 -0800 (PST)
Date: Tue, 20 Nov 2018 16:01:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 1/3] mm, proc: be more verbose about unstable VMA
 flags in /proc/<pid>/smaps
In-Reply-To: <20181120105135.GF8842@quack2.suse.cz>
Message-ID: <alpine.DEB.2.21.1811201558060.89573@chino.kir.corp.google.com>
References: <20181120103515.25280-1-mhocko@kernel.org> <20181120103515.25280-2-mhocko@kernel.org> <20181120105135.GF8842@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>

On Tue, 20 Nov 2018, Jan Kara wrote:

> > Even though vma flags exported via /proc/<pid>/smaps are explicitly
> > documented to be not guaranteed for future compatibility the warning
> > doesn't go far enough because it doesn't mention semantic changes to
> > those flags. And they are important as well because these flags are
> > a deep implementation internal to the MM code and the semantic might
> > change at any time.
> > 
> > Let's consider two recent examples:
> > http://lkml.kernel.org/r/20181002100531.GC4135@quack2.suse.cz
> > : commit e1fb4a086495 "dax: remove VM_MIXEDMAP for fsdax and device dax" has
> > : removed VM_MIXEDMAP flag from DAX VMAs. Now our testing shows that in the
> > : mean time certain customer of ours started poking into /proc/<pid>/smaps
> > : and looks at VMA flags there and if VM_MIXEDMAP is missing among the VMA
> > : flags, the application just fails to start complaining that DAX support is
> > : missing in the kernel.
> > 
> > http://lkml.kernel.org/r/alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com
> > : Commit 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
> > : introduced a regression in that userspace cannot always determine the set
> > : of vmas where thp is ineligible.
> > : Userspace relies on the "nh" flag being emitted as part of /proc/pid/smaps
> > : to determine if a vma is eligible to be backed by hugepages.
> > : Previous to this commit, prctl(PR_SET_THP_DISABLE, 1) would cause thp to
> > : be disabled and emit "nh" as a flag for the corresponding vmas as part of
> > : /proc/pid/smaps.  After the commit, thp is disabled by means of an mm
> > : flag and "nh" is not emitted.
> > : This causes smaps parsing libraries to assume a vma is eligible for thp
> > : and ends up puzzling the user on why its memory is not backed by thp.
> > 
> > In both cases userspace was relying on a semantic of a specific VMA
> > flag. The primary reason why that happened is a lack of a proper
> > internface. While this has been worked on and it will be fixed properly,
> > it seems that our wording could see some refinement and be more vocal
> > about semantic aspect of these flags as well.
> > 
> > Cc: Jan Kara <jack@suse.cz>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Honestly, it just shows that no amount of documentation is going to stop
> userspace from abusing API that's exposing too much if there's no better
> alternative. But this is a good clarification regardless. So feel free to
> add:
> 
> Acked-by: Jan Kara <jack@suse.cz>
> 

I'm not sure what is expected of a userspace developer who finds they have 
a single way to determine if something is enabled/disabled.  Should they 
refer to the documentation and see that the flag may be unstable so they 
write a kernel patch and have it merged upstream before using it?  What to 
do when they don't control the kernel version they are running on?

Anyway, mentioning that the vm flags here only have meaning depending on 
the kernel version seems like a worthwhile addition:

Acked-by: David Rientjes <rientjes@google.com>
