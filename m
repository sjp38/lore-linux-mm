Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC6E9003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:31:13 -0400 (EDT)
Received: by padck2 with SMTP id ck2so125899340pad.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 14:31:13 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id pr7si45991896pdb.236.2015.07.21.14.31.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 14:31:12 -0700 (PDT)
Received: by pdjr16 with SMTP id r16so129044622pdj.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 14:31:12 -0700 (PDT)
Date: Tue, 21 Jul 2015 14:31:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
In-Reply-To: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1507211428160.3833@chino.kir.corp.google.com>
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>

On Tue, 21 Jul 2015, Vlastimil Babka wrote:

> The function alloc_pages_exact_node() was introduced in 6484eb3e2a81 ("page
> allocator: do not check NUMA node ID when the caller knows the node is valid")
> as an optimized variant of alloc_pages_node(), that doesn't allow the node id
> to be -1. Unfortunately the name of the function can easily suggest that the
> allocation is restricted to the given node. In truth, the node is only
> preferred, unless __GFP_THISNODE is among the gfp flags.
> 
> The misleading name has lead to mistakes in the past, see 5265047ac301 ("mm,
> thp: really limit transparent hugepage allocation to local node") and
> b360edb43f8e ("mm, mempolicy: migrate_to_node should only migrate to node").
> 
> To prevent further mistakes, this patch renames the function to
> alloc_pages_prefer_node() and documents it together with alloc_pages_node().
> 

alloc_pages_exact_node(), as you said, connotates that the allocation will 
take place on that node or will fail.  So why not go beyond this patch and 
actually make alloc_pages_exact_node() set __GFP_THISNODE and then call 
into a new alloc_pages_prefer_node(), which would be the current 
alloc_pages_exact_node() implementation, and then fix up the callers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
