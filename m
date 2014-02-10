Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id DD4876B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 05:05:48 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so5898932pdj.4
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 02:05:48 -0800 (PST)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id yh9si14789329pab.121.2014.02.10.02.05.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 02:05:47 -0800 (PST)
Received: by mail-pb0-f53.google.com with SMTP id md12so6035008pbc.40
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 02:05:47 -0800 (PST)
Date: Mon, 10 Feb 2014 02:05:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
In-Reply-To: <52F88C16.70204@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com>
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org> <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com> <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org>
 <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com> <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com> <52F4B8A4.70405@linux.vnet.ibm.com> <alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com>
 <52F88C16.70204@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 10 Feb 2014, Raghavendra K T wrote:

> As you rightly pointed , I 'll drop remote memory term and use
> something like  :
> 
> "* Ensure readahead success on a memoryless node cpu. But we limit
>  * the readahead to 4k pages to avoid trashing page cache." ..
> 

I don't know how to proceed here after pointing it out twice, I'm afraid.

numa_mem_id() is local memory for a memoryless node.  node_present_pages() 
has no place in your patch.

> Regarding ACCESS_ONCE, since we will have to add
> inside the function and still there is nothing that could prevent us
> getting run on different cpu with a different node (as Andrew ponted), I have
> not included in current patch that I am posting.
> Moreover this case is hopefully not fatal since it is just a hint for
> readahead we can do.
> 

I have no idea why you think the ACCESS_ONCE() is a problem.  It's relying 
on gcc's implementation to ensure that the equation is done only for one 
node.  It has absolutely nothing to do with the fact that the process may 
be moved to another cpu upon returning or even immediately after the 
calculation is done.  Is it possible that node0 has 80% of memory free and 
node1 has 80% of memory inactive?  Well, then your equation doesn't work 
quite so well if the process moves.

There is no downside whatsoever to using it, I have no idea why you think 
it's better without it.

> So there are many possible implementation:
> (1) use numa_mem_id(), apply freepage limit  and use 4k page limit for all
> case
> (Jan had reservation about this case)
> 
> (2)for normal case:    use free memory calculation and do not apply 4k
>     limit (no change).
>    for memoryless cpu case:  use numa_mem_id for more accurate
>     calculation of limit and also apply 4k limit.
> 
> (3) for normal case:   use free memory calculation and do not apply 4k
>     limit (no change).
>     for memoryless case: apply 4k page limit
> 
> (4) use numa_mem_id() and apply only free page limit..
> 
> So, I ll be resending the patch with changelog and comment changes
> based on your and Andrew's feedback (type (3) implementation).
> 

It's frustrating to have to say something three times.  Ask yourself what 
happens if ALL NODES WITH CPUS DO NOT HAVE MEMORY?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
