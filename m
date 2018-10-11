Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id A81AE6B0008
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 02:09:07 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id z14-v6so3793002ybp.6
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 23:09:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s68-v6si1831841ybc.336.2018.10.10.23.09.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 23:09:06 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9B695Oe105575
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 02:09:06 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2n20vd09gs-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 02:09:05 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 11 Oct 2018 07:09:03 +0100
Date: Thu, 11 Oct 2018 09:08:50 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] memblock: stop using implicit alignement to
 SMP_CACHE_BYTES
References: <1538687224-17535-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20181005151934.87226fa92825c3002a475413@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181005151934.87226fa92825c3002a475413@linux-foundation.org>
Message-Id: <20181011060850.GA19822@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-um@lists.infradead.org

On Fri, Oct 05, 2018 at 03:19:34PM -0700, Andrew Morton wrote:
> On Fri,  5 Oct 2018 00:07:04 +0300 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > When a memblock allocation APIs are called with align = 0, the alignment is
> > implicitly set to SMP_CACHE_BYTES.
> > 
> > Replace all such uses of memblock APIs with the 'align' parameter explicitly
> > set to SMP_CACHE_BYTES and stop implicit alignment assignment in the
> > memblock internal allocation functions.
> > 
> > For the case when memblock APIs are used via helper functions, e.g. like
> > iommu_arena_new_node() in Alpha, the helper functions were detected with
> > Coccinelle's help and then manually examined and updated where appropriate.
> > 
> > ...
> >
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -1298,9 +1298,6 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
> >  {
> >  	phys_addr_t found;
> >  
> > -	if (!align)
> > -		align = SMP_CACHE_BYTES;
> > -
> 
> Can we add a WARN_ON_ONCE(!align) here?  To catch unconverted code
> which sneaks in later on.

Here it goes:
