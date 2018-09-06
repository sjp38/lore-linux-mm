Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5256B78CA
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:45:05 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p11-v6so12498419oih.17
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:45:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r4-v6si3139343oia.155.2018.09.06.05.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 05:45:04 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w86Chnqp101471
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 08:45:04 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mb3cn37jw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 08:45:03 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 6 Sep 2018 13:45:02 +0100
Date: Thu, 6 Sep 2018 15:44:53 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 13/29] memblock: replace __alloc_bootmem_nopanic with
 memblock_alloc_from_nopanic
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-14-git-send-email-rppt@linux.vnet.ibm.com>
 <20180906075721.GV14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906075721.GV14951@dhcp22.suse.cz>
Message-Id: <20180906124453.GE27492@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 06, 2018 at 09:57:21AM +0200, Michal Hocko wrote:
> On Wed 05-09-18 18:59:28, Mike Rapoport wrote:
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> The translation is simpler here but still a word or two would be nice.
> Empty changelogs suck.

This is one of the things left to sort out :)
 
> To the change
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> > ---
> >  arch/arc/kernel/unwind.c       | 4 ++--
> >  arch/x86/kernel/setup_percpu.c | 4 ++--
> >  2 files changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/arch/arc/kernel/unwind.c b/arch/arc/kernel/unwind.c
> > index 183391d..2a01dd1 100644
> > --- a/arch/arc/kernel/unwind.c
> > +++ b/arch/arc/kernel/unwind.c
> > @@ -181,8 +181,8 @@ static void init_unwind_hdr(struct unwind_table *table,
> >   */
> >  static void *__init unw_hdr_alloc_early(unsigned long sz)
> >  {
> > -	return __alloc_bootmem_nopanic(sz, sizeof(unsigned int),
> > -				       MAX_DMA_ADDRESS);
> > +	return memblock_alloc_from_nopanic(sz, sizeof(unsigned int),
> > +					   MAX_DMA_ADDRESS);
> >  }
> >  
> >  static void *unw_hdr_alloc(unsigned long sz)
> > diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
> > index 67d48e26..041663a 100644
> > --- a/arch/x86/kernel/setup_percpu.c
> > +++ b/arch/x86/kernel/setup_percpu.c
> > @@ -106,7 +106,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, unsigned long size,
> >  	void *ptr;
> >  
> >  	if (!node_online(node) || !NODE_DATA(node)) {
> > -		ptr = __alloc_bootmem_nopanic(size, align, goal);
> > +		ptr = memblock_alloc_from_nopanic(size, align, goal);
> >  		pr_info("cpu %d has no node %d or node-local memory\n",
> >  			cpu, node);
> >  		pr_debug("per cpu data for cpu%d %lu bytes at %016lx\n",
> > @@ -121,7 +121,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, unsigned long size,
> >  	}
> >  	return ptr;
> >  #else
> > -	return __alloc_bootmem_nopanic(size, align, goal);
> > +	return memblock_alloc_from_nopanic(size, align, goal);
> >  #endif
> >  }
> >  
> > -- 
> > 2.7.4
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
