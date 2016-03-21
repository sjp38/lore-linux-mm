Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 219576B0253
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 06:08:39 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id n5so259392653pfn.2
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 03:08:39 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s16si19855890pfi.193.2016.03.21.03.08.37
        for <linux-mm@kvack.org>;
        Mon, 21 Mar 2016 03:08:37 -0700 (PDT)
Date: Mon, 21 Mar 2016 10:08:18 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: Delete flush cache all in arm64 platform.
Message-ID: <20160321100818.GA17326@leverpostej>
References: <56EFABD3.7060700@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56EFABD3.7060700@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: catalin.marinas@arm.com, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, labbott@redhat.com, xuyiping@hisilicon.com, suzhuangluan@hisilicon.com, saberlily.xia@hisilicon.com, dan.zhao@hisilicon.com, linux-arm-kernel@lists.infradead.org

[adding LAKML]

On Mon, Mar 21, 2016 at 04:07:47PM +0800, Chen Feng wrote:
> Hi Mark,

Hi,

> With 68234df4ea7939f98431aa81113fbdce10c4a84b
> arm64: kill flush_cache_all()
> The documented semantics of flush_cache_all are not possible to provide
> for arm64 (short of flushing the entire physical address space by VA),
> and there are currently no users; KVM uses VA maintenance exclusively,
> cpu_reset is never called, and the only two users outside of arch code
> cannot be built for arm64.
> 
> While cpu_soft_reset and related functions (which call flush_cache_all)
> were thought to be useful for kexec, their current implementations only
> serve to mask bugs. For correctness kexec will need to perform
> maintenance by VA anyway to account for system caches, line migration,
> and other subtleties of the cache architecture. As the extent of this
> cache maintenance will be kexec-specific, it should probably live in the
> kexec code.
> 
> This patch removes flush_cache_all, and related unused components,
> preventing further abuse.
> 
> 
> This patch delete the flush_cache_all interface.

As the patch states, it does so because the documented semantics are
impossible to provide, as there is no portable mechanism to "flush" all
caches in the system.

Set/Way operations cannot guarantee that data has been cleaned to the
PoC (i.e. memory), or invalidated from all levels of cache. Reasons
include:

* They may race against background behaviour of the CPU (e.g.
  speculation), which may allocate/evict/migrate lines. Depending on the
  cache topology, this may "hide" lines from subsequent Set/Way
  operations.

* They are not broadcast, and do not affect other CPUs. Depending on the
  implemented cache coherency protocols, other CPUs may be able to
  acquire dirty lines, or retain lines in shared states, and hence these
  may not be operated on.

* They do not affect system caches (which respect cache maintenance by
  VA in ARMv8-A).

The only portable mechanism to perform cache maintenance to all relevant
caches is by VA.

> But if we use VA to flush cache to do cache-coherency with other
> master(eg:gpu)
> 
> We must iterate over the sg-list to flush by va to pa.
> 
> In this way, the iterate of sg-list may cost too much time(sg-table to
> sg-list) if the sglist is too long. Take a look at the
> ion_pages_sync_for_device in ion.
> 
> The driver(eg: ION) need to use this interface(flush cache all) to
> *improve the efficiency*.

As above, we cannot use Set/Way operations for this, and cannot provide
a flush_cache_all interface.

I'm not sure what to suggest regarding improving efficiency.

Is walking the sglist the expensive portion, or is the problem the cost
of multiple page-size operations (each with their own barriers)?

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
