Message-ID: <3A706CCF.8010400@valinux.com>
Date: Thu, 25 Jan 2001 11:13:35 -0700
From: Jeff Hartmann <jhartmann@valinux.com>
MIME-Version: 1.0
Subject: Re: ioremap_nocache problem?
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org>
		<20010123165117Z131182-221+34@kanga.kvack.org> ; from ttabi@interactivesi.com on Tue, Jan 23, 2001 at 10:53:51AM -0600 <20010125155345Z131181-221+38@kanga.kvack.org>
		<20010125165001Z132264-460+11@vger.kernel.org> <E14LpvQ-0008Pw-00@mail.valinux.com> <20010125175308Z130507-460+45@vger.kernel.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Timur Tabi wrote:

> ** Reply to message from Jeff Hartmann <jhartmann@valinux.com> on Thu, 25 Jan
> 2001 10:47:13 -0700
> 
> 
> 
>> As in an MMIO aperture?  If its MMIO on the bus you should be able to 
>> just call ioremap with the bus address.  By nature of it being outside 
>> of real ram, it should automatically be uncached (unless you've set an 
>> MTRR over that region saying otherwise).
> 
> 
> It's not outside of real RAM.  The device is inside real RAM (it sits on the
> DIMM itself), but I need to poke through the entire 4GB range to see how it
> responds.
> 
> 
>> Look at the functions agp_generic_free_gatt_table and 
>> agp_generic_create_gatt_table in agpgart_be.c (drivers/char/agp).  They 
>> do the ioremap_nocache on real ram for the GATT/GART table.
> 
> 
> Unfortunately, the memory they remap is allocated:
> 
> table = (char *) __get_free_pages(GFP_KERNEL, page_order);
> 
> ...
> 
> CACHE_FLUSH();
> agp_bridge.gatt_table = ioremap_nocache(virt_to_phys(table), (PAGE_SIZE * (1 <<
> page_order)));
> CACHE_FLUSH();
> 
> I've searched high and low for examples of code that does what I do, and I
> can't find any.

You need to have your driver in the early bootup process then.  When 
memory is being detected (but before the free lists are created.), you 
can set your page as being reserved.  Then the kernel will leave it 
alone when it creates its free lists.  This does mean that this driver 
can not be a module and that it must run at least part of itself in the 
early bootup process.  I don't remember exactly where you need to do 
this, you might try looking at arch/i386/mm/init.c (Just an educated guess.)

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
