Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB676B00AC
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 01:25:51 -0500 (EST)
Received: by ywm14 with SMTP id 14so184418ywm.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 22:25:49 -0800 (PST)
Date: Tue, 22 Nov 2011 22:25:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.2-rc3] cpusets: stall when updating mems_allowed
 for mempolicy or disjoint nodemask
In-Reply-To: <4ECC7B1E.6020108@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1111222210341.21009@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1111161307020.23629@chino.kir.corp.google.com> <4EC4C603.8050704@cn.fujitsu.com> <alpine.DEB.2.00.1111171328120.15918@chino.kir.corp.google.com> <4EC62AEA.2030602@cn.fujitsu.com> <alpine.DEB.2.00.1111181545170.24487@chino.kir.corp.google.com>
 <4ECC5FC8.9070500@cn.fujitsu.com> <alpine.DEB.2.00.1111221902300.30008@chino.kir.corp.google.com> <4ECC7B1E.6020108@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Paul Menage <paul@paulmenage.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 23 Nov 2011, Miao Xie wrote:

> This is a good idea. But I worry that oom will happen easily, because we do
> direct reclamation and compact by mems_allowed.
> 

Memory compaction actually iterates through each zone regardless of 
whether it's allowed or not in the current context.  Recall that the 
nodemask passed into __alloc_pages_nodemask() is non-NULL only when there 
is a mempolicy that restricts the allocations by MPOL_BIND.  That nodemask 
is not protected by get_mems_allowed(), so there's no change in 
compaction's behavior with my patch.

Direct reclaim does, however, require mems_allowed staying constant 
without the risk of early oom as you mentioned.  It has its own 
get_mems_allowed(), though, so it doesn't have the opportunity to change 
until returning to the page allocator.  It's possible that mems_allowed 
will be different on the next call to get_pages_from_freelist() but we 
don't know anything about that context: it's entirely possible that the 
set of new mems has an abundance of free memory or are completely depleted 
as well.  So there's no strict need for consistency between the set of 
allowed nodes during reclaim and the subsequent allocation attempt.  All 
we care about is that reclaim has a consistent set of allowed nodes to 
determine whether it's making progress or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
