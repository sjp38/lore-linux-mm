Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C7D566B7C65
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 16:31:15 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t2so960075edb.22
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 13:31:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u27si657806eda.251.2018.12.06.13.31.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 13:31:14 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB6LTIKh039935
	for <linux-mm@kvack.org>; Thu, 6 Dec 2018 16:31:12 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p79pae1w8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Dec 2018 16:31:08 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 6 Dec 2018 21:30:40 -0000
Date: Thu, 6 Dec 2018 23:30:27 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 5/6] arch: simplify several early memory allocations
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
 <1543852035-26634-6-git-send-email-rppt@linux.ibm.com>
 <20181203162908.GB4244@ravnborg.org>
 <20181203164920.GB26700@rapoport-lnx>
 <20181206180826.GB19166@ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181206180826.GB19166@ravnborg.org>
Message-Id: <20181206213026.GA7479@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

On Thu, Dec 06, 2018 at 07:08:26PM +0100, Sam Ravnborg wrote:
> On Mon, Dec 03, 2018 at 06:49:21PM +0200, Mike Rapoport wrote:
> > On Mon, Dec 03, 2018 at 05:29:08PM +0100, Sam Ravnborg wrote:
> > > Hi Mike.
> > > 
> > > > index c37955d..2a17665 100644
> > > > --- a/arch/sparc/kernel/prom_64.c
> > > > +++ b/arch/sparc/kernel/prom_64.c
> > > > @@ -34,16 +34,13 @@
> > > >  
> > > >  void * __init prom_early_alloc(unsigned long size)
> > > >  {
> > > > -	unsigned long paddr = memblock_phys_alloc(size, SMP_CACHE_BYTES);
> > > > -	void *ret;
> > > > +	void *ret = memblock_alloc(size, SMP_CACHE_BYTES);
> > > >  
> > > > -	if (!paddr) {
> > > > +	if (!ret) {
> > > >  		prom_printf("prom_early_alloc(%lu) failed\n", size);
> > > >  		prom_halt();
> > > >  	}
> > > >  
> > > > -	ret = __va(paddr);
> > > > -	memset(ret, 0, size);
> > > >  	prom_early_allocated += size;
> > > >  
> > > >  	return ret;
> > > 
> > > memblock_alloc() calls memblock_alloc_try_nid().
> > > And if allocation fails then memblock_alloc_try_nid() calls panic().
> > > So will we ever hit the prom_halt() code?
> > 
> > memblock_phys_alloc_try_nid() also calls panic if an allocation fails. So
> > in either case we never reach prom_halt() code.
> 
> So we have code here we never reach - not nice.
> If the idea is to avoid relying on the panic inside memblock_alloc() then
> maybe replace it with a variant that do not call panic?
> To make it clear what happens.

My plan is to completely remove memblock variants that call panic() and
make the callers check the return value.

I've started to work on it, but with the holidays it progresses slower than
I'd like to.

Since the code here was unreachable for several year, a few more weeks
won't make real difference so I'd prefer to keep the variant with panic()
for now. 
 
> 	Sam
> 

-- 
Sincerely yours,
Mike.
