Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 810D56B02E1
	for <linux-mm@kvack.org>; Wed, 17 May 2017 15:37:27 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u75so8029317qka.13
        for <linux-mm@kvack.org>; Wed, 17 May 2017 12:37:27 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id e58si3100542qta.179.2017.05.17.12.37.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 12:37:26 -0700 (PDT)
Message-ID: <1495049834.3092.39.camel@kernel.crashing.org>
Subject: Re: [RFC summary] Enable Coherent Device Memory
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 18 May 2017 05:37:14 +1000
In-Reply-To: <20170517105812.plj54qwbr334w5r5@techsingularity.net>
References: <1494569882.21563.8.camel@gmail.com>
	 <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
	 <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
	 <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
	 <1494973607.21847.50.camel@kernel.crashing.org>
	 <20170517082836.whe3hggeew23nwvz@techsingularity.net>
	 <1495011826.3092.18.camel@kernel.crashing.org>
	 <20170517091511.gjxx46d2h6gmcqjf@techsingularity.net>
	 <1495014995.3092.20.camel@kernel.crashing.org>
	 <20170517105812.plj54qwbr334w5r5@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, 2017-05-17 at 11:58 +0100, Mel Gorman wrote:
> The race is a non-issue unless for some reason you decide to hot-add the node
> when the machine is already heavily loaded and under memory pressure. Do it
> near boot time and no CPU-local allocation is going to hit it. In itself,
> special casing the core VM is overkill.
> 
> If you decide to use ZONE_MOVABLE and take the remote hit penalty of page
> tables, then you can also migrate all the pages away after the onlining
> and isolation is complete if it's a serious concern in practice.
> 
> > Unless we have a way to create a node without actually making it
> > available for allocations, so we get a chance to establish policies for
> > it, then "online" it ?
> > 
> 
> Conceivably, that could be done although again it's somewhat overkill
> as the race only applies if hot-adding CDM under heavy memory pressure
> sufficient to overflow to a very remote node.

I wouldn't dismiss the problem that readily. It might by ok for our
initial customer needs but long run, there's a lot of demand for SR-IOV 
GPUs and pass-through.

It's not far fetched to have GPU being dynamically added/removed from
partitions based on usage, which means possibly under significant
pressure.

That said, this can be solved later if needed.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
