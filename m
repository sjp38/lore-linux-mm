Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 63D9D6B0038
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 16:33:46 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hn15so3930050igb.1
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:33:46 -0800 (PST)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com. [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id ve8si42258igb.8.2014.11.24.13.33.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 13:33:45 -0800 (PST)
Received: by mail-ie0-f175.google.com with SMTP id at20so9824344iec.34
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:33:45 -0800 (PST)
Date: Mon, 24 Nov 2014 13:33:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm/thp: Always allocate transparent hugepages on
 local node
In-Reply-To: <20141124150342.GA3889@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.10.1411241317430.21237@chino.kir.corp.google.com>
References: <1416838791-30023-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20141124150342.GA3889@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 24 Nov 2014, Kirill A. Shutemov wrote:

> > This make sure that we try to allocate hugepages from local node. If
> > we can't we fallback to small page allocation based on
> > mempolicy. This is based on the observation that allocating pages
> > on local node is more beneficial that allocating hugepages on remote node.
> 
> Local node on allocation is not necessary local node for use.
> If policy says to use a specific node[s], we should follow.
> 

True, and the interaction between thp and mempolicies is fragile: if a 
process has a MPOL_BIND mempolicy over a set of nodes, that does not 
necessarily mean that we want to allocate thp remotely if it will always 
be accessed remotely.  It's simple to benchmark and show that remote 
access latency of a hugepage can exceed that of local pages.  MPOL_BIND 
itself is a policy of exclusion, not inclusion, and it's difficult to 
define when local pages and its cost of allocation is better than remote 
thp.

For MPOL_BIND, if the local node is allowed then thp should be forced from 
that node, if the local node is disallowed then allocate from any node in 
the nodemask.  For MPOL_INTERLEAVE, I think we should only allocate thp 
from the next node in order, otherwise fail the allocation and fallback to 
small pages.  Is this what you meant as well?

> I think it makes sense to force local allocation if policy is interleave
> or if current node is in preferred or bind set.
>  

If local allocation were forced for MPOL_INTERLEAVE and all memory is 
initially faulted by cpus on a single node, then the policy has 
effectively become MPOL_DEFAULT, there's no interleave.

Aside: the patch is also buggy since it passes numa_node_id() and thp is 
supported on platforms that allow memoryless nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
