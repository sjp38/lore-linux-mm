Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CCF9B6B0038
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 21:40:23 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 11so24978729pge.4
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 18:40:23 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v69si8385794pgb.404.2017.09.12.18.40.21
        for <linux-mm@kvack.org>;
        Tue, 12 Sep 2017 18:40:22 -0700 (PDT)
Date: Wed, 13 Sep 2017 10:40:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -v4 3/5] mm, swap: VMA based swap readahead
Message-ID: <20170913014019.GB29422@bbox>
References: <20170807054038.1843-1-ying.huang@intel.com>
 <20170807054038.1843-4-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170807054038.1843-4-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Mon, Aug 07, 2017 at 01:40:36PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> The swap readahead is an important mechanism to reduce the swap in
> latency.  Although pure sequential memory access pattern isn't very
> popular for anonymous memory, the space locality is still considered
> valid.
> 
> In the original swap readahead implementation, the consecutive blocks
> in swap device are readahead based on the global space locality
> estimation.  But the consecutive blocks in swap device just reflect
> the order of page reclaiming, don't necessarily reflect the access
> pattern in virtual memory.  And the different tasks in the system may
> have different access patterns, which makes the global space locality
> estimation incorrect.
> 
> In this patch, when page fault occurs, the virtual pages near the
> fault address will be readahead instead of the swap slots near the
> fault swap slot in swap device.  This avoid to readahead the unrelated
> swap slots.  At the same time, the swap readahead is changed to work
> on per-VMA from globally.  So that the different access patterns of
> the different VMAs could be distinguished, and the different readahead
> policy could be applied accordingly.  The original core readahead
> detection and scaling algorithm is reused, because it is an effect
> algorithm to detect the space locality.

Andrew,

Every zram users like low-end android device has used 0 page-cluster
to disable swap readahead because it has no seek cost and works as
synchronous IO operation so if we do readahead multiple pages,
swap falut latency would be (4K * readahead window size). IOW,
readahead is meaningful only if it doesn't bother faulted page's
latency.

However, this patch introduces additional knob /sys/kernel/mm/swap/
vma_ra_max_order as well as page-cluster. It means existing users
has used disabled swap readahead doesn't work until they should be
aware of new knob and modification of their script/code to disable
vma_ra_max_order as well as page-cluster.

I say it's a *regression* and wanted to fix it but Huang's opinion
is that it's not a functional regression so userspace should be fixed
by themselves.
Please look into detail of discussion in
http://lkml.kernel.org/r/%3C1505183833-4739-4-git-send-email-minchan@kernel.org%3E

The discussion is never productive so it's time to follow maintainer's
opinion. Could you share your opinion?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
