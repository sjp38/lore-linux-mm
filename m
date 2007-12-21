Date: Fri, 21 Dec 2007 01:45:56 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
Message-ID: <20071221004556.GB31040@wotan.suse.de>
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <476A7D21.7070607@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 20, 2007 at 03:33:05PM +0100, Carsten Otte wrote:
> Carsten Otte wrote:
> >I'll drill down deeper here to see why it does'nt work as expected...
> Apparently pfn_valid() is true for our shared memory segment. The s390 
> implementation checks if the pfn is within max_pfn, which reflects the 
> size of the kernel page table 1:1 mapping. If that is the case, we use 
> one of our many magic instructions "lra" to ask our mmu if there is 
> memory we can access at subject address. Both is true for our shared 
> memory segment. Thus, the page gets refcounted regular on a struct 
> page entry that is not initialized.
> 
> Even worse, changing the semantic of pfn_valid() on s390 to be false 
> for shared segments is no option.  We'll want to use the same memory 
> segment for memory hotplug. And in that case we do want refcounting 
> because it becomes regular linux memory.

So then you're back to needing struct pages again. Do you allocate
them at hotplug time?

AFAIK, sparsemem keeps track of all sections for pfn_valid(), which would
work. Any plans to convert s390 to it? ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
