Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED696B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 09:24:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i193-v6so1867622wmf.6
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 06:24:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j79-v6si2957108wmi.178.2018.07.04.06.24.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 06:24:18 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w64DNYgs008436
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 09:24:17 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2k0wn5v0dk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 09:24:17 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 14:24:15 +0100
Date: Wed, 4 Jul 2018 16:24:11 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180704130500.GP22503@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704130500.GP22503@dhcp22.suse.cz>
Message-Id: <20180704132410.GH4352@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>

On Wed, Jul 04, 2018 at 03:05:00PM +0200, Michal Hocko wrote:
> On Tue 03-07-18 20:05:06, Mike Rapoport wrote:
> > Most functions in memblock already use phys_addr_t to represent a physical
> > address with __memblock_free_late() being an exception.
> > 
> > This patch replaces u64 with phys_addr_t in __memblock_free_late() and
> > switches several format strings from %llx to %pa to avoid casting from
> > phys_addr_t to u64.
> > 
> > CC: Michal Hocko <mhocko@kernel.org>
> > CC: Matthew Wilcox <willy@infradead.org>
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> >  mm/memblock.c | 46 +++++++++++++++++++++++-----------------------
> >  1 file changed, 23 insertions(+), 23 deletions(-)
> > 
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 03d48d8..20ad8e9 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -330,7 +330,7 @@ static int __init_memblock memblock_double_array(struct memblock_type *type,
> >  {
> >  	struct memblock_region *new_array, *old_array;
> >  	phys_addr_t old_alloc_size, new_alloc_size;
> > -	phys_addr_t old_size, new_size, addr;
> > +	phys_addr_t old_size, new_size, addr, new_end;
> >  	int use_slab = slab_is_available();
> >  	int *in_slab;
> >  
> > @@ -391,9 +391,9 @@ static int __init_memblock memblock_double_array(struct memblock_type *type,
> >  		return -1;
> >  	}
> >  
> > -	memblock_dbg("memblock: %s is doubled to %ld at [%#010llx-%#010llx]",
> > -			type->name, type->max * 2, (u64)addr,
> > -			(u64)addr + new_size - 1);
> > +	new_end = addr + new_size - 1;
> > +	memblock_dbg("memblock: %s is doubled to %ld at [%pa-%pa]",
> > +			type->name, type->max * 2, &addr, &new_end);
> 
> I didn't get to check this carefully but this surely looks suspicious. I
> am pretty sure you wanted to print the value here rather than address of
> the local variable, right?

It's the semantics of %pa:

Physical address types phys_addr_t
----------------------------------

::

	%pa[p]	0x01234567 or 0x0123456789abcdef

For printing a phys_addr_t type (and its derivatives, such as
resource_size_t) which can vary based on build options, regardless of the
width of the CPU data path.

Passed by reference.


> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
