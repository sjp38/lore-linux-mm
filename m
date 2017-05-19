Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA94A831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 06:40:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v4so14274193wmb.8
        for <linux-mm@kvack.org>; Fri, 19 May 2017 03:40:09 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id u104si2499246wrb.59.2017.05.19.03.40.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 03:40:08 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [RFC v3]mm: ro protection for data allocated dynamically 
Date: Fri, 19 May 2017 13:38:10 +0300
Message-ID: <20170519103811.2183-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, dave.hansen@intel.com, labbott@redhat.com
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, Igor Stoppa <igor.stoppa@huawei.com>

Not all the data allocated dynamically needs to be altered frequently.
In some cases, it might be written just once, at initialization.

This RFC has the goal of improving memory integrity, by explicitly
making said data write-protected.

A reference implementation is provided.

During the previous 2 rounds, some concerns/questions were risen.
This iteration should address msot of them, if not all.

Basic idea behind the implementation: on systems with MMU, the MMU
supports associating various types of attribute to memory pages.

One of them is being read-only.
The MMU will cause an exception upon attempts to alter a read-only page.
This mechanism is already in use for protecting: kernel text and
constant data.
Relatively recently, it has become possible to have also statically
allocated data to become read-only, with the __ro_after_init annotation.

However nothing is done for variables allocated dynamically.

The catch for re-using the same mechanism, is that soon-to-be read only
variables must be grouped in dedicated memory pages, without any rw data
falling in the same range.

This can be achieved with a dedicated allocator.

The implementation proposed allows to create memory pools.
Each pool can be treated independently from the others, allowing fine
grained control about what data can be overwritten.

A pool is a kernel linked list, where the head contains a mutex used for
accessing the list, and the elements are nodes, providing the memory
actually used.

When a pool receives an allocation request for which it doesn't have
enough memory already available, it obtains a set of contiguous virtual
pages (node) that is large enough to cover the request being processed.
Such memory is likely to be significantly larger than what was required.
The slack is used for fulfilling further allocation requests, provided
that they fit the space available.

The pool ends up being a list of nodes, where each node contains a
request that, at the time it was received, could not be satisfied by
using the exisitng nodes, plus other requests that happened to fit in the
slack. Such requests handle each node as an individual linear pool.

When it's time to seal/unseal a pool, each element (node) of the list is
visited and the range of pages it comprises is passed ot set_memory_ro/rw.

Freeing memory is supported at pool level: if for some reason one or more
memory requests must be discarded, at some point, they are simply ignored.
Upon the pool tear down, then nodes are removed one by one and the
corresponding memory range freed for good with vfree.

This approach avoids the extra coplexity of tracking individual
allocations, yet it allows to control claim back pages when not needed
anymore (i.e. module unloading.)

The same design also supports isolation between different kernel modules:
each module can allocae one or more pools, to obtain the desired level of
granularity when managing portions of its data that need different handling.

The price for this flexibility is that some more slack is produced.
The exact amount depends on the sizes of allocations performed and in
which order they arrive.

Modules that do not want/need all of this flexibility can use the default
global pool provided by the allocator.

This pool is intended to provide consistency with __ro_after_init and
therefore would be sealed at the same time.

Some observations/questions:

* the backend of the memory allocation is done by using vmalloc.
  Is here any better way? the bpf uses module_alloc but that seems not
  exactly its purpose.

* because of the vmalloc backend, this is not suitable for cases where
  it is really needed to have physically contiguous memory regions,
  however the type of data that would use this interface is likely to
  not require interaction with HW devices that could rise such need.

* the allocator supports defining a preferred alignment (currently set
  to 8 bytes, using uint64_t) - is it useful/desirable?
  If yes, is it the correct granularity (global)?

* to get the size of the padded header of a node, the current code uses
  __align(align_t) and it seems to work, but is it correct?

* examples of uses for this new allcoator:
  - LSM Hooks
  - policy database of SE Linux (several different structure types)

Igor Stoppa (1):
  Sealable memory support

 mm/Makefile  |   2 +-
 mm/smalloc.c | 200 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/smalloc.h |  61 ++++++++++++++++++
 3 files changed, 262 insertions(+), 1 deletion(-)
 create mode 100644 mm/smalloc.c
 create mode 100644 mm/smalloc.h

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
