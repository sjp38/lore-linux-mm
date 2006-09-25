Date: Mon, 25 Sep 2006 16:54:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: virtual memmap sparsity: Dealing with fragmented MAX_ORDER blocks
In-Reply-To: <Pine.LNX.4.64.0609251354460.24262@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0609251643150.25159@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
 <4517CB69.9030600@shadowen.org> <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
 <45181B4F.6060602@shadowen.org> <Pine.LNX.4.64.0609251354460.24262@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Regarding buddy checks out of memmap:

1. This problem only occurs if we allow fragments of MAX_ORDER size 
   segments. The default needs to be not to allow that. Then we do not 
   need  any checks like right now on IA64. Why would one want smaller
   granularity than 2M/4M in hotplugging?

2. If you must have these fragments then we need to check the validity
   of the buddy pointers before derefencing them to see if pages can
   be combined. If fragments are permitted then a
   special function needs to be called to check if the address we are
   accessing is legit. Preferably this would be done with an instruction
   that can use the MMU to verify if the address is valid 

   On IA64 this is done with the "probe" instruction

   Looking through the i386 commands I see a VERR mnemonic that
   I guess will do what you need on i386 and x86_64 in order to do
   what we need without a page table walk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
