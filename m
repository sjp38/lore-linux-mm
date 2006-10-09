Message-ID: <452A8AC6.2080203@tungstengraphics.com>
Date: Mon, 09 Oct 2006 19:45:42 +0200
From: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
MIME-Version: 1.0
Subject: Re: Driver-driven paging?
References: <452A68E9.3000707@tungstengraphics.com> <452A7AD3.5050006@yahoo.com.au>
In-Reply-To: <452A7AD3.5050006@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> Thomas Hellstrom wrote:
>
>> Hi!
>>
>> While trying to put together an improved graphics memory manager in 
>> the DRM kernel module, I've identified a need to swap out backing 
>> store pages which haven't been in use for a while, and I was 
>> wondering if there is a kernel mm API to do that?
>>
>> Basically when a graphics object is created, space is allocated 
>> either in on-card video RAM or in a backup object in system RAM. That 
>> backup object can optionally be flipped into the AGP aperture for 
>> fast and linear graphics card access.
>>
>> What I want to do is to be able to release backup object pages while 
>> maintaining the contents. Basically hand them over to the swapping 
>> system and get a handle back that can be used for later retrieval. 
>> The driver will unmap all mappings referencing the page before 
>> handing it over to the swapping system.
>>
>> Is there an API for this and is there any chance of getting it exported?
>
>
> I suspect you will run into a few troubles trying to do it all in kernel.
> It might be possible, but probably not with the current code, and it
> isn't clear we'd want to make the required changes to support such a
> thing.
>
> Your best bet might be to have a userspace "memory manager" process, 
> which
> allocates pages (anonymous or file backed), and has your device driver
> access them with get_user_pages. The get_user_pages takes care of 
> faulting
> the pages back in, and when they are released, the memory manager will
> swap them out on demand.
>
Hi!

I was actually thinking of something similar, but I thought it would be 
cleaner to do it in the kernel, if the API were there. But currently the 
DRM needs a "master" user-space process anyway so it's a feasible way to go.

> If you need for the driver to *then* export these pages out to be mapped
> by other processes in userspace, I think you run into problems if trying
> to use nopage. You'll need to go the nopfn route (and thus your mappings
> must disallow PROT_WRITE && MAP_PRIVATE).
>
> But I think that might just work?
>
Yes, possibly. What kind of problems would I expect if using nopage? Is 
it, in particular, legal for a process to call get_user_pages() with the 
tsk and mm arguments of another process?

Thanks,

Thomas



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
