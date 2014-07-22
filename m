Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id C8F006B0039
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 17:49:15 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id k15so330430qaq.41
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 14:49:15 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id t48si687861qge.30.2014.07.22.14.49.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 14:49:15 -0700 (PDT)
Received: by mail-qg0-f54.google.com with SMTP id z60so377595qgd.41
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 14:49:15 -0700 (PDT)
Date: Tue, 22 Jul 2014 17:49:11 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for
 determining the fallback node
Message-ID: <20140722214911.GO13851@htj.dyndns.org>
References: <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
 <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com>
 <20140207054819.GC28952@lge.com>
 <alpine.DEB.2.02.1402080154140.9668@chino.kir.corp.google.com>
 <20140210010936.GA12574@lge.com>
 <20140722010305.GJ4156@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1407211809140.9778@chino.kir.corp.google.com>
 <20140722214311.GM4156@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140722214311.GM4156@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Hello,

On Tue, Jul 22, 2014 at 02:43:11PM -0700, Nishanth Aravamudan wrote:
...
> "    There is an issue currently where NUMA information is used on powerpc
>     (and possibly ia64) before it has been read from the device-tree, which
>     leads to large slab consumption with CONFIG_SLUB and memoryless nodes.
>     
>     NUMA powerpc non-boot CPU's cpu_to_node/cpu_to_mem is only accurate
>     after start_secondary(), similar to ia64, which is invoked via
>     smp_init().
>     
>     Commit 6ee0578b4daae ("workqueue: mark init_workqueues() as
>     early_initcall()") made init_workqueues() be invoked via
>     do_pre_smp_initcalls(), which is obviously before the secondary
>     processors are online.
>     ...
>     Therefore, when init_workqueues() runs, it sees all CPUs as being on
>     Node 0. On LPARs or KVM guests where Node 0 is memoryless, this leads to
>     a high number of slab deactivations
>     (http://www.spinics.net/lists/linux-mm/msg67489.html)."
> 
> Christoph/Tejun, do you see the issue I'm referring to? Is my analysis
> correct? It seems like regardless of CONFIG_USE_PERCPU_NUMA_NODE_ID, we
> have to be especially careful that users of cpu_to_{node,mem} and
> related APIs run *after* correct values are stored for all used CPUs?

Without delving into the code, yes, NUMA info should be set up as soon
as possible before major allocations happen.  All allocations which
happen beforehand would naturally be done with bogus NUMA information.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
