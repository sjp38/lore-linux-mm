Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75EA36B0003
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 18:08:31 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id x7so2103568pfd.19
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 15:08:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q16-v6sor184254pls.136.2018.02.25.15.08.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Feb 2018 15:08:30 -0800 (PST)
Date: Mon, 26 Feb 2018 10:08:20 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: virtual memory limits control (was Re: [Lsf-pc] [LSF/MM ATTEND]
 Attend mm summit 2018)
Message-ID: <20180226100820.190de9a7@balbir.ozlabs.ibm.com>
In-Reply-To: <20180223074201.GR30681@dhcp22.suse.cz>
References: <CAKTCnz=rS14Ry7pOC2qiX5wEbRZCKwP_0u7_ncanoV18Gz9=AQ@mail.gmail.com>
	<20180222130341.GF30681@dhcp22.suse.cz>
	<CAKTCnzmsEhMYnAOtN+BtN_6bEa=+fTRYSjB+OR9isfzRruwA_Q@mail.gmail.com>
	<20180222133425.GI30681@dhcp22.suse.cz>
	<20180223090123.74248146@balbir.ozlabs.ibm.com>
	<20180223074201.GR30681@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, vdavydov@parallels.com

-lsf-pc (I can add them back, but I did not want to spam the group)
+Vladimir

On Fri, 23 Feb 2018 08:42:01 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 23-02-18 09:01:23, Balbir Singh wrote:
> > Changed the subject to reflect the discussion
> > 
> > On Thu, 22 Feb 2018 14:34:25 +0100
> > Michal Hocko <mhocko@kernel.org> wrote:
> >   
> > > On Fri 23-02-18 00:23:53, Balbir Singh wrote:  
> > > > On Fri, Feb 23, 2018 at 12:03 AM, Michal Hocko <mhocko@kernel.org> wrote:    
> > > > > On Thu 22-02-18 13:54:46, Balbir Singh wrote:
> > > > > [...]    
> > > > >> 2. Memory cgroups - I don't see a pressing need for many new features,
> > > > >> but I'd like to see if we can revive some old proposals around virtual
> > > > >> memory limits    
> > > > >
> > > > > Could you be more specific about usecase(s)?    
> > > > 
> > > > I had for a long time a virtual memory limit controller in -mm tree.
> > > > The use case was to fail allocations as opposed to OOM'ing in the
> > > > worst case as we do with the cgroup memory limits (actual page usage
> > > > control). I did not push for it then since I got side-tracked. I'd
> > > > like to pursue a use case for being able to fail allocations as
> > > > opposed to OOM'ing on a per cgroup basis. I'd like to start the
> > > > discussion again.    
> > > 
> > > So you basically want the strict no overcommit on the per memcg level?  
> > 
> > I don't think it implies strict no overcommit, the value sets the
> > overcommit ratio (independent of the global vm.overcommit_ratio, which
> > we can discuss on the side, since I don't want it to impact the use
> > case).
> > 
> > The goal of the controller was  (and its optional, may not work well
> > for sparse address spaces)
> > 
> > 1. set the vm limit
> > 2. If the limit is exceeded, fail at malloc()/mmap() as opposed to
> > OOM'ing at page fault time  
> 
> this is basically strict no-overcommit

I look at it more as Committed_AS accounting and controls not controlled
or driven by CommitLimit, but something the administrator can derive,
but your right the defaults would be CommitLimit

> 
> > 3. Application handles the fault and decide not to proceed with the
> > new task that needed more memory  
> 
> So you do not return ENOMEM but rather raise a signal? What that would
> be?

Nope, it will return ENOMEM

> 
> > I think this leads to applications being able to deal with failures
> > better. OOM is a big hammer  
> 
> Do you have any _specific_ usecase in mind?

It's mostly my frustration with OOM kills I see, granted a lot of it is
about sizing the memory cgroup correctly, but that is not an easy job.

>  
> > > I am really skeptical, to be completely honest. The global behavior is
> > > not very usable in most cases already. Making it per-memcg will just
> > > amplify all the issues (application tend to overcommit their virtual
> > > address space). Not to mention that you cannot really prevent from the
> > > OOM killer because there are allocations outside of the address space.
> > >   
> > 
> > Could you clarify on the outside address space -- as in shared
> > allocations outside the cgroup?  kernel allocations as a side-effect?  
> 
> basically anything that can be triggered from userspace and doesn't map
> into the address space - page cache, fs metadata, drm buffers etc...

Yep, the virtual memory limits controller is more about the Committed_AS.

I also noticed that Vladimir tried something similar at
https://lkml.org/lkml/2014/7/3/405

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
