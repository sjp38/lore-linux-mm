Date: Thu, 2 Nov 2000 15:58:35 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
Message-ID: <20001102155835.F1876@redhat.com>
References: <20001102134021.B1876@redhat.com> <3A017A72.ECBA2051@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3A017A72.ECBA2051@mandrakesoft.com>; from jgarzik@mandrakesoft.com on Thu, Nov 02, 2000 at 09:30:10AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Nov 02, 2000 at 09:30:10AM -0500, Jeff Garzik wrote:
> 
> Dumb question time, if you don't mind.  :)  All code examples are from
> mm/memory.c.
> 
> This seems to imply datain means 'read access':
> 	int datain = (rw == READ);
> 
> And then we pass 'datain' as the 'write_access' arg of handle_mm_fault:
> 	if (handle_mm_fault(current->mm, vma, ptr, datain) <= 0)

Yes.  The kernel often has to make these checks the non-intuitive way
round, because a disk or network read IO actually involves write to
memory, but a write IO only has to read from memory.  The convention
is that read/write flags which affect IO paths indicate whether we are
writing from backing store, so we have to invert the sense to decide
whether it's a write to memory.

> This seems to further imply datain means 'read access':
> 	if (((datain) && (!(vma->vm_flags & VM_WRITE))) ||

No, because the next line is
				err = -EACCES;
so (rw==READ) and !VM_WRITE is an error --- datain does imply write
access to memory.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
