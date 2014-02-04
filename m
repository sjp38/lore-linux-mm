Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5A70B6B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 15:39:37 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id f11so13101331qae.7
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 12:39:37 -0800 (PST)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id 8si1460299qak.146.2014.02.04.12.39.35
        for <linux-mm@kvack.org>;
        Tue, 04 Feb 2014 12:39:36 -0800 (PST)
Date: Tue, 4 Feb 2014 14:39:32 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <20140204072630.GB10101@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1402041436150.11222@nuc>
References: <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com> <20140124232902.GB30361@linux.vnet.ibm.com> <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com> <20140125001643.GA25344@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com> <20140125011041.GB25344@linux.vnet.ibm.com> <20140127055805.GA2471@lge.com> <20140128182947.GA1591@linux.vnet.ibm.com> <20140203230026.GA15383@linux.vnet.ibm.com> <alpine.DEB.2.10.1402032138070.17997@nuc>
 <20140204072630.GB10101@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Mon, 3 Feb 2014, Nishanth Aravamudan wrote:

> Yes, sorry for my lack of clarity. I meant Joonsoo's latest patch for
> the $SUBJECT issue.

Hmmm... I am not sure that this is a general solution. The fallback to
other nodes can not only occur because a node has no memory as his patch
assumes.

If the target node allocation fails (for whatever reason) then I would
recommend for simplicities sake to change the target node to NUMA_NO_NODE
and just take whatever is in the current cpu slab. A more complex solution
would be to look through partial lists in increasing distance to find a
partially used slab that is reasonable close to the current node. Slab has
logic like that in fallback_alloc(). Slubs get_any_partial() function does
something close to what you want.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
