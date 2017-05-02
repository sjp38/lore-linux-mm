Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC7AF6B02E1
	for <linux-mm@kvack.org>; Tue,  2 May 2017 03:23:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c16so80204037pfl.21
        for <linux-mm@kvack.org>; Tue, 02 May 2017 00:23:37 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id t62si1151233pgb.245.2017.05.02.00.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 00:23:36 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id v1so19779777pgv.3
        for <linux-mm@kvack.org>; Tue, 02 May 2017 00:23:36 -0700 (PDT)
Message-ID: <1493709804.15044.9.camel@gmail.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 02 May 2017 17:23:24 +1000
In-Reply-To: <9e3b8b57-abd3-67cf-7c5c-a5cccc93f4b7@nvidia.com>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <91272c14-81df-9529-f0ae-6abb17a694ea@nvidia.com>
	 <1493688548.15044.1.camel@gmail.com>
	 <9e3b8b57-abd3-67cf-7c5c-a5cccc93f4b7@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Mon, 2017-05-01 at 22:47 -0700, John Hubbard wrote:
> 
> On 05/01/2017 06:29 PM, Balbir Singh wrote:
> > On Mon, 2017-05-01 at 13:41 -0700, John Hubbard wrote:
> > > On 04/19/2017 12:52 AM, Balbir Singh wrote:
> > > > This is a request for comments on the discussed approaches
> > > > for coherent memory at mm-summit (some of the details are at
> > > > https://lwn.net/Articles/717601/). The latest posted patch
> > > > series is at https://lwn.net/Articles/713035/. I am reposting
> > > > this as RFC, Michal Hocko suggested using HMM for CDM, but
> > > > we believe there are stronger reasons to use the NUMA approach.
> > > > The earlier patches for Coherent Device memory were implemented
> > > > and designed by Anshuman Khandual.
> > > > 
> > > 
> > > Hi Balbir,
> > > 
> > > Although I think everyone agrees that in the [very] long term, these
> > > hardware-coherent nodes probably want to be NUMA nodes, in order to decide what to
> > > code up over the next few years, we need to get a clear idea of what has to be done
> > > for each possible approach.
> > > 
> > > Here, the CDM discussion is falling just a bit short, because it does not yet
> > > include the whole story of what we would need to do. Earlier threads pointed this
> > > out: the idea started as a large patchset RFC, but then, "for ease of review", it
> > > got turned into a smaller RFC, which loses too much context.
> > 
> > Hi, John
> > 
> > I thought I explained the context, but I'll try again. I see the whole solution
> > as a composite of the following primitives:
> > 
> > 1. Enable hotplug of CDM nodes
> > 2. Isolation of CDM memory
> > 3. Migration to/from CDM memory
> > 4. Performance enhancements for migration
> > 
> 
> So, there is a little more than the above required, which is why I made that short 
> list. I'm in particular concerned about the various system calls that userspace can 
> make to control NUMA memory, and the device drivers will need notification (probably 
> mmu_notifiers, I guess), and once they get notification, in many cases they'll need 
> some way to deal with reverse mapping.

Are you suggesting that the system calls user space should be audited to
check if they should be used with a CDM device? I would
think a whole lot of this should be transparent to user space, unless it opts
in to using CDM and explictly wants to allocate and free memory -- the whole
isolation premise. w.r.t device drivers are you suggesting that the device
driver needs to know the state of each page -- free/in-use? Reverse mapping
for migration?

> 
> HMM provides all of that support, so it needs to happen here, too.
> 
> 
> 
> > The RFC here is for (2) above. (3) is handled by HMM and (4) is being discussed
> > in the community. I think the larger goals are same as HMM, except that we
> > don't need unaddressable memory, since the memory is cache coherent.
> > 
> > > 
> > > So, I'd suggest putting together something more complete, so that it can be fairly
> > > compared against the HMM-for-hardware-coherent-nodes approach.
> > > 
> > 
> > Since I intend to reuse bits of HMM, I am not sure if I want to repost those
> > patches as a part of my RFC. I hope my answers make sense, the goal is to
> > reuse as much of what is available. From a user perspective
> 
> It's hard to keep track of what the plan is, so explaining exactly what you're doing 
> helps.
> 

Fair enough, I hope I answered the questions?

> > 
> > 1. We see no new interface being added in either case, the programming model
> > would differ though
> > 2. We expect the programming model to be abstracted behind a user space
> > framework, potentially like CUDA or CXL
> > 
> >   
> > > 
> > > > Jerome posted HMM-CDM at https://lwn.net/Articles/713035/.
> > > > The patches do a great deal to enable CDM with HMM, but we
> > > > still believe that HMM with CDM is not a natural way to
> > > > represent coherent device memory and the mm will need
> > > > to be audited and enhanced for it to even work.
> > > 
> > > That is also true for the CDM approach. Specifically, in order for this to be of any
> > > use to device drivers, we'll need the following:
> > > 
> > 
> > Since Reza answered these questions, I'll skip them in this email
> 
> Yes, but he skipped over the rmap question, which I think is an important one.
>

If it is for migration, then we are going to rely on changes from HMM-CDM.
How does HMM deal with the rmap case? I presume it is not required for
unaddressable memory?

Balbir Singh. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
