Message-ID: <3A8C254F.17334682@colorfullife.com>
Date: Thu, 15 Feb 2001 19:51:59 +0100
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: x86 ptep_get_and_clear question
References: <200102151823.KAA00802@google.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org, mingo@redhat.com, alan@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar wrote:
> 
> Okay, I will quote from Intel Architecture Software Developer's Manual
> Volume 3: System Programming Guide (1997 print), section 3.7, page 3-27:
> 
> "Bus cycles to the page directory and page tables in memory are performed
> only when the TLBs do not contain the translation information for a
> requested page."
> 
> And on the same page:
> 
> "Whenever a page directory or page table entry is changed (including when
> the present flag is set to zero), the operating system must immediately
> invalidate the corresponding entry in the TLB so that it can be updated
> the next time the entry is referenced."
>

But there is another paragraph that mentions that an OS may use lazy tlb
shootdowns.
[search for shootdown]

You check the far too obvious chapters, remember that Intel wrote the
documentation ;-)
I searched for 'dirty' though Vol 3 and found

Chapter 7.1.2.1 Automatic locking.

.. the processor uses locked cycles to set the accessed and dirty flag
in the page-directory and page-table entries.

But that obviously doesn't answer your question.

Is the sequence
<< lock;
read pte
pte |= dirty
write pte
>> end lock;
or
<< lock;
read pte
if (!present(pte))
	do_page_fault();
pte |= dirty
write pte.
>> end lock;

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
