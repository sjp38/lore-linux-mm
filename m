Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 151936B011A
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:32:13 -0400 (EDT)
Received: by mail-yk0-f170.google.com with SMTP id q9so1941758ykb.15
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 16:32:12 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id p47si28606726yhk.96.2014.06.10.16.32.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 16:32:12 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 10 Jun 2014 17:32:11 -0600
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1356538C803B
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:32:09 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5ANW9Ms65077342
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 23:32:09 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5ANW85K021043
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:32:08 -0400
Date: Tue, 10 Jun 2014 16:31:57 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: Node 0 not necessary for powerpc?
Message-ID: <20140610233157.GB24463@linux.vnet.ibm.com>
References: <20140311195632.GA946@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403120839110.6865@nuc>
 <20140313164949.GC22247@linux.vnet.ibm.com>
 <20140519182400.GM8941@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1405210915170.7859@gentwo.org>
 <20140521185812.GA5259@htj.dyndns.org>
 <20140521195743.GA5755@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1406091447240.5271@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1406091447240.5271@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <htejun@gmail.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, anton@samba.org, benh@kernel.crashing.org, tony.luck@intel.com

On 09.06.2014 [14:47:57 -0700], David Rientjes wrote:
> On Wed, 21 May 2014, Nishanth Aravamudan wrote:
> 
> > For context: I was looking at why N_ONLINE was statically setting Node 0
> > to be online, whether or not the topology is that way -- I've been
> > getting several bugs lately where Node 0 is online, but has no CPUs and
> > no memory on it, on powerpc. 
> > 
> > On powerpc, setup_per_cpu_areas calls into ___alloc_bootmem_node using
> > NODE_DATA(cpu_to_node(cpu)).
> > 
> > Currently, cpu_to_node() in arch/powerpc/include/asm/topology.h does:
> > 
> >         /*
> >          * During early boot, the numa-cpu lookup table might not have been
> >          * setup for all CPUs yet. In such cases, default to node 0.
> >          */
> >         return (nid < 0) ? 0 : nid;
> > 
> > And so early at boot, if node 0 is not present, we end up accessing an
> > unitialized NODE_DATA(). So this seems buggy (I'll contact the powerpc
> > deveopers separately on that).
> > 
> 
> I think what this really wants to do is NODE_DATA(cpu_to_mem(cpu)) and I 
> thought ppc had the cpu-to-local-memory-node mappings correct?

Except cpu_to_mem relies on the mapping being defined, but early in
boot, specifically, it isn't yet (at least not necessarily).

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
