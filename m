Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7440B6B0006
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 17:01:39 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q15so2703379pgv.2
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 14:01:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u194sor249713pgc.31.2018.02.22.14.01.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Feb 2018 14:01:37 -0800 (PST)
Date: Fri, 23 Feb 2018 09:01:23 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: virtual memory limits control (was Re: [Lsf-pc] [LSF/MM ATTEND]
 Attend mm summit 2018)
Message-ID: <20180223090123.74248146@balbir.ozlabs.ibm.com>
In-Reply-To: <20180222133425.GI30681@dhcp22.suse.cz>
References: <CAKTCnz=rS14Ry7pOC2qiX5wEbRZCKwP_0u7_ncanoV18Gz9=AQ@mail.gmail.com>
	<20180222130341.GF30681@dhcp22.suse.cz>
	<CAKTCnzmsEhMYnAOtN+BtN_6bEa=+fTRYSjB+OR9isfzRruwA_Q@mail.gmail.com>
	<20180222133425.GI30681@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, lsf-pc <lsf-pc@lists.linux-foundation.org>

Changed the subject to reflect the discussion

On Thu, 22 Feb 2018 14:34:25 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 23-02-18 00:23:53, Balbir Singh wrote:
> > On Fri, Feb 23, 2018 at 12:03 AM, Michal Hocko <mhocko@kernel.org> wrote:  
> > > On Thu 22-02-18 13:54:46, Balbir Singh wrote:
> > > [...]  
> > >> 2. Memory cgroups - I don't see a pressing need for many new features,
> > >> but I'd like to see if we can revive some old proposals around virtual
> > >> memory limits  
> > >
> > > Could you be more specific about usecase(s)?  
> > 
> > I had for a long time a virtual memory limit controller in -mm tree.
> > The use case was to fail allocations as opposed to OOM'ing in the
> > worst case as we do with the cgroup memory limits (actual page usage
> > control). I did not push for it then since I got side-tracked. I'd
> > like to pursue a use case for being able to fail allocations as
> > opposed to OOM'ing on a per cgroup basis. I'd like to start the
> > discussion again.  
> 
> So you basically want the strict no overcommit on the per memcg level?

I don't think it implies strict no overcommit, the value sets the
overcommit ratio (independent of the global vm.overcommit_ratio, which
we can discuss on the side, since I don't want it to impact the use
case).

The goal of the controller was  (and its optional, may not work well
for sparse address spaces)

1. set the vm limit
2. If the limit is exceeded, fail at malloc()/mmap() as opposed to
OOM'ing at page fault time
3. Application handles the fault and decide not to proceed with the
new task that needed more memory

I think this leads to applications being able to deal with failures
better. OOM is a big hammer

> I am really skeptical, to be completely honest. The global behavior is
> not very usable in most cases already. Making it per-memcg will just
> amplify all the issues (application tend to overcommit their virtual
> address space). Not to mention that you cannot really prevent from the
> OOM killer because there are allocations outside of the address space.
> 

Could you clarify on the outside address space -- as in shared
allocations outside the cgroup?  kernel allocations as a side-effect?

> So if you want to push this forward you really need a very good existing
> usecase to justifiy the change.

I want to start the discussion again.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
