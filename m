Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7676B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:41:17 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id j7so2259648qaq.10
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 10:41:17 -0700 (PDT)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id y8si7230634qcq.19.2014.06.19.10.41.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 10:41:16 -0700 (PDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 19 Jun 2014 13:41:16 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2F9B538C804D
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:41:08 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5JHf84K262468
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 17:41:08 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5JHf6E9006243
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:41:07 -0400
Date: Thu, 19 Jun 2014 10:40:47 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: Node 0 not necessary for powerpc?
Message-ID: <20140619174047.GV16644@linux.vnet.ibm.com>
References: <20140311195632.GA946@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403120839110.6865@nuc>
 <20140313164949.GC22247@linux.vnet.ibm.com>
 <20140519182400.GM8941@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1405210915170.7859@gentwo.org>
 <20140521185812.GA5259@htj.dyndns.org>
 <20140521195743.GA5755@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1406091447240.5271@chino.kir.corp.google.com>
 <20140610233157.GB24463@linux.vnet.ibm.com>
 <20140619145950.GG26904@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140619145950.GG26904@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, anton@samba.org, benh@kernel.crashing.org, tony.luck@intel.com

On 19.06.2014 [10:59:50 -0400], Tejun Heo wrote:
> On Tue, Jun 10, 2014 at 04:31:57PM -0700, Nishanth Aravamudan wrote:
> > > I think what this really wants to do is NODE_DATA(cpu_to_mem(cpu)) and I 
> > > thought ppc had the cpu-to-local-memory-node mappings correct?
> > 
> > Except cpu_to_mem relies on the mapping being defined, but early in
> > boot, specifically, it isn't yet (at least not necessarily).
> 
> Can't ppc NODE_DATA simply return dummy generic node_data during early
> boot?  Populating it with just enough to make early boot work
> shouldn't be too hard, right?

So the problem is this, whether we use cpu_to_mem() or cpu_to_node()
here, neither is setup yet because of the ordering between percpu setup
and the actual writing of the percpu data (that is actually storing what
node/local memory is relative to a given CPU).

The NODE_DATA is all correct, but since we are calling cpu_to_{mem,node}
before it really holds valid data, it falsely says 0, which is not
necessarily even an online node.

So, I think we need to do the same thing as x86 and have an early
mapping setup and configured before the percpu areas are.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
