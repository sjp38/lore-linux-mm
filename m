From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003081823.KAA26235@google.engr.sgi.com>
Subject: Re: Shrinking stack
Date: Wed, 8 Mar 2000 10:23:48 -0800 (PST)
In-Reply-To: <Pine.LNX.3.95.1000308170518.465B-100000@ppp-pat141.tee.gr> from "Stelios Xanthakis" at Mar 08, 2000 05:06:02 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: axanth@tee.gr
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> The stack space will remain at 400kB even if the rest of the program only
> needs up to 10kB. (I have a patch to view the unused stack through /proc)

Only if you ever touch the stack page, will it be allocated. Else, no
physical page is associated. And if the kernel runs low on memory, it
will reclaim rarely accessed pages.

> I've implemented a patch where the kernel provides the vma->vm_start of
> the stack area through prctl() syscall. Its very simple and adds very
> little to the kernel code.

I believe there is only one foolproof method of determing the stack.
And that is by looking at the user's esp. (Programs probably might
have multiple stack segments, maybe even switch between them by  
modifying esp ... in extreme cases. Not sure how pthreads work in 
this respect.) 

Thus, instead of having the kernel do this, you can do this in
userland by getting /proc/pid/maps, then identifying the vma that
contains the current value of esp. (To get the esp, you can either 
write processor specific code, or maybe get the address of a variable
on stack). 

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
