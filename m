Date: Mon, 8 Jan 2001 12:29:41 -0600
From: Timur Tabi <ttabi@interactivesi.com>
Subject: iounmap causes Oops and Aiees
Message-Id: <20010108182707Z131177-222+78@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(sorry if this is a repost - but I haven't been seeing my posts to this or the
linux-kernel mailing lists)

I'm using 2.2.18pre15 on an i386, and the following code causes my system to be
very unstable:

unsigned long phys = virt_to_phys(high_memory) - (2 * PAGE_SIZE);
mem_map_t *mm = mem_map + MAP_NR(phys);
unsigned long flags = mm->flags;

mm->flags |= PG_reserved;
p = ioremap_nocache(phys, PAGE_SIZE);
mm->flags = flags;
ASSERT(p);
if (p) iounmap(p);


The code is located in the init_module section of my driver.  It executes
without any problems.  However, after the driver is loaded (it doesn't do
anything but run this code), the system rapidly becomes unstable.  Symptoms are
random and include:

1. Inability to log in (login prompt doesn't respond after I type in a userid)
2. Attempting to shut down always causes an oops
3. Various kernel panics, including the "Aieee" kind.

I must be forgetting to do something critical, probably because what I'm trying
to do is not well documented but apparently supported by the kernel.  I make
that assumption because of this code fragment in function __ioremap of
arch/i386/mm/ioremap.c:

	if (phys_addr < virt_to_phys(high_memory))
           {
		char *temp_addr, *temp_end;
		int i;

		temp_addr = __va(phys_addr);
		temp_end = temp_addr + (size - 1);
	      
		for(i = MAP_NR(temp_addr); i < MAP_NR(temp_end); i++) {
			if(!PageReserved(mem_map + i))
				return NULL;
		}
	   }

As long as every page is marked as reserved, ioremap_nocache() will map the
page.  My question is: why does iounmap fail when ioremap succeeds?


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
