Date: Tue, 26 Sep 2006 09:16:52 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: virtual memmap sparsity: Dealing with fragmented MAX_ORDER blocks
In-Reply-To: <Pine.LNX.4.64.0609251643150.25159@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0609260901160.15574@skynet.skynet.ie>
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
 <4517CB69.9030600@shadowen.org> <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
 <45181B4F.6060602@shadowen.org> <Pine.LNX.4.64.0609251354460.24262@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0609251643150.25159@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2006, Christoph Lameter wrote:

> Regarding buddy checks out of memmap:
>
> 1. This problem only occurs if we allow fragments of MAX_ORDER size
>   segments. The default needs to be not to allow that. Then we do not
>   need  any checks like right now on IA64. Why would one want smaller
>   granularity than 2M/4M in hotplugging?
>

On a local IA64 machine, the MAX_ORDER block of pages is not 2M or 4M but 
1GB. This is a base pagesize of 16K and a MAX_ORDER of 17. At best, 
MAX_ORDER could be fixed to present 256MB but there would be wastage.

> 2. If you must have these fragments then we need to check the validity
>   of the buddy pointers before derefencing them to see if pages can
>   be combined.

i.e. pfn_valid()

> If fragments are permitted then a
>   special function needs to be called to check if the address we are
>   accessing is legit. Preferably this would be done with an instruction
>   that can use the MMU to verify if the address is valid
>
>   On IA64 this is done with the "probe" instruction
>

Why does IA64 not use this then? Currently, it uses __get_user() and 
catches faults when they occur.

>   Looking through the i386 commands I see a VERR mnemonic that
>   I guess will do what you need on i386 and x86_64 in order to do
>   what we need without a page table walk.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
