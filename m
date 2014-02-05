Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1317B6B0037
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 14:28:07 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id uy17so4163228igb.3
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 11:28:06 -0800 (PST)
Received: from qmta10.westchester.pa.mail.comcast.net (qmta10.westchester.pa.mail.comcast.net. [2001:558:fe14:43:76:96:62:17])
        by mx.google.com with ESMTP id i4si30077694pad.199.2014.02.05.11.28.04
        for <linux-mm@kvack.org>;
        Wed, 05 Feb 2014 11:28:05 -0800 (PST)
Date: Wed, 5 Feb 2014 13:28:03 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <20140205001352.GC10101@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1402051312430.21661@nuc>
References: <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com> <20140125001643.GA25344@linux.vnet.ibm.com> <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com> <20140125011041.GB25344@linux.vnet.ibm.com> <20140127055805.GA2471@lge.com>
 <20140128182947.GA1591@linux.vnet.ibm.com> <20140203230026.GA15383@linux.vnet.ibm.com> <alpine.DEB.2.10.1402032138070.17997@nuc> <20140204072630.GB10101@linux.vnet.ibm.com> <alpine.DEB.2.10.1402041436150.11222@nuc>
 <20140205001352.GC10101@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, mpm@selenic.com, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Tue, 4 Feb 2014, Nishanth Aravamudan wrote:

> > If the target node allocation fails (for whatever reason) then I would
> > recommend for simplicities sake to change the target node to
> > NUMA_NO_NODE and just take whatever is in the current cpu slab. A more
> > complex solution would be to look through partial lists in increasing
> > distance to find a partially used slab that is reasonable close to the
> > current node. Slab has logic like that in fallback_alloc(). Slubs
> > get_any_partial() function does something close to what you want.
>
> I apologize for my own ignorance, but I'm having trouble following.
> Anton's original patch did fallback to the current cpu slab, but I'm not
> sure any NUMA_NO_NODE change is necessary there. At the point we're
> deactivating the slab (in the current code, in __slab_alloc()), we have
> successfully allocated from somewhere, it's just not on the node we
> expected to be on.

Right so if we are ignoring the node then the simplest thing to do is to
not deactivate the current cpu slab but to take an object from it.

> So perhaps you are saying to make a change lower in the code? I'm not
> sure where it makes sense to change the target node in that case. I'd
> appreciate any guidance you can give.

This not an easy thing to do. If the current slab is not the right node
but would be the node from which the page allocator would be returning
memory then the current slab can still be allocated from. If the fallback
is to another node then the current cpu slab needs to be deactivated and
the allocation from that node needs to proceeed. Have a look at
fallback_alloc() in the slab allocator.

A allocation attempt from the page allocator can be restricted to a
specific node through GFP_THIS_NODE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
