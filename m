Message-ID: <478B4942.4030003@de.ibm.com>
Date: Mon, 14 Jan 2008 12:36:34 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 1/4] include: add callbacks to toggle reference counting
 for VM_MIXEDMAP pages
References: <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com> <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com> <6934efce0801091017t7f9041abs62904de3722cadc@mail.gmail.com> <4785D064.1040501@de.ibm.com> <6934efce0801101201t72e9b7c4ra88d6fda0f08b1b2@mail.gmail.com> <47872CA7.40802@de.ibm.com> <20080113024410.GA22285@wotan.suse.de>
In-Reply-To: <20080113024410.GA22285@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> You know that pfn_valid() can be changed at runtime depending on what
> your intentions are for that page. It can remain false if you don't
> want struct pages for it, then you can switch a flag...
We would'nt need to switch at runtime: it is sufficient to make that 
decision when the segment gets attched.

> I've just been looking at putting everything together (including the
> pte_special patch). 
Yippieh. I am going to try it out next :-).

> I still hit one problem with your required modification
> to the filemap_xip patch.
 >
> You need to unconditionally do a vm_insert_pfn in xip_file_fault, and rely
> on the pte bit to tell the rest of the VM that the page has not been
> refcounted. For architectures without such a bit, this breaks VM_MIXEDMAP,
> because it relies on testing pfn_valid() rather than a pte bit here.
> We can go 2 ways here: either s390 can make pfn_valid() work like we'd
> like; or we can have a vm_insert_mixedmap_pfn(), which has
> #ifdef __HAVE_ARCH_PTE_SPECIAL
> in order to do the right thing (ie. those architectures which do have pte
> special can just do vm_insert_pfn, and those that don't will either do a
> vm_insert_pfn or vm_insert_page depending on the result of pfn_valid).
Of those two choices, I'd cleary favor vm_insert_mixedmap_pfn(). But 
we can #ifdef __HAVE_ARCH_PTE_SPECIAL in vm_insert_pfn() too, can't 
we? We can safely set the bit for both VM_MIXEDMAP and VM_PFNMAP. Did 
I miss something?

> The latter I guess is more efficient for those that do implement pte_special,
> however if anything I would rather investigate that as an incremental patch
> after the basics are working. It would also break the dependency of the
> xip stuff on the pte_special patch, and basically make everything much
> more likely to get merged IMO.
I'll talk to Martin and see what he thinks. I really hate doing list 
walk in pfn_valid(), it just does'nt feel right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
