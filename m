Message-ID: <3B72357E.1BF85B4B@scs.ch>
Date: Thu, 09 Aug 2001 09:02:23 +0200
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: Re: Changes in vm_operations_struct 2.2.x => 2.4.x
References: <3B6A5A52.73D0DC12@scs.ch> <20010809004910.C1200@nightmaster.csn.tu-chemnitz.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ingo,

Thank's for your reply. The details are as follows:
My module allocates a block of memory, and exports that block to user space processes, by registering as a character device and implementing a mmap file operation, so that
user space processes can map that memory block into their virtual address space by calling mmap().

A block of memory may only be mapped through mmap() by one process, subsequent mmap() calls to map that memory block should fail, until the block is no longer mapped into
any processes memory (note, that following fork() calls the block may be mapped into the virtual memory space of several processes simultaneously, but this is OK).

It would have simplified my job, if I could have assumed that a process has either the entire block mapped into it's virtual address space, or that it has none of the block
mapped at all (i.e. there are never fragment's of the block mapped into a process' virtual address space). To ensure that at the time of mapping, I would have checked the
length of the processes memory region (vma->vm_end -vma->vm_start) in the module's mmap() file operation. To prevent partial unmapping of the block, I would have registered
an unmap() vm_area operation with the vm_area_struct in the module's mmap() file operation. The unmap() vm_area operation would have  checked the addr and len parameter, to
detect partial unmappings of the memory block by a user process. In case of a partial unmapping of the memory block, unmap() would have simply sent a SIGKILL to the
process.

Regards
Martin

Ingo Oeser wrote:

> On Fri, Aug 03, 2001 at 10:01:22AM +0200, Martin Maletinsky wrote:
> > Does anyone know the reason why the number of operations in
> > vm_operation_struct has been reduced?
>
> Al Viro reduced it, because nobody used them for several years.
> Nobody complained after removing them, also.
>
> Maybe you can explain more, what you try to do in your module and
> people can help you.
>
> Regards
>
> Ingo Oeser
> -
> Kernelnewbies: Help each other learn about the Linux kernel.
> Archive:       http://mail.nl.linux.org/kernelnewbies/
> IRC Channel:   irc.openprojects.net / #kernelnewbies
> Web Page:      http://www.kernelnewbies.org/

--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
