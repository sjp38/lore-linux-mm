Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id A450B6B0003
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 14:10:49 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id w68so761381ith.0
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 11:10:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c7sor16207667itk.21.2018.11.12.11.10.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 11:10:48 -0800 (PST)
MIME-Version: 1.0
References: <20181109211521.5ospn33pp552k2xv@xakep.localdomain>
 <18b6634b912af7b4ec01396a2b0f3b31737c9ea2.camel@linux.intel.com>
 <20181110000006.tmcfnzynelaznn7u@xakep.localdomain> <0d8782742d016565870c578848138aaedf873a7c.camel@linux.intel.com>
 <20181110011652.2wozbvfimcnhogfj@xakep.localdomain>
In-Reply-To: <20181110011652.2wozbvfimcnhogfj@xakep.localdomain>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 12 Nov 2018 11:10:35 -0800
Message-ID: <CAKgT0UdDYC5RvZ1XgLTamFpBe3foPMs+SV_kSUVNDWLvxSC_1Q@mail.gmail.com>
Subject: Re: [mm PATCH v5 0/7] Deferred page init improvements
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@soleen.com, Andrew Morton <akpm@linux-foundation.org>
Cc: alexander.h.duyck@linux.intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm <linux-mm@kvack.org>, sparclinux@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm@lists.01.org, David Miller <davem@davemloft.net>, pavel.tatashin@microsoft.com, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, Mel Gorman <mgorman@techsingularity.net>, yi.z.zhang@linux.intel.com

On Fri, Nov 9, 2018 at 5:17 PM Pavel Tatashin <pasha.tatashin@soleen.com> wrote:
>
> On 18-11-09 16:46:02, Alexander Duyck wrote:
> > On Fri, 2018-11-09 at 19:00 -0500, Pavel Tatashin wrote:
> > > On 18-11-09 15:14:35, Alexander Duyck wrote:
> > > > On Fri, 2018-11-09 at 16:15 -0500, Pavel Tatashin wrote:
> > > > > On 18-11-05 13:19:25, Alexander Duyck wrote:
> > > > > > This patchset is essentially a refactor of the page initialization logic
> > > > > > that is meant to provide for better code reuse while providing a
> > > > > > significant improvement in deferred page initialization performance.
> > > > > >
> > > > > > In my testing on an x86_64 system with 384GB of RAM and 3TB of persistent
> > > > > > memory per node I have seen the following. In the case of regular memory
> > > > > > initialization the deferred init time was decreased from 3.75s to 1.06s on
> > > > > > average. For the persistent memory the initialization time dropped from
> > > > > > 24.17s to 19.12s on average. This amounts to a 253% improvement for the
> > > > > > deferred memory initialization performance, and a 26% improvement in the
> > > > > > persistent memory initialization performance.
> > > > >
> > > > > Hi Alex,
> > > > >
> > > > > Please try to run your persistent memory init experiment with Daniel's
> > > > > patches:
> > > > >
> > > > > https://lore.kernel.org/lkml/20181105165558.11698-1-daniel.m.jordan@oracle.com/
> > > >
> > > > I've taken a quick look at it. It seems like a bit of a brute force way
> > > > to try and speed things up. I would be worried about it potentially
> > >
> > > There is a limit to max number of threads that ktasks start. The memory
> > > throughput is *much* higher than what one CPU can maxout in a node, so
> > > there is no reason to leave the other CPUs sit idle during boot when
> > > they can help to initialize.
> >
> > Right, but right now that limit can still be pretty big when it is
> > something like 25% of all the CPUs on a 288 CPU system.
>
> It is still OK. About 9 threads per node.
>
> That machine has 1T of memory, which means 8 nodes need to initialize 2G
> of memory each. With 46G/s throughout it should take 0.043s Which is 10
> times higher than what Daniel sees with 0.325s, so there is still room
> to saturate the memory throughput.
>
> Now, if the multi-threadding efficiency is good, it should take
> 1.261s / 9 threads =  0.14s

The two patch sets combined would hopefully do better then that,
although I don't know what the clock speed is on the CPUs in use.

The system I have been testing with has 1.5TB spread over 4 nodes. So
we have effectively 3 times as much to initialize and with the
"numa=fake=8U" I was seeing it only take .275s to initialize the
nodes.

> >
> > One issue is the way the code was ends up essentially blowing out the
> > cache over and over again. Doing things in two passes made it really
> > expensive as you took one cache miss to initialize it, and another to
> > free it. I think getting rid of that is one of the biggest gains with
> > my patch set.
>
> I am not arguing that your patches make sense, all I am saying that
> ktasks improve time order of magnitude better on machines with large
> amount of memory.

The point I was trying to make is that it doesn't. You say it is an
order of magnitude better but it is essentially 3.5x vs 3.8x and to
achieve the 3.8x you are using a ton of system resources. My approach
is meant to do more with less, while this approach will throw a
quarter of the system at  page initialization.

An added advantage to my approach is that it speeds up things
regardless of the number of cores used, whereas the scaling approach
requires that there be more cores available to use. So for example on
some of the new AMD Zen stuff I am not sure the benefit would be all
that great since if I am not mistaken each tile is only 8 processors
so at most you are only doubling the processing power applied to the
initialization. In such a case it is likely that my approach would
fare much better then this approach since I don't require additional
cores to achieve the same results.

Anyway there are tradeoffs we have to take into account.

I will go over the changes you suggested after Plumbers. I just need
to figure out if I am doing incremental changes, or if Andrew wants me
to just resubmit the whole set. I can probably deal with these changes
either way since most of them are pretty small.

Thanks.

- Alex
