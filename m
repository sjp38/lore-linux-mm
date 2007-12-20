Message-ID: <476A7D21.7070607@de.ibm.com>
Date: Thu, 20 Dec 2007 15:33:05 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com>
In-Reply-To: <476A73F0.4070704@de.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Carsten Otte wrote:
> I'll drill down deeper here to see why it does'nt work as expected...
Apparently pfn_valid() is true for our shared memory segment. The s390 
implementation checks if the pfn is within max_pfn, which reflects the 
size of the kernel page table 1:1 mapping. If that is the case, we use 
one of our many magic instructions "lra" to ask our mmu if there is 
memory we can access at subject address. Both is true for our shared 
memory segment. Thus, the page gets refcounted regular on a struct 
page entry that is not initialized.

Even worse, changing the semantic of pfn_valid() on s390 to be false 
for shared segments is no option.  We'll want to use the same memory 
segment for memory hotplug. And in that case we do want refcounting 
because it becomes regular linux memory.

So bottom line I think we do need a different trigger then pfn_valid() 
to select which pages within VM_MIXEDMAP get refcounted and which don't.

cheers,
Carsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
