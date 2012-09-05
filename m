Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 886CC6B0068
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 10:23:09 -0400 (EDT)
Date: Wed, 5 Sep 2012 17:24:15 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/3] Enable clients to schedule in mmu_notifier methods
Message-ID: <20120905142415.GA10832@redhat.com>
References: <1345975899-2236-1-git-send-email-haggaie@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345975899-2236-1-git-send-email-haggaie@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>

On Wed, Sep 05, 2012 at 04:35:49PM +0300, Haggai Eran wrote:
> The following short patch series completes the support for allowing clients to
> sleep in mmu notifiers (specifically in invalidate_page and
> invalidate_range_start/end), adding on the work done by Andrea Arcangeli and
> Sagi Grimberg in http://marc.info/?l=linux-mm&m=133113297028676&w=3
> 
> This patchset is a preliminary step towards on-demand paging design to be
> added to the Infiniband stack. Our goal is to avoid pinning pages in
> memory regions registered for IB communication, so we need to get
> notifications for invalidations on such memory regions, and stop the hardware
> from continuing its access to the invalidated pages. The hardware operation
> that flushes the page tables can block, so we need to sleep until the hardware
> is guaranteed not to access these pages anymore.

Since people have been asking about the need for on demand paging in
devices: this can be useful for KVM where we sometimes want to let guest
directly (bypassing the hypervisor) control a virtual function of a PCI
device (prevented by an iommu from accessing host memory).

Currently this means host needs to pin all guest memory that *might* be used
by this virtual function which breaks setups with memory overcommit; at
the moment we can address this by means of ballooning - cooperative memory
management - but this has some obvious problems: for example, to get some
memory out of a low priority guest it needs to run so the balloon can
get inflated. By comparison on demand paging would not require
guest cooperation.

The problem is not specific to Infiniband; addressing it by on demand
paging does require hardware and host driver support though. If
Infiniband drivers happen to be the first to implement it more
power to them.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
