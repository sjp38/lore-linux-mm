Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kANBxIKJ131588
	for <linux-mm@kvack.org>; Thu, 23 Nov 2006 11:59:18 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kANC29PD2412742
	for <linux-mm@kvack.org>; Thu, 23 Nov 2006 12:02:09 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kANBxHtV031683
	for <linux-mm@kvack.org>; Thu, 23 Nov 2006 11:59:17 GMT
Date: Thu, 23 Nov 2006 12:58:01 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: VMALLOC_END definition?
Message-ID: <20061123115801.GB8009@osiris.boeblingen.de.ibm.com>
References: <20061123084940.GA8009@osiris.boeblingen.de.ibm.com> <45657B0D.3040207@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45657B0D.3040207@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 23, 2006 at 10:42:21AM +0000, Andy Whitcroft wrote:
> Heiko Carstens wrote:
> > I just stumbled across the VMALLOC_END definition: I'm not entirely sure
> > what the meaning of this is: is it the last _valid_ address of the
> > vmalloc area or is it the first address _after_ the vmalloc area?
> >
> > Reading the code in mm/vmalloc.c it seems to be the last valid address,
> > which IMHO is the only thing that makes sense... how would one express
> > the first address after 0xffffffff on a 32bit architecture?
> > Whatever it is, it looks like half of the architectures got it wrong.
>
> A quick grep shows that most architectures are assuming vmalloc space is
> VMALLOC_START >= addr < VMALLOC_END.  x86_64 seems to be an odd one out
> with the following construct in architecture specific code:
> 
> arch/x86_64/mm/fault.c: for (address = start; address <= VMALLOC_END;
> address += PGDIR_SIZE) {
> 
> However, it also has this:
> 
> arch/x86_64/mm/fault.c:               ((address >= VMALLOC_START &&
> address < VMALLOC_END))) {
> 
> A couple of filesystems and sparsemem also appear to assume the
> VMALLOC_START >= addr < VMALLOC_END model.  So it seems likely that the
> architectures not using this model are wrong.

Ah, right... I also found this one in include/asm-arm/pgtable.h

 * Note that platforms may override VMALLOC_START, but they must provide
 * VMALLOC_END.  VMALLOC_END defines the (exclusive) limit of this space,
 * which may not overlap IO space.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
