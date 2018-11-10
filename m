Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1126B0754
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 20:17:08 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n68so7487239qkn.8
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 17:17:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h25-v6sor10217922qta.49.2018.11.09.17.16.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 17:16:55 -0800 (PST)
Date: Fri, 9 Nov 2018 20:16:52 -0500
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [mm PATCH v5 0/7] Deferred page init improvements
Message-ID: <20181110011652.2wozbvfimcnhogfj@xakep.localdomain>
References: <20181109211521.5ospn33pp552k2xv@xakep.localdomain>
 <18b6634b912af7b4ec01396a2b0f3b31737c9ea2.camel@linux.intel.com>
 <20181110000006.tmcfnzynelaznn7u@xakep.localdomain>
 <0d8782742d016565870c578848138aaedf873a7c.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0d8782742d016565870c578848138aaedf873a7c.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: daniel.m.jordan@oracle.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

On 18-11-09 16:46:02, Alexander Duyck wrote:
> On Fri, 2018-11-09 at 19:00 -0500, Pavel Tatashin wrote:
> > On 18-11-09 15:14:35, Alexander Duyck wrote:
> > > On Fri, 2018-11-09 at 16:15 -0500, Pavel Tatashin wrote:
> > > > On 18-11-05 13:19:25, Alexander Duyck wrote:
> > > > > This patchset is essentially a refactor of the page initialization logic
> > > > > that is meant to provide for better code reuse while providing a
> > > > > significant improvement in deferred page initialization performance.
> > > > > 
> > > > > In my testing on an x86_64 system with 384GB of RAM and 3TB of persistent
> > > > > memory per node I have seen the following. In the case of regular memory
> > > > > initialization the deferred init time was decreased from 3.75s to 1.06s on
> > > > > average. For the persistent memory the initialization time dropped from
> > > > > 24.17s to 19.12s on average. This amounts to a 253% improvement for the
> > > > > deferred memory initialization performance, and a 26% improvement in the
> > > > > persistent memory initialization performance.
> > > > 
> > > > Hi Alex,
> > > > 
> > > > Please try to run your persistent memory init experiment with Daniel's
> > > > patches:
> > > > 
> > > > https://lore.kernel.org/lkml/20181105165558.11698-1-daniel.m.jordan@oracle.com/
> > > 
> > > I've taken a quick look at it. It seems like a bit of a brute force way
> > > to try and speed things up. I would be worried about it potentially
> > 
> > There is a limit to max number of threads that ktasks start. The memory
> > throughput is *much* higher than what one CPU can maxout in a node, so
> > there is no reason to leave the other CPUs sit idle during boot when
> > they can help to initialize.
> 
> Right, but right now that limit can still be pretty big when it is
> something like 25% of all the CPUs on a 288 CPU system.

It is still OK. About 9 threads per node.

That machine has 1T of memory, which means 8 nodes need to initialize 2G
of memory each. With 46G/s throughout it should take 0.043s Which is 10
times higher than what Daniel sees with 0.325s, so there is still room
to saturate the memory throughput.

Now, if the multi-threadding efficiency is good, it should take
1.261s / 9 threads =  0.14s

> 
> One issue is the way the code was ends up essentially blowing out the
> cache over and over again. Doing things in two passes made it really
> expensive as you took one cache miss to initialize it, and another to
> free it. I think getting rid of that is one of the biggest gains with
> my patch set.

I am not arguing that your patches make sense, all I am saying that
ktasks improve time order of magnitude better on machines with large
amount of memory.

Pasha
