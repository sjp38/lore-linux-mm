Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9F66B0008
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 02:42:03 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v16so4990085wrv.14
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 23:42:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si1501187wrd.38.2018.02.22.23.42.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 23:42:02 -0800 (PST)
Date: Fri, 23 Feb 2018 08:42:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: virtual memory limits control (was Re: [Lsf-pc] [LSF/MM ATTEND]
 Attend mm summit 2018)
Message-ID: <20180223074201.GR30681@dhcp22.suse.cz>
References: <CAKTCnz=rS14Ry7pOC2qiX5wEbRZCKwP_0u7_ncanoV18Gz9=AQ@mail.gmail.com>
 <20180222130341.GF30681@dhcp22.suse.cz>
 <CAKTCnzmsEhMYnAOtN+BtN_6bEa=+fTRYSjB+OR9isfzRruwA_Q@mail.gmail.com>
 <20180222133425.GI30681@dhcp22.suse.cz>
 <20180223090123.74248146@balbir.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180223090123.74248146@balbir.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, lsf-pc <lsf-pc@lists.linux-foundation.org>

On Fri 23-02-18 09:01:23, Balbir Singh wrote:
> Changed the subject to reflect the discussion
> 
> On Thu, 22 Feb 2018 14:34:25 +0100
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 23-02-18 00:23:53, Balbir Singh wrote:
> > > On Fri, Feb 23, 2018 at 12:03 AM, Michal Hocko <mhocko@kernel.org> wrote:  
> > > > On Thu 22-02-18 13:54:46, Balbir Singh wrote:
> > > > [...]  
> > > >> 2. Memory cgroups - I don't see a pressing need for many new features,
> > > >> but I'd like to see if we can revive some old proposals around virtual
> > > >> memory limits  
> > > >
> > > > Could you be more specific about usecase(s)?  
> > > 
> > > I had for a long time a virtual memory limit controller in -mm tree.
> > > The use case was to fail allocations as opposed to OOM'ing in the
> > > worst case as we do with the cgroup memory limits (actual page usage
> > > control). I did not push for it then since I got side-tracked. I'd
> > > like to pursue a use case for being able to fail allocations as
> > > opposed to OOM'ing on a per cgroup basis. I'd like to start the
> > > discussion again.  
> > 
> > So you basically want the strict no overcommit on the per memcg level?
> 
> I don't think it implies strict no overcommit, the value sets the
> overcommit ratio (independent of the global vm.overcommit_ratio, which
> we can discuss on the side, since I don't want it to impact the use
> case).
> 
> The goal of the controller was  (and its optional, may not work well
> for sparse address spaces)
> 
> 1. set the vm limit
> 2. If the limit is exceeded, fail at malloc()/mmap() as opposed to
> OOM'ing at page fault time

this is basically strict no-overcommit

> 3. Application handles the fault and decide not to proceed with the
> new task that needed more memory

So you do not return ENOMEM but rather raise a signal? What that would
be?

> I think this leads to applications being able to deal with failures
> better. OOM is a big hammer

Do you have any _specific_ usecase in mind?
 
> > I am really skeptical, to be completely honest. The global behavior is
> > not very usable in most cases already. Making it per-memcg will just
> > amplify all the issues (application tend to overcommit their virtual
> > address space). Not to mention that you cannot really prevent from the
> > OOM killer because there are allocations outside of the address space.
> > 
> 
> Could you clarify on the outside address space -- as in shared
> allocations outside the cgroup?  kernel allocations as a side-effect?

basically anything that can be triggered from userspace and doesn't map
into the address space - page cache, fs metadata, drm buffers etc...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
