Message-ID: <3CAC3E85.2040304@earthlink.net>
Date: Thu, 04 Apr 2002 11:52:37 +0000
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: Memory allocation in Linux (fwd)
References: <Pine.LNX.4.21.0204041258240.24668-100000@mailhost.tifr.res.in>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Amit S. Jain" <amitjain@tifr.res.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Amit S. Jain wrote:

> This was the message I had posted in March expecting some help from the
> Masters in Linux-mm...however there was no response...hope someone can
> respond to it now.. Pleasse.....and if u do could you please CC the
> message to my e-mail address...


Well, I may not be telling you anything you don't already
know, but at least here's a reply :-)

>  Hello everyone,
>                I am confused about the concept of memory allocation in
> Linux and hope u all can please clear this.
> Obtaining large amount of continuous memory from the kernel is not a
> good practice and is also not possible.However,as far as non-contiguous
> memory is concerned ...cant those be obtained in huge amounts (I am talkin
> in terms of MB).Using get_free_pages or vmalloc cant large amounts of
> memory be obtained.I tried doing this but I got continuous message ssayin
> PCI bus error 2290...wass this bout???ne idea. 


get_free_pages() allocates physically contiguous RAM of the
requested size (2^order pages). You can get lots of
non-physically-contiguous memory by calling get_free_pages()
many times with order=0.

vmalloc() does just that, and maps the resulting pages
contiguously into kernel virtual memory. However, vmalloc()
can only map pages into kernel addresses that are not
already in use, and in a machine with lots of RAM most of the
kernel's virtual address space is occupied by 1-1 mapping
of physical RAM. So you may be running into that problem,
depending on how much RAM is in the machine. And of
course other users of vmalloc() may fragment the
kernel's virtual space and make allocation of very large
blocks impossible.

I don't know why you would be getting "PCI bus error 2290",
sorry...


> Also,I will be highly obliged if you could refer a good document which can
> gimme a good explaination bout mmap function.I basically want to obtain
> zero copy from the user area straigt to the network interface without any
> copies in the kernel area. kiobuff can provide one such interface,however
> I also want to try using mmap....so please could u refer me some good

> document.   


(I can't comment on this.)

Cheers,

-- Joe
   Using open-source software: free.
   Pissing Bill Gates off: priceless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
