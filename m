Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 621A96B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:58:21 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so2363461pde.6
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:58:21 -0800 (PST)
Received: from mail-pb0-x229.google.com (mail-pb0-x229.google.com [2607:f8b0:400e:c01::229])
        by mx.google.com with ESMTPS id if4si2789735pbc.16.2014.02.06.15.58.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 15:58:19 -0800 (PST)
Received: by mail-pb0-f41.google.com with SMTP id up15so2461521pbc.28
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:58:19 -0800 (PST)
Date: Thu, 6 Feb 2014 15:58:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
In-Reply-To: <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com>
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org> <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com> <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org>
 <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 6 Feb 2014, David Rientjes wrote:

> > > > > +#define MAX_REMOTE_READAHEAD   4096UL

> Normally it wouldn't matter because there's no significant downside to it 
> racing, things like mempolicies which use numa_node_id() extensively would 
> result in, oops, a page allocation on the wrong node.
> 
> This stands out to me, though, because you're expecting the calculation to 
> be correct for a specific node.
> 
> The patch is still wrong, though, it should just do
> 
> 	int node = ACCESS_ONCE(numa_mem_id());
> 	return min(nr, (node_page_state(node, NR_INACTIVE_FILE) +
> 		        node_page_state(node, NR_FREE_PAGES)) / 2);
> 
> since we want to readahead based on the cpu's local node, the comment 
> saying we're reading ahead onto "remote memory" is wrong since a 
> memoryless node has local affinity to numa_mem_id().
> 

Oops, forgot about the MAX_REMOTE_READAHEAD which needs to be factored in 
as well, but this handles the bound on local node's statistics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
