Date: Mon, 8 Nov 1999 13:43:25 +0200
From: "Arkadi E. Shishlov" <arkadi@it.lv>
Subject: IO mappings; verify_area() on SMP
Message-ID: <19991108134325.A589@it.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


  Hi.
  If it is not good place to ask, direct me to the right place, please.

  Some times ago I wrote driver for 2.0 series of kernel. It was
  primitive - no memory based IO, don't concerned about SMP case,
  and so on. But it give me understanding of character drivers basics.

  Now I'm trying to write driver for hardware device that heavily use
  main memory for data exchange. Architecture is i386 and device is
  on ISA. But in future, I want this driver to work on other architectures
  too and device will become PCI card to overcome 16Mb ISA barrier.

  For IO, device use many memory chunks that are linked together using
  classical structure - one-way linked list - ptr->data, ptr->next.
  I'm in stuck about how driver can supply a pointer on data structure
  to the device. I will try to explain on examples.

  For first step, I don't use kmalloc() - I simply boot my 128Mb box
  with mem=120M parameter. And then I created test module:

int init_module(void)
{

	uint base;
	uint base2;
	uint base3;


	printk("----------\n");
	base = (uint)ioremap_nocache(0xB0000000, 1024*1024);
	printk("%08X, %08X\n", base, (int)virt_to_phys((void*)base));

	base2 = (uint)ioremap_nocache(0xD0000000, 1024*1024);
	printk("%08X, %08X\n", base2, (int)virt_to_phys((void*)base2));

	base3 = (uint)ioremap_nocache(0x07900000, 1024*1024);
	printk("%08X, %08X\n", base3, (int)virt_to_phys((void*)base3));

	if (base) iounmap((void*)base);
	if (base2) iounmap((void*)base2);
	if (base3) iounmap((void*)base3);


	return(0);
}

  I know, that virt_to_phys() is equivalent to virt_to_bus() on i386.
  Output:

C806D000, 0806D000
C816E000, 0816E000
C826F000, 0826F000

  In last case, bus address according to virt_to_bus() is 0x0826F000,
  but device will see this region of memory at 0x07900000. Definitely
  not what I want. I read Documentation/IO-mapping.txt. Very strange.
  Likely I misunderstand something. At this point of time I think
  this way:

  hwbase = 0x07900000;
  base = ioremap_nocache(hwbase, 1024*1024);
  data_ptr = base + 100;
  data = base + 104;
  data_addr_for_controller = hwbase + (data - base);
  *(uint*)data_ptr = data_addr_for_controller;

  Instead of playing with virt_to_bus() and memcpy_to_io(), there is
  pointer arithmetics every time. Is it right or not?
  OK. Maybe I'm wrong. I mix ioremap() and main memory access. Not very
  clever. But, read further, please.

  Next step - memory are allocated by kmalloc(). Now driver don't know
  hwbase... How it should work? How this magic ptr = kmalloc() can
  be translated to raw bus address, that driver can give to controller?
  Will virt_to_bus() work?

  Also some miscellaneous questions:
  Does memory allocated with one call to kmalloc(), will be always
  physically contiguous (in future)?
  What is about Intel 64Gb PAE extension - how device drivers should
  deal with it?

  Second question is about verify_area() safety. Many drivers contain
  following sequence:

  if ((ret = verify_area(VERIFY_WRITE, buffer, count)))
	    return r;
  ...
  copy_to_user(buffer, driver_data_buf, count);

  Even protected by cli()/sti() pairs, why multithreaded program on
  SMP machine can't unmap this verified buffer between calls to
  verify_area() and copy_to_user()? Of course it can't be true, but
  maybe somebody can write two-three words about reason that prevent
  this situation.


arkadi.
-- 
Just arms curvature radius.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
