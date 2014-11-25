Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A8D6B6B006E
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 09:17:08 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so1604579wid.0
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 06:17:08 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id d6si3305355wiz.67.2014.11.25.06.17.06
        for <linux-mm@kvack.org>;
        Tue, 25 Nov 2014 06:17:06 -0800 (PST)
Date: Tue, 25 Nov 2014 16:17:02 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm/thp: Always allocate transparent hugepages on
 local node
Message-ID: <20141125141702.GB11841@node.dhcp.inet.fi>
References: <1416838791-30023-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20141124150342.GA3889@node.dhcp.inet.fi>
 <alpine.DEB.2.10.1411241317430.21237@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1411241317430.21237@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 24, 2014 at 01:33:42PM -0800, David Rientjes wrote:
> On Mon, 24 Nov 2014, Kirill A. Shutemov wrote:
> 
> > > This make sure that we try to allocate hugepages from local node. If
> > > we can't we fallback to small page allocation based on
> > > mempolicy. This is based on the observation that allocating pages
> > > on local node is more beneficial that allocating hugepages on remote node.
> > 
> > Local node on allocation is not necessary local node for use.
> > If policy says to use a specific node[s], we should follow.
> > 
> 
> True, and the interaction between thp and mempolicies is fragile: if a 
> process has a MPOL_BIND mempolicy over a set of nodes, that does not 
> necessarily mean that we want to allocate thp remotely if it will always 
> be accessed remotely.  It's simple to benchmark and show that remote 
> access latency of a hugepage can exceed that of local pages.  MPOL_BIND 
> itself is a policy of exclusion, not inclusion, and it's difficult to 
> define when local pages and its cost of allocation is better than remote 
> thp.
> 
> For MPOL_BIND, if the local node is allowed then thp should be forced from 
> that node, if the local node is disallowed then allocate from any node in 
> the nodemask.  For MPOL_INTERLEAVE, I think we should only allocate thp 
> from the next node in order, otherwise fail the allocation and fallback to 
> small pages.  Is this what you meant as well?

Correct.

> > I think it makes sense to force local allocation if policy is interleave
> > or if current node is in preferred or bind set.
> >  
> 
> If local allocation were forced for MPOL_INTERLEAVE and all memory is 
> initially faulted by cpus on a single node, then the policy has 
> effectively become MPOL_DEFAULT, there's no interleave.

You're right. I don't have much experience with mempolicy code.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
