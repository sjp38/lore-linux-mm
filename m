Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9EB900139
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 11:05:54 -0400 (EDT)
Subject: bade page state while calling munmap() for kmalloc'ed UIO memory
From: Jan Altenberg <jan@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 29 Aug 2011 17:05:47 +0200
Message-ID: <1314630347.2258.150.camel@bender.lan>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Hans J. Koch" <hjk@hansjkoch.de>, b.spranger@linutronix.de

Hi,

I'm currently analysing a problem similar to some mmap() issue reported
in the past: https://lkml.org/lkml/2010/7/11/140

So, what I'm trying to do is mapping some physically continuous memory
(allocated by kmalloc) to userspace, using a trivial UIO driver (the
idea is that a device can directly DMA to that buffer):

[...]
#define MEM_SIZE (4 * PAGE_SIZE)

addr = kmalloc(MEM_SIZE, GFP_KERNEL)
[...]
info.mem[0].addr = (unsigned long) addr;
info.mem[0].internal_addr = addr;
info.mem[0].size = MEM_SIZE;
info.mem[0].memtype = UIO_MEM_LOGICAL;
[...]
ret = uio_register_device(&pdev->dev, &info);

Userspace maps that memory range and writes its contents to a file:

[...]

fd = open("/dev/uio0", O_RDWR);
if (fd < 0) {
           perror("Can't open UIO device\n");
           exit(1);
}

mem_map = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE,
                  MAP_PRIVATE, fd, 0);

if(mem_map == MAP_FAILED) {
           perror("Can't map UIO memory\n");
           ret = -ENOMEM;
           goto out_file;
}
[...]
bytes_written = write(fd_file, mem_map, MAP_SIZE)
[...]

munmap(mem_map);

So, what happens is (I'm currently testing with 3.0.3 on ARM
VersatilePB): When I do the munmap(), I run into the following error:

BUG: Bad page state in process uio_test  pfn:078ed
page:c0409154 count:0 mapcount:0 mapping:  (null) index:0x0
page flags: 0x284(referenced|slab|arch_1)
[<c0033e50>] (unwind_backtrace+0x0/0xe4) from [<c0079938>] (bad_page+0xcc/0xf8)
[<c0079938>] (bad_page+0xcc/0xf8) from [<c007a5f0>] (free_pages_prepare+0x6c/0xcc)
[<c007a5f0>] (free_pages_prepare+0x6c/0xcc) from [<c007a778>] (free_hot_cold_page+0x20/0x18c)
[<c007a778>] (free_hot_cold_page+0x20/0x18c) from [<c008ccb4>] (unmap_vmas+0x338/0x564)
[<c008ccb4>] (unmap_vmas+0x338/0x564) from [<c008f0f4>] (unmap_region+0xa4/0x1e0)
[<c008f0f4>] (unmap_region+0xa4/0x1e0) from [<c0090428>] (do_munmap+0x20c/0x274)
[<c0090428>] (do_munmap+0x20c/0x274) from [<c00904cc>] (sys_munmap+0x3c/0x50)
[<c00904cc>] (sys_munmap+0x3c/0x50) from [<c002e680>] (ret_fast_syscall+0x0/0x2c)
Disabling lock debugging due to kernel taint
BUG: Bad page state in process uio_test  pfn:078ee
page:c0409178 count:0 mapcount:0 mapping:  (null) index:0x0
page flags: 0x284(referenced|slab|arch_1)
[<c0033e50>] (unwind_backtrace+0x0/0xe4) from [<c0079938>] (bad_page+0xcc/0xf8)
[<c0079938>] (bad_page+0xcc/0xf8) from [<c007a5f0>] (free_pages_prepare+0x6c/0xcc)
[<c007a5f0>] (free_pages_prepare+0x6c/0xcc) from [<c007a778>] (free_hot_cold_page+0x20/0x18c)
[<c007a778>] (free_hot_cold_page+0x20/0x18c) from [<c008ccb4>] (unmap_vmas+0x338/0x564)
[<c008ccb4>] (unmap_vmas+0x338/0x564) from [<c008f0f4>] (unmap_region+0xa4/0x1e0)
[<c008f0f4>] (unmap_region+0xa4/0x1e0) from [<c0090428>] (do_munmap+0x20c/0x274)
[<c0090428>] (do_munmap+0x20c/0x274) from [<c00904cc>] (sys_munmap+0x3c/0x50)
[<c00904cc>] (sys_munmap+0x3c/0x50) from [<c002e680>] (ret_fast_syscall+0x0/0x2c)
BUG: Bad page state in process uio_test  pfn:078ef
page:c040919c count:0 mapcount:0 mapping:  (null) index:0x0
page flags: 0x284(referenced|slab|arch_1)
[<c0033e50>] (unwind_backtrace+0x0/0xe4) from [<c0079938>] (bad_page+0xcc/0xf8)
[<c0079938>] (bad_page+0xcc/0xf8) from [<c007a5f0>] (free_pages_prepare+0x6c/0xcc)
[<c007a5f0>] (free_pages_prepare+0x6c/0xcc) from [<c007a778>] (free_hot_cold_page+0x20/0x18c)
[<c007a778>] (free_hot_cold_page+0x20/0x18c) from [<c008ccb4>] (unmap_vmas+0x338/0x564)
[<c008ccb4>] (unmap_vmas+0x338/0x564) from [<c008f0f4>] (unmap_region+0xa4/0x1e0)
[<c008f0f4>] (unmap_region+0xa4/0x1e0) from [<c0090428>] (do_munmap+0x20c/0x274)
[<c0090428>] (do_munmap+0x20c/0x274) from [<c00904cc>] (sys_munmap+0x3c/0x50)
[<c00904cc>] (sys_munmap+0x3c/0x50) from [<c002e680>] (ret_fast_syscall+0x0/0x2c)

This happens for every page except the first one. If I change the code
and just touch the first page, everything's working fine. As soon as I
touch one of the other pages, I can see the "bad page state error" for
that page. The kernel is currently built using CONFIG_SLAB (my .config
is based on the versatile_defconfig); if I change to CONFIG_SLUB,
munmap() seems to be happy and I can't see the "bad page state" error.

Any idea what might be wrong here? Am I missing something obvious? (I've
prepared some brown paperbags for that case ;-))

Thanks,
	Jan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
