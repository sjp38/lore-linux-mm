Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0E66B6A37
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 11:49:40 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id bj3so10498539plb.17
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 08:49:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w9si13053748pgg.72.2018.12.03.08.49.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 08:49:39 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB3GibtO132475
	for <linux-mm@kvack.org>; Mon, 3 Dec 2018 11:49:38 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p57kp2y0k-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 03 Dec 2018 11:49:37 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 3 Dec 2018 16:49:35 -0000
Date: Mon, 3 Dec 2018 18:49:21 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 5/6] arch: simplify several early memory allocations
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
 <1543852035-26634-6-git-send-email-rppt@linux.ibm.com>
 <20181203162908.GB4244@ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203162908.GB4244@ravnborg.org>
Message-Id: <20181203164920.GB26700@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

On Mon, Dec 03, 2018 at 05:29:08PM +0100, Sam Ravnborg wrote:
> Hi Mike.
> 
> > index c37955d..2a17665 100644
> > --- a/arch/sparc/kernel/prom_64.c
> > +++ b/arch/sparc/kernel/prom_64.c
> > @@ -34,16 +34,13 @@
> >  
> >  void * __init prom_early_alloc(unsigned long size)
> >  {
> > -	unsigned long paddr = memblock_phys_alloc(size, SMP_CACHE_BYTES);
> > -	void *ret;
> > +	void *ret = memblock_alloc(size, SMP_CACHE_BYTES);
> >  
> > -	if (!paddr) {
> > +	if (!ret) {
> >  		prom_printf("prom_early_alloc(%lu) failed\n", size);
> >  		prom_halt();
> >  	}
> >  
> > -	ret = __va(paddr);
> > -	memset(ret, 0, size);
> >  	prom_early_allocated += size;
> >  
> >  	return ret;
> 
> memblock_alloc() calls memblock_alloc_try_nid().
> And if allocation fails then memblock_alloc_try_nid() calls panic().
> So will we ever hit the prom_halt() code?

memblock_phys_alloc_try_nid() also calls panic if an allocation fails. So
in either case we never reach prom_halt() code.

Actually, sparc is rather an exception from the general practice to rely on
panic() inside the early allocator rather than to check the return value.
 
> Do we have a panic() implementation that actually returns?
> 
> 
> > diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
> > index 3c8aac2..52884f4 100644
> > --- a/arch/sparc/mm/init_64.c
> > +++ b/arch/sparc/mm/init_64.c
> > @@ -1089,16 +1089,13 @@ static void __init allocate_node_data(int nid)
> >  	struct pglist_data *p;
> >  	unsigned long start_pfn, end_pfn;
> >  #ifdef CONFIG_NEED_MULTIPLE_NODES
> > -	unsigned long paddr;
> >  
> > -	paddr = memblock_phys_alloc_try_nid(sizeof(struct pglist_data),
> > -					    SMP_CACHE_BYTES, nid);
> > -	if (!paddr) {
> > +	NODE_DATA(nid) = memblock_alloc_node(sizeof(struct pglist_data),
> > +					     SMP_CACHE_BYTES, nid);
> > +	if (!NODE_DATA(nid)) {
> >  		prom_printf("Cannot allocate pglist_data for nid[%d]\n", nid);
> >  		prom_halt();
> >  	}
> > -	NODE_DATA(nid) = __va(paddr);
> > -	memset(NODE_DATA(nid), 0, sizeof(struct pglist_data));
> >  
> >  	NODE_DATA(nid)->node_id = nid;
> >  #endif
> 
> Same here.
> 
> I did not look at the other cases.

I really tried to be careful and did the replacements only for the calls
that do panic if an allocation fails.
 
> 	Sam
> 

-- 
Sincerely yours,
Mike.
