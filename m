Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4309F6B78D4
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:49:58 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v4-v6so12759358oix.2
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:49:58 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e67-v6si3112345oia.360.2018.09.06.05.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 05:49:57 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w86Cmxdb044041
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 08:49:56 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mb3t12cr0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 08:49:56 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 6 Sep 2018 13:49:53 +0100
Date: Thu, 6 Sep 2018 15:49:44 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 14/29] memblock: add align parameter to
 memblock_alloc_node()
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-15-git-send-email-rppt@linux.vnet.ibm.com>
 <20180906080614.GW14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906080614.GW14951@dhcp22.suse.cz>
Message-Id: <20180906124944.GF27492@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 06, 2018 at 10:06:14AM +0200, Michal Hocko wrote:
> On Wed 05-09-18 18:59:29, Mike Rapoport wrote:
> > With the align parameter memblock_alloc_node() can be used as drop in
> > replacement for alloc_bootmem_pages_node().
> 
> Why do we need an additional translation later? Sparse code which is the
> only one to use it already uses memblock_alloc_try_nid elsewhere
> (sparse_mem_map_populate).

It is also used in later patches to replace alloc_bootmem* in several
places and most of them explicitly set the alignment.
 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> >  include/linux/bootmem.h | 4 ++--
> >  mm/sparse.c             | 2 +-
> >  2 files changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> > index 7d91f0f..3896af2 100644
> > --- a/include/linux/bootmem.h
> > +++ b/include/linux/bootmem.h
> > @@ -157,9 +157,9 @@ static inline void * __init memblock_alloc_from_nopanic(
> >  }
> >  
> >  static inline void * __init memblock_alloc_node(
> > -						phys_addr_t size, int nid)
> > +		phys_addr_t size, phys_addr_t align, int nid)
> >  {
> > -	return memblock_alloc_try_nid(size, 0, BOOTMEM_LOW_LIMIT,
> > +	return memblock_alloc_try_nid(size, align, BOOTMEM_LOW_LIMIT,
> >  					    BOOTMEM_ALLOC_ACCESSIBLE, nid);
> >  }
> >  
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 04e97af..509828f 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -68,7 +68,7 @@ static noinline struct mem_section __ref *sparse_index_alloc(int nid)
> >  	if (slab_is_available())
> >  		section = kzalloc_node(array_size, GFP_KERNEL, nid);
> >  	else
> > -		section = memblock_alloc_node(array_size, nid);
> > +		section = memblock_alloc_node(array_size, 0, nid);
> >  
> >  	return section;
> >  }
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
