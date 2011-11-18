Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C28D66B0069
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 19:00:22 -0500 (EST)
Date: Thu, 17 Nov 2011 16:00:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v2 for-3.2-rc3] cpusets: stall when updating
 mems_allowed for mempolicy or disjoint nodemask
Message-Id: <20111117160019.c8bd45ba.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1111171507340.9933@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1111161307020.23629@chino.kir.corp.google.com>
	<20111117142213.2b34469d.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1111171507340.9933@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Paul Menage <paul@paulmenage.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 17 Nov 2011 15:08:08 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> cpusets: stall when updating mems_allowed for mempolicy or disjoint nodemask
> 
> c0ff7453bb5c ("cpuset,mm: fix no node to alloc memory when changing
> cpuset's mems") adds get_mems_allowed() to prevent the set of allowed
> nodes from changing for a thread.  This causes any update to a set of
> allowed nodes to stall until put_mems_allowed() is called.
> 
> This stall is unncessary, however, if at least one node remains unchanged
> in the update to the set of allowed nodes.  This was addressed by
> 89e8a244b97e ("cpusets: avoid looping when storing to mems_allowed if one
> node remains set"), but it's still possible that an empty nodemask may be
> read from a mempolicy because the old nodemask may be remapped to the new
> nodemask during rebind.  To prevent this, only avoid the stall if there
> is no mempolicy for the thread being changed.
> 
> This is a temporary solution until all reads from mempolicy nodemasks can
> be guaranteed to not be empty without the get_mems_allowed()
> synchronization.
> 
> Also moves the check for nodemask intersection inside task_lock() so that
> tsk->mems_allowed cannot change.  This ensures that nothing can set this
> tsk's mems_allowed out from under us and also protects tsk->mempolicy.

Nothing in this changelog makes me understand why you think we need this
change in 3.2.  What are the user-visible effects of this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
