Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CDF96B04B3
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 10:28:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p43so42318009wrb.6
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 07:28:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s7si22549641wrb.494.2017.07.31.07.27.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 07:28:00 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6VEOHuF020299
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 10:27:58 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c24v7dcwe-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 10:27:58 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 31 Jul 2017 15:27:56 +0100
Date: Mon, 31 Jul 2017 16:27:46 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [RFC PATCH 2/5] mm, arch: unify vmemmap_populate altmap
 handling
In-Reply-To: <20170731125555.GB4829@dhcp22.suse.cz>
References: <20170726083333.17754-1-mhocko@kernel.org>
	<20170726083333.17754-3-mhocko@kernel.org>
	<20170731144053.38c8b012@thinkpad>
	<20170731125555.GB4829@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20170731162746.60b8d98e@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, gerald.schaefer@de.ibm.com

On Mon, 31 Jul 2017 14:55:56 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 31-07-17 14:40:53, Gerald Schaefer wrote:
> [...]
> > > @@ -247,12 +248,12 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
> > >  			 * use large frames even if they are only partially
> > >  			 * used.
> > >  			 * Otherwise we would have also page tables since
> > > -			 * vmemmap_populate gets called for each section
> > > +			 * __vmemmap_populate gets called for each section
> > >  			 * separately. */
> > >  			if (MACHINE_HAS_EDAT1) {
> > >  				void *new_page;
> > > 
> > > -				new_page = vmemmap_alloc_block(PMD_SIZE, node);
> > > +				new_page = __vmemmap_alloc_block_buf(PMD_SIZE, node, altmap);
> > >  				if (!new_page)
> > >  					goto out;
> > >  				pmd_val(*pm_dir) = __pa(new_page) | sgt_prot;
> > 
> > There is another call to vmemmap_alloc_block() in this function, a couple
> > of lines below, this should also be replaced by __vmemmap_alloc_block_buf().
> 
> I've noticed that one but in general I have only transformed PMD
> mappings because we shouldn't even get to pte level if the forme works
> AFAICS. Memory sections should be always 2MB aligned unless I am missing
> something. Or is this not true?

vmemmap_populate() on s390 will only stop at pmd level if we have HW
support for large pages (MACHINE_HAS_EDAT1). In that case we will allocate
a PMD_SIZE block with vmemmap_alloc_block() and map it on pmd level as
a large page.

Without HW large page support, we will continue to allocate a pte page,
populate the pmd entry with that, and fall through to the pte_none()
check below, with its PAGE_SIZE vmemmap_alloc_block() allocation. In this
case we should use the __vmemmap_alloc_block_buf().

Regards,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
