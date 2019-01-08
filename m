Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA67C8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 10:49:20 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id c71so3427653qke.18
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 07:49:20 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h21si3282804qtq.120.2019.01.08.07.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 07:49:19 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x08FnJrU090570
	for <linux-mm@kvack.org>; Tue, 8 Jan 2019 10:49:19 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pvwx4uf0c-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Jan 2019 10:49:06 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 8 Jan 2019 15:49:03 -0000
Date: Tue, 8 Jan 2019 17:48:52 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCHv5] x86/kdump: bugfix, make the behavior of crashkernel=X
 consistent with kaslr
References: <1546848299-23628-1-git-send-email-kernelfans@gmail.com>
 <20190108080538.GB4396@rapoport-lnx>
 <20190108090138.GB18718@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190108090138.GB18718@MiWiFi-R3L-srv>
Message-Id: <20190108154852.GC14063@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Pingfan Liu <kernelfans@gmail.com>, linux-mm@kvack.org, kexec@lists.infradead.org, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

On Tue, Jan 08, 2019 at 05:01:38PM +0800, Baoquan He wrote:
> Hi Mike,
> 
> On 01/08/19 at 10:05am, Mike Rapoport wrote:
> > I'm not thrilled by duplicating this code (yet again).
> > I liked the v3 of this patch [1] more, assuming we allow bottom-up mode to
> > allocate [0, kernel_start) unconditionally. 
> > I'd just replace you first patch in v3 [2] with something like:
> 
> In initmem_init(), we will restore the top-down allocation style anyway.
> While reserve_crashkernel() is called after initmem_init(), it's not
> appropriate to adjust memblock_find_in_range_node(), and we really want
> to find region bottom up for crashkernel reservation, no matter where
> kernel is loaded, better call __memblock_find_range_bottom_up().
> 
> Create a wrapper to do the necessary handling, then call
> __memblock_find_range_bottom_up() directly, looks better.

What bothers me is 'the necessary handling' which is already done in
several places in memblock in a similar, but yet slightly different way.

memblock_find_in_range() and memblock_phys_alloc_nid() retry with different
MEMBLOCK_MIRROR, but memblock_phys_alloc_try_nid() does that only when
allocating from the specified node and does not retry when it falls back to
any node. And memblock_alloc_internal() has yet another set of fallbacks. 

So what should be the necessary handling in the wrapper for
__memblock_find_range_bottom_up() ?

BTW, even without any memblock modifications, retrying allocation in
reserve_crashkerenel() for different ranges, like the proposal at [1] would
also work, wouldn't it?

[1] http://lists.infradead.org/pipermail/kexec/2017-October/019571.html
 
> Thanks
> Baoquan
> 
> > 
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 7df468c..d1b30b9 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -274,24 +274,14 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
> >  	 * try bottom-up allocation only when bottom-up mode
> >  	 * is set and @end is above the kernel image.
> >  	 */
> > -	if (memblock_bottom_up() && end > kernel_end) {
> > -		phys_addr_t bottom_up_start;
> > -
> > -		/* make sure we will allocate above the kernel */
> > -		bottom_up_start = max(start, kernel_end);
> > -
> > +	if (memblock_bottom_up()) {
> >  		/* ok, try bottom-up allocation first */
> > -		ret = __memblock_find_range_bottom_up(bottom_up_start, end,
> > +		ret = __memblock_find_range_bottom_up(start, end,
> >  						      size, align, nid, flags);
> >  		if (ret)
> >  			return ret;
> >  
> >  		/*
> > -		 * we always limit bottom-up allocation above the kernel,
> > -		 * but top-down allocation doesn't have the limit, so
> > -		 * retrying top-down allocation may succeed when bottom-up
> > -		 * allocation failed.
> > -		 *
> >  		 * bottom-up allocation is expected to be fail very rarely,
> >  		 * so we use WARN_ONCE() here to see the stack trace if
> >  		 * fail happens.
> > 
> > [1] https://lore.kernel.org/lkml/1545966002-3075-3-git-send-email-kernelfans@gmail.com/
> > [2] https://lore.kernel.org/lkml/1545966002-3075-2-git-send-email-kernelfans@gmail.com/
> > 
> > > +
> > > +	return ret;
> > > +}
> > > +
> > >  /**
> > >   * __memblock_find_range_top_down - find free area utility, in top-down
> > >   * @start: start of candidate range
> > > -- 
> > > 2.7.4
> > > 
> > 
> > -- 
> > Sincerely yours,
> > Mike.
> > 
> 

-- 
Sincerely yours,
Mike.
