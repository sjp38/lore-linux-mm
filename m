Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0E06B7B42
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 13:08:47 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id 2-v6so300650ljs.15
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 10:08:47 -0800 (PST)
Received: from asavdk3.altibox.net (asavdk3.altibox.net. [109.247.116.14])
        by mx.google.com with ESMTPS id a8si660828lfk.7.2018.12.06.10.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 10:08:44 -0800 (PST)
Date: Thu, 6 Dec 2018 19:08:26 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH v2 5/6] arch: simplify several early memory allocations
Message-ID: <20181206180826.GB19166@ravnborg.org>
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
 <1543852035-26634-6-git-send-email-rppt@linux.ibm.com>
 <20181203162908.GB4244@ravnborg.org>
 <20181203164920.GB26700@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203164920.GB26700@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

On Mon, Dec 03, 2018 at 06:49:21PM +0200, Mike Rapoport wrote:
> On Mon, Dec 03, 2018 at 05:29:08PM +0100, Sam Ravnborg wrote:
> > Hi Mike.
> > 
> > > index c37955d..2a17665 100644
> > > --- a/arch/sparc/kernel/prom_64.c
> > > +++ b/arch/sparc/kernel/prom_64.c
> > > @@ -34,16 +34,13 @@
> > >  
> > >  void * __init prom_early_alloc(unsigned long size)
> > >  {
> > > -	unsigned long paddr = memblock_phys_alloc(size, SMP_CACHE_BYTES);
> > > -	void *ret;
> > > +	void *ret = memblock_alloc(size, SMP_CACHE_BYTES);
> > >  
> > > -	if (!paddr) {
> > > +	if (!ret) {
> > >  		prom_printf("prom_early_alloc(%lu) failed\n", size);
> > >  		prom_halt();
> > >  	}
> > >  
> > > -	ret = __va(paddr);
> > > -	memset(ret, 0, size);
> > >  	prom_early_allocated += size;
> > >  
> > >  	return ret;
> > 
> > memblock_alloc() calls memblock_alloc_try_nid().
> > And if allocation fails then memblock_alloc_try_nid() calls panic().
> > So will we ever hit the prom_halt() code?
> 
> memblock_phys_alloc_try_nid() also calls panic if an allocation fails. So
> in either case we never reach prom_halt() code.

So we have code here we never reach - not nice.
If the idea is to avoid relying on the panic inside memblock_alloc() then
maybe replace it with a variant that do not call panic?
To make it clear what happens.

	Sam
