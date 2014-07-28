Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 35A6C6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 09:30:49 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so10408448pad.23
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 06:30:48 -0700 (PDT)
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
        by mx.google.com with ESMTPS id ag4si17902214pac.77.2014.07.28.06.30.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 06:30:48 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so9986045pdb.27
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 06:30:47 -0700 (PDT)
From: Grant Likely <grant.likely@linaro.org>
Subject: Re: [RFC Patch V1 22/30] mm, of: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
In-Reply-To: <20140721175241.GF4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
	<1405064267-11678-23-git-send-email-jiang.liu@linux.intel.com>
	<20140721175241.GF4156@linux.vnet.ibm.com>
Date: Mon, 28 Jul 2014 07:30:40 -0600
Message-Id: <20140728133040.854F5C4095E@trevor.secretlab.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Rob Herring <robh+dt@kernel.org>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, devicetree@vger.kernel.org

On Mon, 21 Jul 2014 10:52:41 -0700, Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:
> On 11.07.2014 [15:37:39 +0800], Jiang Liu wrote:
> > When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
> > may return a node without memory, and later cause system failure/panic
> > when calling kmalloc_node() and friends with returned node id.
> > So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
> > memory for the/current cpu.
> > 
> > If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
> > is the same as cpu_to_node()/numa_node_id().
> > 
> > Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> > ---
> >  drivers/of/base.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/of/base.c b/drivers/of/base.c
> > index b9864806e9b8..40d4772973ad 100644
> > --- a/drivers/of/base.c
> > +++ b/drivers/of/base.c
> > @@ -85,7 +85,7 @@ EXPORT_SYMBOL(of_n_size_cells);
> >  #ifdef CONFIG_NUMA
> >  int __weak of_node_to_nid(struct device_node *np)
> >  {
> > -	return numa_node_id();
> > +	return numa_mem_id();
> >  }
> >  #endif
> 
> Um, NAK. of_node_to_nid() returns the NUMA node ID for a given device
> tree node. The default should be the physically local NUMA node, not the
> nearest memory-containing node.

That description doesn't match the code. This patch only changes the
default implementation of of_node_to_nid() which doesn't take the device
node into account *at all* when returning a node ID. Just look at the
diff.

I think this patch is correct, and it doesn't affect the override
versions provided by powerpc and sparc.

g.

> 
> I think the general direction of this patchset is good -- what NUMA
> information do we actually are about at each callsite. But the execution
> is blind and doesn't consider at all what the code is actually doing.
> The changelogs are all identical and don't actually provide any
> information about what errors this (or any) specific patch are
> resolving.
> 
> Thanks,
> Nish
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
