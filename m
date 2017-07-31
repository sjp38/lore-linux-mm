Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E72966B05F9
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:55:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e204so19419288wma.2
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 05:55:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m191si472517wmb.231.2017.07.31.05.55.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 05:55:59 -0700 (PDT)
Date: Mon, 31 Jul 2017 14:55:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/5] mm, arch: unify vmemmap_populate altmap handling
Message-ID: <20170731125555.GB4829@dhcp22.suse.cz>
References: <20170726083333.17754-1-mhocko@kernel.org>
 <20170726083333.17754-3-mhocko@kernel.org>
 <20170731144053.38c8b012@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731144053.38c8b012@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>

On Mon 31-07-17 14:40:53, Gerald Schaefer wrote:
[...]
> > @@ -247,12 +248,12 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
> >  			 * use large frames even if they are only partially
> >  			 * used.
> >  			 * Otherwise we would have also page tables since
> > -			 * vmemmap_populate gets called for each section
> > +			 * __vmemmap_populate gets called for each section
> >  			 * separately. */
> >  			if (MACHINE_HAS_EDAT1) {
> >  				void *new_page;
> > 
> > -				new_page = vmemmap_alloc_block(PMD_SIZE, node);
> > +				new_page = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
> >  				if (!new_page)
> >  					goto out;
> >  				pmd_val(*pm_dir) = __pa(new_page) | sgt_prot;
> 
> There is another call to vmemmap_alloc_block() in this function, a couple
> of lines below, this should also be replaced by __vmemmap_alloc_block_buf().

I've noticed that one but in general I have only transformed PMD
mappings because we shouldn't even get to pte level if the forme works
AFAICS. Memory sections should be always 2MB aligned unless I am missing
something. Or is this not true?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
