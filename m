Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3666A6B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 04:45:08 -0400 (EDT)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id n8M8j71L008411
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 09:45:07 +0100
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by spaceape8.eur.corp.google.com with ESMTP id n8M8j1F4025153
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 01:45:01 -0700
Received: by pzk3 with SMTP id 3so2778787pzk.20
        for <linux-mm@kvack.org>; Tue, 22 Sep 2009 01:45:01 -0700 (PDT)
Date: Tue, 22 Sep 2009 01:44:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
In-Reply-To: <1253607077.7103.219.camel@pasglop>
Message-ID: <alpine.DEB.1.00.0909220132250.19097@chino.kir.corp.google.com>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <1253577603.7103.174.camel@pasglop> <alpine.DEB.1.00.0909211704180.4798@chino.kir.corp.google.com> <alpine.DEB.1.10.0909220227050.3719@V090114053VZO-1> <alpine.DEB.1.00.0909220023070.9061@chino.kir.corp.google.com>
 <1253607077.7103.219.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Sep 2009, Benjamin Herrenschmidt wrote:

> While I like the idea of NUMA nodes being strictly memory and everything
> else being expressed by distances, we'll have to clean up quite a few
> corners with skeletons in various states of decompositions waiting for
> us there.
> 

Agreed, it's invasive.

> For example, we have code here or there that (ab)uses the NUMA node
> information to link devices with their iommu, that sort of thing. IE, a
> hard dependency which isn't really related to a concept of distance to
> any memory.
> 

ACPI's slit uses a distance of 0xff to specify that one locality is 
unreachable from another.  We could easily adopt that convention.

> At least on powerpc, nowadays, I can pretty much make everything
> fallback to some representation in the device-tree though, thus it
> shouldn't be -that- hard to fix I suppose.
> 

Cool, that's encouraging.

I really think that this type of abstraction would make things simpler in 
the long term.  For example, I just finished fixing a bug in tip where 
cpumask_of_pcibus() wasn't returning cpu_all_mask for busses without any 
affinity on x86.  This was a consequence of cpumask_of_pcibus() being 
forced to rely on pcibus_to_node() since there is no other abstraction 
available.  For busses without affinity to any specific cpus, the 
implementation had relied on returning the mapping's default node of -1 to 
represent all cpus.  That type of complexity could easily be avoided if 
the bus was isolated into its own locality and the mapping to all cpu 
localities was of local distance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
