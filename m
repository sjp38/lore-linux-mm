Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 1F0446B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 14:53:08 -0400 (EDT)
Date: Tue, 16 Oct 2012 18:53:06 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Q] Default SLAB allocator
In-Reply-To: <alpine.DEB.2.00.1210151743130.31712@chino.kir.corp.google.com>
Message-ID: <0000013a6aec10e3-304d4336-6d62-4b0f-9d06-e2ca4c6d8dcf-000000@email.amazonses.com>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com> <m27gqwtyu9.fsf@firstfloor.org> <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com> <m2391ktxjj.fsf@firstfloor.org> <alpine.DEB.2.00.1210130249070.7462@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210151743130.31712@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Ezequiel Garcia <elezegarcia@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

On Mon, 15 Oct 2012, David Rientjes wrote:

> This type of workload that really exhibits the problem with remote freeing
> would suggest that the design of slub itself is the problem here.

There is a tradeoff here between spatial data locality and temporal
locality. Slub always frees to the queue associated with the slab page
that the object originated from and therefore restores spatial data
locality. It will always serve all objects available in a slab page
before moving onto the next. Within a slab page it can consider temporal
locality.

Slab considers temporal locatlity more important and will not return
objects to the originating slab pages until they are no longer in use. It
(ideally) will serve objects in the order they were freed. This breaks
down in the NUMA case and the allocator got into a pretty bizarre queueing
configuration (with lots and lots of queues) as a result of our attempt to
preverse the free/alloc order per NUMA node (look at the alien caches
f.e.). Slub is an alternative to that approach.

Slab also has the problem of queue handling overhead due to the attempt to
throw objects out of the queues that are likely no more cache hot. Every
few seconds it needs to run queue cleaning through all queues that exists
on the system. How accurate it tracks the actual cache hotness of objects
is not clear.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
