Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA369003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 16:27:19 -0400 (EDT)
Received: by pacan13 with SMTP id an13so1649308pac.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 13:27:18 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id dn14si14567855pac.111.2015.07.23.13.27.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 13:27:18 -0700 (PDT)
Received: by pdbbh15 with SMTP id bh15so1562449pdb.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 13:27:17 -0700 (PDT)
Date: Thu, 23 Jul 2015 13:27:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
In-Reply-To: <alpine.DEB.2.11.1507230855510.12258@east.gentwo.org>
Message-ID: <alpine.DEB.2.10.1507231322510.31024@chino.kir.corp.google.com>
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507211428160.3833@chino.kir.corp.google.com> <55AF7F64.1040602@suse.cz> <alpine.DEB.2.10.1507221445130.21468@chino.kir.corp.google.com>
 <alpine.DEB.2.11.1507230855510.12258@east.gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>

On Thu, 23 Jul 2015, Christoph Lameter wrote:

> > The only possible downside would be existing users of
> > alloc_pages_node() that are calling it with an offline node.  Since it's a
> > VM_BUG_ON() that would catch that, I think it should be changed to a
> > VM_WARN_ON() and eventually fixed up because it's nonsensical.
> > VM_BUG_ON() here should be avoided.
> 
> The offline node thing could be addresses by using numa_mem_id()?
> 

I was concerned about any callers that were passing an offline node, not 
NUMA_NO_NODE, today.  One of the alloc-node functions has a VM_BUG_ON() 
for it, the other silently calls node_zonelist() on it.

I suppose the final alloc_pages_node() implementation could be

        if (nid == NUMA_NO_NODE || VM_WARN_ON(!node_online(nid)))
                nid = numa_mem_id();

        VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
        return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));

though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
