Message-ID: <3A017A72.ECBA2051@mandrakesoft.com>
Date: Thu, 02 Nov 2000 09:30:10 -0500
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
References: <20001102134021.B1876@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> Next part of the kiobuf diffs: fix the fact that handle_mm_fault
> doesn't guarantee to complete the operation in all cases; doesn't
> guarantee that the resulting pte is writable if write access was
> requested; and doesn't pin the page against immediately being swapped
> back out.

Dumb question time, if you don't mind.  :)  All code examples are from
mm/memory.c.

This seems to imply datain means 'read access':
	int datain = (rw == READ);

This seems to further imply datain means 'read access':
	if (((datain) && (!(vma->vm_flags & VM_WRITE))) ||

And then we pass 'datain' as the 'write_access' arg of handle_mm_fault:
	if (handle_mm_fault(current->mm, vma, ptr, datain) <= 0)

Further down in make_pages_present, there seems to be the opposite:
	write = (vma->vm_flags & VM_WRITE) != 0;
	[...]
	if (handle_mm_fault(mm, vma, addr, write) < 0)


So, why do we pass 'datain' as the 'write_access' arg of
handle_mm_fault? 
(and now in your 02-faultfix.diff patch, as the 'write' arg of
follow_page)

Regards,

	Jeff


-- 
Jeff Garzik             | Dinner is ready when
Building 1024           | the smoke alarm goes off.
MandrakeSoft            |	-/usr/games/fortune
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
