Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8F09003C7
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:34:04 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so29794810wic.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:34:03 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gl4si3066550wjb.197.2015.07.30.10.34.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 10:34:02 -0700 (PDT)
Date: Thu, 30 Jul 2015 13:33:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 1/3] mm: rename alloc_pages_exact_node to
 __alloc_pages_node
Message-ID: <20150730173318.GA15257@cmpxchg.org>
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438274071-22551-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Michael Ellerman <mpe@ellerman.id.au>, Robin Holt <robinmholt@gmail.com>

On Thu, Jul 30, 2015 at 06:34:29PM +0200, Vlastimil Babka wrote:
> The function alloc_pages_exact_node() was introduced in 6484eb3e2a81 ("page
> allocator: do not check NUMA node ID when the caller knows the node is valid")
> as an optimized variant of alloc_pages_node(), that doesn't fallback to current
> node for nid == NUMA_NO_NODE. Unfortunately the name of the function can easily
> suggest that the allocation is restricted to the given node and fails
> otherwise. In truth, the node is only preferred, unless __GFP_THISNODE is
> passed among the gfp flags.
> 
> The misleading name has lead to mistakes in the past, see 5265047ac301 ("mm,
> thp: really limit transparent hugepage allocation to local node") and
> b360edb43f8e ("mm, mempolicy: migrate_to_node should only migrate to node").
> 
> Another issue with the name is that there's a family of alloc_pages_exact*()
> functions where 'exact' means exact size (instead of page order), which leads
> to more confusion.
> 
> To prevent further mistakes, this patch effectively renames
> alloc_pages_exact_node() to __alloc_pages_node() to better convey that it's
> an optimized variant of alloc_pages_node() not intended for general usage.
> Both functions get described in comments.
> 
> It has been also considered to really provide a convenience function for
> allocations restricted to a node, but the major opinion seems to be that
> __GFP_THISNODE already provides that functionality and we shouldn't duplicate
> the API needlessly. The number of users would be small anyway.
> 
> Existing callers of alloc_pages_exact_node() are simply converted to call
> __alloc_pages_node(), with two exceptions. sba_alloc_coherent() and
> slob_new_page() both open-code the check for NUMA_NO_NODE, so they are
> converted to use alloc_pages_node() instead. This means they no longer perform
> some VM_BUG_ON checks, and since the current check for nid in
> alloc_pages_node() uses a 'nid < 0' comparison (which includes NUMA_NO_NODE),
> it may hide wrong values which would be previously exposed. Both differences
> will be rectified by the next patch.
> 
> To sum up, this patch makes no functional changes, except temporarily hiding
> potentially buggy callers. Restricting the checks in alloc_pages_node() is
> left for the next patch which can in turn expose more existing buggy callers.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Acked-by: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Gleb Natapov <gleb@kernel.org>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Cliff Whickman <cpw@sgi.com>
> Acked-by: Robin Holt <robinmholt@gmail.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
