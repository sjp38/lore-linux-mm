Date: Thu, 13 Apr 2000 18:59:01 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: A question about pages in stacks
In-Reply-To: <200004132136.XAA01065@agnes.bagneux.maison>
Message-ID: <Pine.LNX.3.96.1000413184149.14199A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: JF Martinez <jfm2@club-internet.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Apr 2000, JF Martinez wrote:

> Will I be flamed if I consider this as a weakness in Linux?  While the
> hardware will notify the kernel only about increasings in the stack
> segment the fact is a page who is in the stack segment but on the
> wrong side of the bottom of the stack is in fact a free page a nd does
> not need to be written to disk.  Unless that it is considered that
> checking for these "false dirty" pages is so slow that it will absorb
> the benefits got from the reduced number of disk writings.

Well, I hope you don't consider this a flame, but let me try to explain
why doing the shrink from the kernel isn't as simple as it might seem: 
first off, vma's and mm_struct's, and hence the stack mapping, aren't
directly connected to the registers of the process being used.  Sure, we
could get around that by walking the list of tasks and examining the
registers of the tasks that use the mapping (although that in itself is
horrible).  Now what do we do if the process is still running on another
CPU?  Do we send an IPI to find out what the stack address is?  Definately
not worth the cost.  Besides, what if the process is temporarily making
use of an alternate stack for signal processing (or something else
internal to the task)?  Implementing this policy heavy optimization for
such a rare case (the stack pages of a typical process are a very small
portion of their memory usage) in the kernel is not worth the
difficulties.

Otoh, it's very easy to implement in userland as a prune_stack() function 
that gets called occasionally from the right place.  As I said in my last
message, see the thread titled "Stack & Policy" in the linux-mm archives
from earlier this month.

		-ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
