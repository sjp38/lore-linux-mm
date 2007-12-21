Message-ID: <476B8DBB.4070309@de.ibm.com>
Date: Fri, 21 Dec 2007 10:56:11 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <476A8133.5050809@de.ibm.com> <6934efce0712200924o4e676484j95188a01b605bfdc@mail.gmail.com> <6934efce0712201612x57f77ab0le1d4d08d39e92c93@mail.gmail.com>
In-Reply-To: <6934efce0712201612x57f77ab0le1d4d08d39e92c93@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: carsteno@de.ibm.com, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Jared Hulbert wrote:
> vm_normal_page() needs to know if a VM_MIXEDMAP pfn has a struct page
> or not.  Somebody had suggested we'd need a pfn_normal() or something.
>  Maybe it should be called pfn_has_page() instead.  For ARM
> pfn_has_page() == pfn_valid() near as I can tell.  What about on s390?
Well, pfn_valid does'nt work for us as I pointed out before.

>  If pfn_valid() doesn't work, then can you check if the pfn is
> hotplugged in? 
Since the same memory segment may either be used as hotplug memory or 
as shared segment for xip, and since we'd want regular refcounting in 
one scenario and we'd not want regular refcounting in the other, I 
don't see an easy way. And walking a list of ranges to figure out is 
definetly too slow.

> What would pfn_to_page() return if the associated
> struct page entry was not initialized?
A pointer to the entry that is not initialized.

>  Can we use what is returned to
> check if the pfn has no page?
As far as I undstand Heiko's vmem_map magic, when we do access the 
vmem_map array to check, a struct page entry is created as reaction to 
the page fault. Therefore, this scenario gets us back the disatvantage 
of having struct page in the first place: memory consumption.

I think pfn_valid() or pfn_has_page() or similar arch callback does'nt 
work. We need a place to store the information whether or not a page 
needs refcounting or not. Either in the pte, or in vm_area_struct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
