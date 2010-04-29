Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C9E346B0222
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 12:57:45 -0400 (EDT)
Subject: Re: [PATCH 2/8] numa:  x86_64:  use generic percpu var
 numa_node_id() implementation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <4BCA74D8.3030503@kernel.org>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
	 <20100415173003.8801.48519.sendpatchset@localhost.localdomain>
	 <alpine.DEB.2.00.1004161144350.8664@router.home>
	 <4BCA74D8.3030503@kernel.org>
Content-Type: text/plain
Date: Thu, 29 Apr 2010 12:56:48 -0400
Message-Id: <1272560208.4927.39.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-04-18 at 11:56 +0900, Tejun Heo wrote:
> On 04/17/2010 01:46 AM, Christoph Lameter wrote:
> > Maybe provide a generic function to set the node for cpu X?
> 
> Yeap, seconded.  Also, why not use numa_node_id() in
> common.c::cpu_init()?

Tejun:  do you mean:

#ifdef CONFIG_NUMA
        if (cpu != 0 && percpu_read(numa_node) == 0 &&
........................^ here?
            early_cpu_to_node(cpu) != NUMA_NO_NODE)
                set_numa_node(early_cpu_to_node(cpu));
#endif

Looks like 'numa_node_id()' would work there.

But, I wonder what the "cpu != 0 && percpu_read(numa_node) == 0" is
trying to do?

E.g., is "cpu != 0" testing "cpu != boot_cpu_id"?  Is there an implicit
assumption that the boot cpu is zero?  Or just a non-zero cpuid is
obviously initialized?

And the "percpu_read(numa_node) == 0" is testing that this cpu's
'numa_node' MAY not be initialized?  0 is a valid node id for !0 cpu
ids.  But it's OK to reinitialize numa_node in that case.

Just trying to grok the intent.  Maybe someone will chime in.

Anyway, if the intent is to test the percpu 'numa_node' for
initialization, using numa_node_id() might obscure this even more.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
