Message-ID: <45657B0D.3040207@shadowen.org>
Date: Thu, 23 Nov 2006 10:42:21 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: VMALLOC_END definition?
References: <20061123084940.GA8009@osiris.boeblingen.de.ibm.com>
In-Reply-To: <20061123084940.GA8009@osiris.boeblingen.de.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Heiko Carstens wrote:
> Hi,
> 
> I just stumbled across the VMALLOC_END definition: I'm not entirely sure
> what the meaning of this is: is it the last _valid_ address of the
> vmalloc area or is it the first address _after_ the vmalloc area?
> 
> Reading the code in mm/vmalloc.c it seems to be the last valid address,
> which IMHO is the only thing that makes sense... how would one express
> the first address after 0xffffffff on a 32bit architecture?
> Whatever it is, it looks like half of the architectures got it wrong.
> 
> We have a lot of these:
> 
> e.g. powerpc:
> #define VMALLOC_START ASM_CONST(0xD000000000000000)
> #define VMALLOC_SIZE  ASM_CONST(0x80000000000)
> #define VMALLOC_END   (VMALLOC_START + VMALLOC_SIZE)
> 
> but also a lot of these:
> 
> e.g. x86_64
> 
> #define VMALLOC_START    0xffffc20000000000UL
> #define VMALLOC_END      0xffffe1ffffffffffUL

A quick grep shows that most architectures are assuming vmalloc space is
VMALLOC_START >= addr < VMALLOC_END.  x86_64 seems to be an odd one out
with the following construct in architecture specific code:

arch/x86_64/mm/fault.c: for (address = start; address <= VMALLOC_END;
address += PGDIR_SIZE) {

However, it also has this:

arch/x86_64/mm/fault.c:               ((address >= VMALLOC_START &&
address < VMALLOC_END))) {

A couple of filesystems and sparsemem also appear to assume the
VMALLOC_START >= addr < VMALLOC_END model.  So it seems likely that the
architectures not using this model are wrong.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
