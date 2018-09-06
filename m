Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6AFF86B78D7
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:50:56 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r131-v6so12761727oie.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:50:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g8-v6si3663848oic.418.2018.09.06.05.50.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 05:50:55 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w86Cmw9e043943
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 08:50:55 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mb3t12dwh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 08:50:54 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 6 Sep 2018 13:50:51 +0100
Date: Thu, 6 Sep 2018 15:50:42 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 16/29] memblock: replace __alloc_bootmem_node with
 appropriate memblock_ API
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-17-git-send-email-rppt@linux.vnet.ibm.com>
 <20180906083841.GA14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906083841.GA14951@dhcp22.suse.cz>
Message-Id: <20180906125041.GG27492@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 06, 2018 at 10:38:41AM +0200, Michal Hocko wrote:
> On Wed 05-09-18 18:59:31, Mike Rapoport wrote:
> > Use memblock_alloc_try_nid whenever goal (i.e. mininal address is
> > specified) and memblock_alloc_node otherwise.
> 
> I suspect you wanted to say (i.e. minimal address) is specified

Yep
 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> One note below
> 
> > ---
> >  arch/ia64/mm/discontig.c       |  6 ++++--
> >  arch/ia64/mm/init.c            |  2 +-
> >  arch/powerpc/kernel/setup_64.c |  6 ++++--
> >  arch/sparc/kernel/setup_64.c   | 10 ++++------
> >  arch/sparc/kernel/smp_64.c     |  4 ++--
> >  5 files changed, 15 insertions(+), 13 deletions(-)
> > 
> > diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
> > index 1928d57..918dda9 100644
> > --- a/arch/ia64/mm/discontig.c
> > +++ b/arch/ia64/mm/discontig.c
> > @@ -451,8 +451,10 @@ static void __init *memory_less_node_alloc(int nid, unsigned long pernodesize)
> >  	if (bestnode == -1)
> >  		bestnode = anynode;
> >  
> > -	ptr = __alloc_bootmem_node(pgdat_list[bestnode], pernodesize,
> > -		PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
> > +	ptr = memblock_alloc_try_nid(pernodesize, PERCPU_PAGE_SIZE,
> > +				     __pa(MAX_DMA_ADDRESS),
> > +				     BOOTMEM_ALLOC_ACCESSIBLE,
> > +				     bestnode);
> >  
> >  	return ptr;
> >  }
> > diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> > index ffcc358..2169ca5 100644
> > --- a/arch/ia64/mm/init.c
> > +++ b/arch/ia64/mm/init.c
> > @@ -459,7 +459,7 @@ int __init create_mem_map_page_table(u64 start, u64 end, void *arg)
> >  		pte = pte_offset_kernel(pmd, address);
> >  
> >  		if (pte_none(*pte))
> > -			set_pte(pte, pfn_pte(__pa(memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node))) >> PAGE_SHIFT,
> > +			set_pte(pte, pfn_pte(__pa(memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node)) >> PAGE_SHIFT,
> >  					     PAGE_KERNEL));
> 
> This doesn't seem to belong to the patch, right?

Right, will fix.
 
> >  	}
> >  	return 0;
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
