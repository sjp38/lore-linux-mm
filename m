Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m55NNfZs001362
	for <linux-mm@kvack.org>; Thu, 5 Jun 2008 19:23:41 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m55NNVZh204620
	for <linux-mm@kvack.org>; Thu, 5 Jun 2008 19:23:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m55NNUPp017699
	for <linux-mm@kvack.org>; Thu, 5 Jun 2008 19:23:31 -0400
Date: Thu, 5 Jun 2008 17:23:28 -0600
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
Message-ID: <20080605232328.GE31534@us.ibm.com>
References: <20080603095956.781009952@amd.local0.net> <20080603100939.967775671@amd.local0.net> <1212515282.8505.19.camel@nimitz.home.sr71.net> <20080603182413.GJ20824@one.firstfloor.org> <1212519555.8505.33.camel@nimitz.home.sr71.net> <20080603205752.GK20824@one.firstfloor.org> <20080604011016.GC30863@wotan.suse.de> <20080605231247.GC31534@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080605231247.GC31534@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On 05.06.2008 [17:12:47 -0600], Nishanth Aravamudan wrote:
> On 04.06.2008 [03:10:16 +0200], Nick Piggin wrote:
> > On Tue, Jun 03, 2008 at 10:57:52PM +0200, Andi Kleen wrote:
> > > > The downside of something like this is that you have yet another data
> > > > structure to manage.  Andi, do you think something like this would be
> > > > workable?
> > > 
> > > The reason I don't like your proposal is that it makes only sense
> > > with a lot of hugepage sizes being active at the same time. But the
> > > API (one mount per size) doesn't really scale to that anyways.
> > > It should support two (as on x86), three if you stretch it, but
> > > anything beyond would be difficult.
> > > If you really wanted to support a zillion sizes you would at least
> > > first need a different flexible interface that completely hides page
> > > sizes.
> > > Otherwise you would drive both sysadmins and programmers crazy and 
> > > overlong command lines would be the smallest of their problems
> > > With two or even three sizes only the whole thing is not needed and my original
> > > scheme works fine IMHO.
> > > 
> > > That is why I was also sceptical of the newly proposed sysfs interfaces. 
> > > For two or three numbers you don't need a sysfs interface.
> > 
> > I do think your proc enhancements are clever, and you're right that
> > for the current setup they are pretty workable. The reason I haven't
> > submitted them in this round is because they do cause libhugetlbfs
> > failures...  maybe that's just because the regression suite does
> > really dumb parsing, and nothing important will break, but it is the
> > only thing I have to go on so I have to give it some credit ;)
> 
> Will chime in here that yes, regardless of anything we do here,
> libhugetlbfs will need to be updated to leverage multiple hugepage sizes
> available at run-time. And I think it is sane to make sure that the
> parser we have either is fixed if it has a bug that is causing the
> failures or assuming the failures indicate a userspace interface change
> :)
> 
> > With the sysfs API, we have a way to control the other hstates, so it
> > takes a little importance off the proc interface.
> > 
> > sysfs doesn't appear to give a huge improvement yet (although I still
> > think it is nicer), but I think the hugetlbfs guys want to have control
> > over which nodes things get allocated on etc. so I think proc really
> > was going to run out of steam at some point.
> 
> Well, I know Lee S. really wants it and it could help on large NUMA
> systems using cpusets or other process restriction methods to be able to
> specify which nodes the hugepages get allocated on.

Oh, and I imagine the layout will be something like (on power):

/sys/kernel/hugepages/hugepages-64kB/nodeX/nr_hugepages
/sys/kernel/hugepages/hugepages-64kB/nodeX/nr_overcommit_hugepages
/sys/kernel/hugepages/hugepages-64kB/nodeX/free_hugepages
/sys/kernel/hugepages/hugepages-64kB/nodeX/resv_hugepages
/sys/kernel/hugepages/hugepages-64kB/nodeX/surplus_hugepages
/sys/kernel/hugepages/hugepages-64kB/nr_hugepages
/sys/kernel/hugepages/hugepages-64kB/nr_overcommit_hugepages
/sys/kernel/hugepages/hugepages-64kB/free_hugepages
/sys/kernel/hugepages/hugepages-64kB/resv_hugepages
/sys/kernel/hugepages/hugepages-64kB/surplus_hugepages
/sys/kernel/hugepages/hugepages-16384kB/nodeX/nr_hugepages
/sys/kernel/hugepages/hugepages-16384kB/nodeX/nr_overcommit_hugepages
/sys/kernel/hugepages/hugepages-16384kB/nodeX/free_hugepages
/sys/kernel/hugepages/hugepages-16384kB/nodeX/resv_hugepages
/sys/kernel/hugepages/hugepages-16384kB/nodeX/surplus_hugepages
/sys/kernel/hugepages/hugepages-16384kB/nr_hugepages
/sys/kernel/hugepages/hugepages-16384kB/nr_overcommit_hugepages
/sys/kernel/hugepages/hugepages-16384kB/free_hugepages
/sys/kernel/hugepages/hugepages-16384kB/resv_hugepages
/sys/kernel/hugepages/hugepages-16384kB/surplus_hugepages
/sys/kernel/hugepages/hugepages-16777216kB/nodeX/nr_hugepages
/sys/kernel/hugepages/hugepages-16777216kB/nodeX/nr_overcommit_hugepages
/sys/kernel/hugepages/hugepages-16777216kB/nodeX/free_hugepages
/sys/kernel/hugepages/hugepages-16777216kB/nodeX/resv_hugepages
/sys/kernel/hugepages/hugepages-16777216kB/nodeX/surplus_hugepages
/sys/kernel/hugepages/hugepages-16777216kB/nr_hugepages
/sys/kernel/hugepages/hugepages-16777216kB/nr_overcommit_hugepages
/sys/kernel/hugepages/hugepages-16777216kB/free_hugepages
/sys/kernel/hugepages/hugepages-16777216kB/resv_hugepages
/sys/kernel/hugepages/hugepages-16777216kB/surplus_hugepages

Where X varies over all possible nids. Does that seem reasonable? I'm
not entirely sure I like the amount of repetion of the topology, e.g.,
does it make more sense to have:

/sys/kernel/hugepages/hugepages-64kB
/sys/kernel/hugepages/hugepages-16384kB
/sys/kernel/hugepages/hugepages-16777216kB
/sys/kernel/hugepages/nodeX/hugepages-64kB
/sys/kernel/hugepages/nodeX/hugepages-16384kB
/sys/kernel/hugepages/nodeX/hugepages-16777216kB

?

Would definitely be a more compact representation...

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
