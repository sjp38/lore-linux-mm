Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9662F6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 15:56:22 -0500 (EST)
Subject: Re: Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu counter instead
From: Andi Kleen <andi@firstfloor.org>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1>
	<alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1>
Date: Thu, 05 Nov 2009 21:56:18 +0100
In-Reply-To: <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1> (Christoph Lameter's message of "Thu, 5 Nov 2009 14:20:47 -0500 (EST)")
Message-ID: <87r5sc7kst.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Christoph Lameter <cl@linux-foundation.org> writes:

> Instead of a rw semaphore use a mutex and a per cpu counter for the number
> of the current readers. read locking then becomes very cheap requiring only
> the increment of a per cpu counter.
>
> Write locking is more expensive since the writer must scan the percpu array
> and wait until all readers are complete. Since the readers are not holding
> semaphores we have no wait queue from which the writer could wakeup. In this
> draft we simply wait for one millisecond between scans of the percpu
> array. A different solution must be found there.

I'm not sure making all writers more expensive is really a good idea.

For example it will definitely impact the AIM7 multi brk() issue
or the mysql allocation case, which are all writer intensive. I assume
doing a lot of mmaps/brks in parallel is not that uncommon.

My thinking was more that we simply need per VMA locking or
some other per larger address range locking. Unfortunately that
needs changes in a lot of users that mess with the VMA lists
(perhaps really needs some better abstractions for VMA list management
first)

That said also addressing the convoying issues in the current
semaphores would be a good idea, which is what your patch does.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
