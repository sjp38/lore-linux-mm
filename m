Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5L6P44b019337
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 02:25:05 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5L6P4hd279940
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 02:25:04 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5L6P4Lb022307
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 02:25:04 -0400
Subject: Re: [Lhms-devel] [RFC] patch [1/1] x86_64 numa aware sparsemem
	add_memory	functinality
From: keith mannthey <kmannth@us.ibm.com>
Reply-To: kmannth@us.ibm.com
In-Reply-To: <20060621150653.e00c6d76.kamezawa.hiroyu@jp.fujitsu.com>
References: <1150868581.8518.28.camel@keithlap>
	 <20060621150653.e00c6d76.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 20 Jun 2006 23:25:01 -0700
Message-Id: <1150871101.8518.57.camel@keithlap>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Prarit Bhargava--redhat <prarit@redhat.com>, linux-mm <linux-mm@kvack.org>, ak@suse.de, konrad <darnok@us.ibm.com>, lhms-devel <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-06-21 at 15:06 +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 20 Jun 2006 22:43:01 -0700
> keith mannthey <kmannth@us.ibm.com> wrote:
> 
> > Hello all,
> >   This patch is an attempt to add a numa ware add_memory functionality
> > to x86_64 using CONFIG_SPARSEMEM.  The add memory function today just
> > grabs the pgdat from node 0 and adds the memory there.  On a numa system
> > this is functional but not optimal/correct. 
> > 
> 
> At first, sorry for confusing.
> reserve_hotadd()/memory-hot-add with preallocated mem_map things are 
> maintained by x86_64 and Andi Kleen (maybe).
> So we (lhms people) are not familiar with this.
Agreeded. I don't expect lhms to know much about reserve_hotadd(). 
  Right now SPARSEMEM adds all it's memory to node 0 in x86_64.  This is
the problem I am trying to fix.  I doesn't make sense to me to rewrite
the SRAT code when RESERVE_HOTADD has done most of the work already. 

> And yes, mem_map should be allocated from local node.
> I'm now preparing "dynamic local mem_map allocation" for lhms's memory hotplug,
> which doesn't depend on SRAT.

How do you know which node to add the memory too without something like
the SRAT that define memory locality of hot-add zones? SPARSEMEM doesn't
depend on SRAT (it just needs to use to to know what zone to add to.)

This patch isn't about mem_map allocation rather what zone to add the
memory to when doing SPASEMEM hot-add.  A numa aware mem_map allocation
would belong in generic SPARSEMEM code. 

> 
> >   The SRAT can expose future memory locality.  This information is
> > already tracked by the nodes_add data structure (it keeps the
> > memory/node locality information) from the SRAT code.  The code in
> > srat.c is built around RESERVE_HOTADD.  This patch is a little subtle in
> > the way it uses the existing code for use with sparsemem.  Perhaps
> > acpi_numa_memory_affinity_init needs a larger refactor to fit both
> > RESERVE_HOTADD and sparsemem.  
> > 
> >   This patch still hotadd_percent as a flag to the whole srat parsing
> > code to disable and contain broken bios.  It's functionality is retained
> > and an on off switch to sparsemem hot-add.  Without changing the safety
> > mechanisms build into the current SRAT code I have provided a path for
> > the sparsemem hot-add path to get to the nodes_add data for use at
> > runtime. 
> > 
> >   This is a 1st run at the patch, it works with 2.6.17
> > 
> > Signed-off-by:  Keith Mannthey <kmannth@us.ibm.com>
> > 
> 
> 
> 
> _______________________________________________
> Lhms-devel mailing list
> Lhms-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lhms-devel
-- 
keith mannthey <kmannth@us.ibm.com>
Linux Technology Center IBM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
