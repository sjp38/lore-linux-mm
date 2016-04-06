Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5D46C6B025F
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:27:11 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id l6so60544069wml.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:27:11 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id gh2si2689830wjb.232.2016.04.06.04.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 04:27:10 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i204so12290733wmd.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:27:10 -0700 (PDT)
Date: Wed, 6 Apr 2016 13:27:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] powerpc/mm: Add memory barrier in __hugepte_alloc()
Message-ID: <20160406112708.GF24272@dhcp22.suse.cz>
References: <20160405190547.GA12673@us.ibm.com>
 <20160406095623.GA24283@dhcp22.suse.cz>
 <8737qzxd4i.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8737qzxd4i.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, James Dykman <jdykman@us.ibm.com>

On Wed 06-04-16 15:39:17, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > [ text/plain ]
> > On Tue 05-04-16 12:05:47, Sukadev Bhattiprolu wrote:
> > [...]
> >> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> >> index d991b9e..081f679 100644
> >> --- a/arch/powerpc/mm/hugetlbpage.c
> >> +++ b/arch/powerpc/mm/hugetlbpage.c
> >> @@ -81,6 +81,13 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
> >>  	if (! new)
> >>  		return -ENOMEM;
> >>  
> >> +	/*
> >> +	 * Make sure other cpus find the hugepd set only after a
> >> +	 * properly initialized page table is visible to them.
> >> +	 * For more details look for comment in __pte_alloc().
> >> +	 */
> >> +	smp_wmb();
> >> +
> >
> > what is the pairing memory barrier?
> >
> >>  	spin_lock(&mm->page_table_lock);
> >>  #ifdef CONFIG_PPC_FSL_BOOK3E
> >>  	/*
> 
> This is documented in __pte_alloc(). I didn't want to repeat the same
> here.
> 
> 	/*
> 	 * Ensure all pte setup (eg. pte page lock and page clearing) are
> 	 * visible before the pte is made visible to other CPUs by being
> 	 * put into page tables.
> 	 *
> 	 * The other side of the story is the pointer chasing in the page
> 	 * table walking code (when walking the page table without locking;
> 	 * ie. most of the time). Fortunately, these data accesses consist
> 	 * of a chain of data-dependent loads, meaning most CPUs (alpha
> 	 * being the notable exception) will already guarantee loads are
> 	 * seen in-order. See the alpha page table accessors for the
> 	 * smp_read_barrier_depends() barriers in page table walking code.
> 	 */
> 	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */

OK, I have missed the reference to __pte_alloc. My bad!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
