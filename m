Message-ID: <3A7066A1.5030608@valinux.com>
Date: Thu, 25 Jan 2001 10:47:13 -0700
From: Jeff Hartmann <jhartmann@valinux.com>
MIME-Version: 1.0
Subject: Re: ioremap_nocache problem?
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org>
		<20010123165117Z131182-221+34@kanga.kvack.org> ; from ttabi@interactivesi.com on Tue, Jan 23, 2001 at 10:53:51AM -0600 <20010125155345Z131181-221+38@kanga.kvack.org>
		<20010125165001Z132264-460+11@vger.kernel.org> <E14LpvQ-0008Pw-00@mail.valinux.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Timur Tabi wrote:

> ** Reply to message from Jeff Hartmann <jhartmann@valinux.com> on Thu, 25 Jan
> 2001 10:04:47 -0700
> 
> 
> 
>>> The problem with this is that between the ioremap and iounmap, the page is
>>> reserved.  What happens if that page belongs to some disk buffer or user
>>> process, and some other process tries to free it.  Won't that cause a problem?
>> 
>> 	The page can't belong to some other process/kernel component.  You own 
>> the page if you allocated it.  
> 
> 
> Ok, my mistake.  I wasn't paying attention to the "get_free_pages" call.  My
> problem is that I'm ioremap'ing someone else's page, but my hardware sits on the
> memory bus disguised as real memory, and so I need to poke around the 4GB space
> trying to find it.

As in an MMIO aperture?  If its MMIO on the bus you should be able to 
just call ioremap with the bus address.  By nature of it being outside 
of real ram, it should automatically be uncached (unless you've set an 
MTRR over that region saying otherwise).

> 
> 
> 
>> (I was the one who added support to 
>> the kernel to ioremap real ram, trust me.)
> 
> 
> I really appreciate that feature, because it helps me a lot.  Any
> recommendations on how I can do what I do without causing any problems?  Right
> now, my driver never calls iounmap on memory that's in real RAM, even when it
> exits.  Fortunately, the driver isn't supposed to exit, so all it does is waste
> a few KB of virtual memory.

Look at the functions agp_generic_free_gatt_table and 
agp_generic_create_gatt_table in agpgart_be.c (drivers/char/agp).  They 
do the ioremap_nocache on real ram for the GATT/GART table.  Heres some 
quick pseudo code as well.

I_want_a_no_cached_page() {
alloc a page
reserve the page
flush every cpu's cache
ioremap_nocache the page
}

I_want_to_free_a_no_cached_page() {
iounmap the page
unreserve the page
free the page
}

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
