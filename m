Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id A07E96B0118
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 14:54:39 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id j5so16141326qga.4
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 11:54:39 -0800 (PST)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id x6si6386901qas.90.2014.02.24.11.54.38
        for <linux-mm@kvack.org>;
        Mon, 24 Feb 2014 11:54:39 -0800 (PST)
Date: Mon, 24 Feb 2014 13:54:35 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <20140224050851.GB14814@lge.com>
Message-ID: <alpine.DEB.2.10.1402241353070.20839@nuc>
References: <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com> <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com> <20140207054819.GC28952@lge.com> <alpine.DEB.2.10.1402071150090.15168@nuc> <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140210191321.GD1558@linux.vnet.ibm.com> <20140211074159.GB27870@lge.com> <alpine.DEB.2.10.1402121612270.8183@nuc> <20140217065257.GD3468@lge.com> <alpine.DEB.2.10.1402181033480.28964@nuc> <20140224050851.GB14814@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Mon, 24 Feb 2014, Joonsoo Kim wrote:

> > It will not common get there because of the tracking. Instead a per cpu
> > object will be used.
> > > get_partial_node() always fails even if there are some partial slab on
> > > memoryless node's neareast node.
> >
> > Correct and that leads to a page allocator action whereupon the node will
> > be marked as empty.
>
> Why do we need to request to a page allocator if there is partial slab?
> Checking whether node is memoryless or not is really easy, so we don't need
> to skip this. To skip this is suboptimal solution.

The page allocator action is also used to determine to which other node we
should fall back if the node is empty. So we need to call the page
allocator when the per cpu slab is exhaused with the node of the
memoryless node to get memory from the proper fallback node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
