Message-ID: <478CF30F.1010100@qumranet.com>
Date: Tue, 15 Jan 2008 19:53:19 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] mmu notifiers
References: <20080109181908.GS6958@v2.random>	<Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com>	<47860512.3040607@qumranet.com>	<Pine.LNX.4.64.0801101103470.20353@schroedinger.engr.sgi.com>	<47891A5C.8060907@qumranet.com>	<Pine.LNX.4.64.0801141148540.8300@schroedinger.engr.sgi.com>	<478C62F8.2070702@qumranet.com> <Pine.LNX.4.64.0801150938260.9893@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0801150938260.9893@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>, Andrea Arcangeli <andrea@qumranet.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 15 Jan 2008, Avi Kivity wrote:
>
>   
>>> Duh. Impossible. Two instances of Linux cannot share page structs. So how
>>> are you doing this? Or is this just an idea?
>>>       
>> I was describing one Linux host running two guest instances.  The page structs
>> are in the host, so they are shared by mmap().
>>     
>
> Ahh.. Okay I was talking about a guest exporting its memory to another 
> guest.
>   

That's not very different, if they are on the same host?

>  
>   
>> kvm userspace is just an ordinary host process, it can mmap() any file it
>> likes and then assign that virtual memory range to the guest (as guest
>> physical memory).
>>     
>
> But then the guest does not have its own page struct to manage the memory.
>
>   

Why not?  It's just a block of memory as far as the guest is concerned.  
It's entirely up to it whether to create page structs or not.

Example:

qemu 1:

   p = mmap("/dev/shm/blah", size, ... );
   ioctl(vm_fd, KVM_CREATE_MEMORY_REGION_USER, { p, size, 0x10000000, 
... });

qemu 2:

   p = mmap("/dev/shm/blah", size, ... );
   ioctl(vm_fd, KVM_CREATE_MEMORY_REGION_USER, { p, size, 0x10000000, 
... });

Physical address 0x10000000, of both guests, would map to the same page.

Of course, ordinary Linux kernels can't do much with memory that is 
shared with another guest.

I've a feeling we need a whiteboard.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
