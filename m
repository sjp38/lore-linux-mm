Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CF1F66B0095
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 22:10:02 -0400 (EDT)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n9D29tj3030879
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 03:09:56 +0100
Received: from pzk38 (pzk38.prod.google.com [10.243.19.166])
	by spaceape14.eur.corp.google.com with ESMTP id n9D29qk4018326
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 19:09:53 -0700
Received: by pzk38 with SMTP id 38so9503360pzk.9
        for <linux-mm@kvack.org>; Mon, 12 Oct 2009 19:09:52 -0700 (PDT)
Date: Mon, 12 Oct 2009 19:09:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 7/12] hugetlb:  add per node hstate attributes
In-Reply-To: <1255362064.4344.105.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0910121906590.26949@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain> <20091008162539.23192.3642.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0910081339391.4765@chino.kir.corp.google.com> <1255096198.14370.65.camel@useless.americas.hpqcorp.net>
 <alpine.DEB.1.00.0910091511100.12760@chino.kir.corp.google.com> <1255362064.4344.105.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 12 Oct 2009, Lee Schermerhorn wrote:

> > Hmm, does this really work for memory hot-remove?  If all memory is 
> > removed from a nid, does node_hstates[nid]->hstate_objs[] get updated 
> > appropriately?  I assume we'd never pass that particular kobj to 
> > kobj_to_node_hstate() anymore, but I'm wondering if the pointer would 
> > remain in the hstate_kobjs[] table.
> 
> Patch 11 is intended to address this.  The hotplug notifier, added by
> that patch, will call hugetlb_unregister_node() in the event all memory
> is removed from a node.  hugetlb_unregister_node() NULLs out the per
> node hstate_kobjs[] after freeing them.  This patch [7/12] handles node
> hot-plug--as opposed to memory hot-plug that transitions the node
> to/from the memoryless state.
> 

Ahh, I see it done in hugetlb_register_node(), thanks.

There's probably not much of a need to unregister the attributes if all 
memory is removed, anyway, subsequent allocation attempts on its node 
should simply fail.  It looks like your patches address node hotplug well, 
thanks for the clarification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
