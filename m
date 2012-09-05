Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 6F2AF6B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 10:06:50 -0400 (EDT)
Message-ID: <50475B40.1060407@mellanox.com>
Date: Wed, 5 Sep 2012 17:01:36 +0300
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH V1 0/2] Enable clients to schedule in mmu_notifier methods
References: <1346748081-1652-1-git-send-email-haggaie@mellanox.com> <20120904150615.f6c1a618.akpm@linux-foundation.org>
In-Reply-To: <20120904150615.f6c1a618.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Shachar Raindel <raindel@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>

On 05/09/2012 01:06, Andrew Morton wrote:
> Exactly why do we want on-demand paging for Infiniband?  

Applications register memory with an RDMA adapter using system calls,
and subsequently post IO operations that refer to the corresponding
virtual addresses directly to HW. Until now, this was achieved by
pinning the memory during the registration calls. The goal of on demand
paging is to avoid pinning the pages of registered memory regions (MRs).
This will allow users the same flexibility they get when swapping any
other part of their processes address spaces. Instead of requiring the
entire MR to fit in physical memory, we can allow the MR to be larger,
and only fit the current working set in physical memory.

> Why should anyone care?  What problems are users currently experiencing?

This can make programming with RDMA much simpler. Today, developers that
are working with more data than their RAM can hold need either to
deregister and reregister memory regions throughout their process's
life, or keep a single memory region and copy the data to it. On demand
paging will allow these developers to register a single MR at the
beginning of their process's life, and let the operating system manage
which pages needs to be fetched at a given time. In the future, we might
be able to provide a single memory access key for each process that
would provide the entire process's address as one large memory region,
and the developers wouldn't need to register memory regions at all.

> Is there any prospect that any other subsystems will utilise these
> infrastructural changes?  If so, which and how, etc?

As for other subsystems, I understand that XPMEM wanted to sleep in MMU
notifiers, as Christoph Lameter wrote at
http://lkml.indiana.edu/hypermail/linux/kernel/0802.1/0460.html
and perhaps Andrea knows about other use cases.

Scheduling in mmu notifications is required since we need to sync the
hardware with the secondary page tables change. A TLB flush of an IO
device is inherently slower than a CPU TLB flush, so our design works by
sending the invalidation request to the device, and waiting for an
interrupt before exiting the mmu notifier handler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
