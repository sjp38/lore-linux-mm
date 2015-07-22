Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 375349003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:33:04 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so93873201wic.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 04:33:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si3152655wiz.1.2015.07.22.04.33.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 04:33:02 -0700 (PDT)
Message-ID: <55AF7F64.1040602@suse.cz>
Date: Wed, 22 Jul 2015 13:32:52 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507211428160.3833@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507211428160.3833@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>

On 07/21/2015 11:31 PM, David Rientjes wrote:
> On Tue, 21 Jul 2015, Vlastimil Babka wrote:
> 
>> The function alloc_pages_exact_node() was introduced in 6484eb3e2a81 ("page
>> allocator: do not check NUMA node ID when the caller knows the node is valid")
>> as an optimized variant of alloc_pages_node(), that doesn't allow the node id
>> to be -1. Unfortunately the name of the function can easily suggest that the
>> allocation is restricted to the given node. In truth, the node is only
>> preferred, unless __GFP_THISNODE is among the gfp flags.
>>
>> The misleading name has lead to mistakes in the past, see 5265047ac301 ("mm,
>> thp: really limit transparent hugepage allocation to local node") and
>> b360edb43f8e ("mm, mempolicy: migrate_to_node should only migrate to node").
>>
>> To prevent further mistakes, this patch renames the function to
>> alloc_pages_prefer_node() and documents it together with alloc_pages_node().
>>
> 
> alloc_pages_exact_node(), as you said, connotates that the allocation will
> take place on that node or will fail.  So why not go beyond this patch and
> actually make alloc_pages_exact_node() set __GFP_THISNODE and then call
> into a new alloc_pages_prefer_node(), which would be the current
> alloc_pages_exact_node() implementation, and then fix up the callers?

OK, but then we have alloc_pages_node(), alloc_pages_prefer_node() and
alloc_pages_exact_node(). Isn't that a bit too much? The first two
differ only in tiny bit:

static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
                                                unsigned int order)
{
        /* Unknown node is current node */
        if (nid < 0)
                nid = numa_node_id();

        return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
}

static inline struct page *alloc_pages_prefer_node(int nid, gfp_t gfp_mask,
                                                unsigned int order)
{
        VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));

        return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
}

So _prefer_node is just a tiny optimization over the other one. It
should be maybe called __alloc_pages_node() then? This would perhaps
discourage users outside of mm/arch code (where it may matter). The
savings of a skipped branch is likely dubious anyway... It would be also
nice if alloc_pages_node() could use __alloc_pages_node() internally, but
I'm not sure if all callers are safe wrt the
VM_BUG_ON(!node_online(nid)) part.

So when the alloc_pages_prefer_node is diminished as __alloc_pages_node
or outright removed, then maybe alloc_pages_exact_node() which adds
__GFP_THISNODE on its own, might be a useful wrapper. But I agree with
Christoph it's a duplication of the gfp_flags functionality and I don't
think there would be many users left anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
