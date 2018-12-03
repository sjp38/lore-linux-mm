Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4506B6A1C
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 11:28:34 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r16so7126842pgr.15
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 08:28:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j66si15594202pfb.182.2018.12.03.08.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 08:28:32 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB3GPqXk081374
	for <linux-mm@kvack.org>; Mon, 3 Dec 2018 11:28:32 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p57n41gg2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 03 Dec 2018 11:28:32 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 3 Dec 2018 16:28:28 -0000
Date: Mon, 3 Dec 2018 18:28:16 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 3/6] sh: prefer memblock APIs returning virtual address
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
 <1543852035-26634-4-git-send-email-rppt@linux.ibm.com>
 <20181203161052.GA4244@ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203161052.GA4244@ravnborg.org>
Message-Id: <20181203162816.GA26700@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

On Mon, Dec 03, 2018 at 05:10:52PM +0100, Sam Ravnborg wrote:
> Hi Mike.
> 
> On Mon, Dec 03, 2018 at 05:47:12PM +0200, Mike Rapoport wrote:
> > Rather than use the memblock_alloc_base that returns a physical address and
> > then convert this address to the virtual one, use appropriate memblock
> > function that returns a virtual address.
> > 
> > There is a small functional change in the allocation of then NODE_DATA().
> > Instead of panicing if the local allocation failed, the non-local
> > allocation attempt will be made.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > ---
> >  arch/sh/mm/init.c | 18 +++++-------------
> >  arch/sh/mm/numa.c |  5 ++---
> >  2 files changed, 7 insertions(+), 16 deletions(-)
> > 
> > diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> > index c8c13c77..3576b5f 100644
> > --- a/arch/sh/mm/init.c
> > +++ b/arch/sh/mm/init.c
> > @@ -192,24 +192,16 @@ void __init page_table_range_init(unsigned long start, unsigned long end,
> >  void __init allocate_pgdat(unsigned int nid)
> >  {
> >  	unsigned long start_pfn, end_pfn;
> > -#ifdef CONFIG_NEED_MULTIPLE_NODES
> > -	unsigned long phys;
> > -#endif
> >  
> >  	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
> >  
> >  #ifdef CONFIG_NEED_MULTIPLE_NODES
> > -	phys = __memblock_alloc_base(sizeof(struct pglist_data),
> > -				SMP_CACHE_BYTES, end_pfn << PAGE_SHIFT);
> > -	/* Retry with all of system memory */
> > -	if (!phys)
> > -		phys = __memblock_alloc_base(sizeof(struct pglist_data),
> > -					SMP_CACHE_BYTES, memblock_end_of_DRAM());
> > -	if (!phys)
> > +	NODE_DATA(nid) = memblock_alloc_try_nid_nopanic(
> > +				sizeof(struct pglist_data),
> > +				SMP_CACHE_BYTES, MEMBLOCK_LOW_LIMIT,
> > +				MEMBLOCK_ALLOC_ACCESSIBLE, nid);
> > +	if (!NODE_DATA(nid))
> >  		panic("Can't allocate pgdat for node %d\n", nid);
> > -
> > -	NODE_DATA(nid) = __va(phys);
> > -	memset(NODE_DATA(nid), 0, sizeof(struct pglist_data));
> The new code will always assign NODE_DATA(nid), where the old
> code only assigned NODE_DATA(nid) in the good case.
> I dunno if this is an issue, just noticed the difference and
> wanted to point it out.

If the allocation fails the NODE_DATA(nid) remains zero anyway and there is
a panic() call. So I think there is no actual functional change here.

> 	Sam
> 

-- 
Sincerely yours,
Mike.
