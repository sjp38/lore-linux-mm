Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D52C06B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 18:09:42 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id z128so7380040pfb.4
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 15:09:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p5si7131547pgn.170.2017.01.11.15.09.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 15:09:42 -0800 (PST)
Date: Wed, 11 Jan 2017 15:09:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 3/9] mm/swap: Split swap cache into 64MB trunks
Message-Id: <20170111150940.25d951a121a62e1b7eff6f8d@linux-foundation.org>
In-Reply-To: <735bab895e64c930581ffb0a05b661e01da82bc5.1484082593.git.tim.c.chen@linux.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
	<735bab895e64c930581ffb0a05b661e01da82bc5.1484082593.git.tim.c.chen@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Wed, 11 Jan 2017 09:55:13 -0800 Tim Chen <tim.c.chen@linux.intel.com> wrote:

> The patch is to improve the scalability of the swap out/in via using
> fine grained locks for the swap cache.  In current kernel, one address
> space will be used for each swap device.  And in the common
> configuration, the number of the swap device is very small (one is
> typical).  This causes the heavy lock contention on the radix tree of
> the address space if multiple tasks swap out/in concurrently.  But in
> fact, there is no dependency between pages in the swap cache.  So that,
> we can split the one shared address space for each swap device into
> several address spaces to reduce the lock contention.  In the patch, the
> shared address space is split into 64MB trunks.  64MB is chosen to
> balance the memory space usage and effect of lock contention reduction.
> 
> The size of struct address_space on x86_64 architecture is 408B, so with
> the patch, 6528B more memory will be used for every 1GB swap space on
> x86_64 architecture.
> 
> One address space is still shared for the swap entries in the same 64M
> trunks.  To avoid lock contention for the first round of swap space
> allocation, the order of the swap clusters in the initial free clusters
> list is changed.  The swap space distance between the consecutive swap
> clusters in the free cluster list is at least 64M.  After the first
> round of allocation, the swap clusters are expected to be freed
> randomly, so the lock contention should be reduced effectively.

Switching from a single radix-tree to an array of radix-trees to reduce
contention seems a bit hacky.  That we can do this and have everything
continue to work tells me that we're simply using an inappropriate data
structure to hold this info.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
