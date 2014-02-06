Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id C48476B0036
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 21:09:19 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id w8so1843874qac.8
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 18:09:19 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id r6si9687537qcl.98.2014.02.05.18.09.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 18:09:19 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 5 Feb 2014 19:09:18 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 16EC51FF003F
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 19:09:16 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1629BDr11141488
	for <linux-mm@kvack.org>; Thu, 6 Feb 2014 03:09:16 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1628tSc029136
	for <linux-mm@kvack.org>; Wed, 5 Feb 2014 19:08:55 -0700
Date: Wed, 5 Feb 2014 18:08:33 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140206020833.GD5433@linux.vnet.ibm.com>
References: <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com>
 <20140125011041.GB25344@linux.vnet.ibm.com>
 <20140127055805.GA2471@lge.com>
 <20140128182947.GA1591@linux.vnet.ibm.com>
 <20140203230026.GA15383@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402032138070.17997@nuc>
 <20140204072630.GB10101@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402041436150.11222@nuc>
 <20140205001352.GC10101@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402051312430.21661@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402051312430.21661@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, mpm@selenic.com, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 05.02.2014 [13:28:03 -0600], Christoph Lameter wrote:
> On Tue, 4 Feb 2014, Nishanth Aravamudan wrote:
> 
> > > If the target node allocation fails (for whatever reason) then I would
> > > recommend for simplicities sake to change the target node to
> > > NUMA_NO_NODE and just take whatever is in the current cpu slab. A more
> > > complex solution would be to look through partial lists in increasing
> > > distance to find a partially used slab that is reasonable close to the
> > > current node. Slab has logic like that in fallback_alloc(). Slubs
> > > get_any_partial() function does something close to what you want.
> >
> > I apologize for my own ignorance, but I'm having trouble following.
> > Anton's original patch did fallback to the current cpu slab, but I'm not
> > sure any NUMA_NO_NODE change is necessary there. At the point we're
> > deactivating the slab (in the current code, in __slab_alloc()), we have
> > successfully allocated from somewhere, it's just not on the node we
> > expected to be on.
> 
> Right so if we are ignoring the node then the simplest thing to do is to
> not deactivate the current cpu slab but to take an object from it.

Ok, that's what Anton's patch does, I believe. Are you ok with that
patch as it is?

> > So perhaps you are saying to make a change lower in the code? I'm not
> > sure where it makes sense to change the target node in that case. I'd
> > appreciate any guidance you can give.
> 
> This not an easy thing to do. If the current slab is not the right node
> but would be the node from which the page allocator would be returning
> memory then the current slab can still be allocated from. If the fallback
> is to another node then the current cpu slab needs to be deactivated and
> the allocation from that node needs to proceeed. Have a look at
> fallback_alloc() in the slab allocator.
> 
> A allocation attempt from the page allocator can be restricted to a
> specific node through GFP_THIS_NODE.

Thanks for the pointers, I will try and take a look.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
