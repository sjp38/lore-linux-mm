Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4BED66B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:51:20 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id x125so28798005pfb.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 11:51:20 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id m5si18698581pfi.231.2016.01.28.11.51.18
        for <linux-mm@kvack.org>;
        Thu, 28 Jan 2016 11:51:19 -0800 (PST)
Date: Thu, 28 Jan 2016 12:51:07 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: mm: WARNING in __delete_from_page_cache
Message-ID: <20160128195107.GA26378@linux.intel.com>
References: <CACT4Y+aBnm8VLe5f=AwO2nUoQZaH-UVqUynGB+naAC-zauOQsQ@mail.gmail.com>
 <20160124230422.GA8439@node.shutemov.name>
 <20160125122206.GA24938@quack.suse.cz>
 <1453779754.32645.3.camel@intel.com>
 <20160126125456.GK2948@linux.intel.com>
 <20160126133636.GE23820@quack.suse.cz>
 <1453827566.32645.5.camel@intel.com>
 <20160127220421.GA6634@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160127220421.GA6634@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>, "jack@suse.cz" <jack@suse.cz>, "willy@linux.intel.com" <willy@linux.intel.com>, "syzkaller@googlegroups.com" <syzkaller@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kcc@google.com" <kcc@google.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "dvyukov@google.com" <dvyukov@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "gthelen@google.com" <gthelen@google.com>, "kirill@shutemov.name" <kirill@shutemov.name>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "jack@suse.com" <jack@suse.com>, "glider@google.com" <glider@google.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "j-nomura@ce.jp.nec.com" <j-nomura@ce.jp.nec.com>

On Wed, Jan 27, 2016 at 03:04:21PM -0700, Ross Zwisler wrote:
> On Tue, Jan 26, 2016 at 04:59:27PM +0000, Williams, Dan J wrote:
> > 8<---- (git am --scissors)
> > Subject: fs, block: force direct-I/O for dax-enabled block devices
> > 
> > From: Dan Williams <dan.j.williams@intel.com>
> > 
> > Similar to the file I/O path, re-direct all I/O to the DAX path for I/O
> > to a block-device special file.  Both regular files and device special
> > files can use the common filp->f_mapping->host lookup to determing is
> > DAX is enabled.
> > 
> > Otherwise, we confuse the DAX code that does not expect to find live
> > data in the page cache:
> > 
> >     ------------[ cut here ]------------
> >     WARNING: CPU: 0 PID: 7676 at mm/filemap.c:217
> >     __delete_from_page_cache+0x9f6/0xb60()
> >     Modules linked in:
> >     CPU: 0 PID: 7676 Comm: a.out Not tainted 4.4.0+ #276
> >     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> >      00000000ffffffff ffff88006d3f7738 ffffffff82999e2d 0000000000000000
> >      ffff8800620a0000 ffffffff86473d20 ffff88006d3f7778 ffffffff81352089
> >      ffffffff81658d36 ffffffff86473d20 00000000000000d9 ffffea0000009d60
> >     Call Trace:
> >      [<     inline     >] __dump_stack lib/dump_stack.c:15
> >      [<ffffffff82999e2d>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
> >      [<ffffffff81352089>] warn_slowpath_common+0xd9/0x140 kernel/panic.c:482
> >      [<ffffffff813522b9>] warn_slowpath_null+0x29/0x30 kernel/panic.c:515
> >      [<ffffffff81658d36>] __delete_from_page_cache+0x9f6/0xb60 mm/filemap.c:217
> >      [<ffffffff81658fb2>] delete_from_page_cache+0x112/0x200 mm/filemap.c:244
> >      [<ffffffff818af369>] __dax_fault+0x859/0x1800 fs/dax.c:487
> >      [<ffffffff8186f4f6>] blkdev_dax_fault+0x26/0x30 fs/block_dev.c:1730
> >      [<     inline     >] wp_pfn_shared mm/memory.c:2208
> >      [<ffffffff816e9145>] do_wp_page+0xc85/0x14f0 mm/memory.c:2307
> >      [<     inline     >] handle_pte_fault mm/memory.c:3323
> >      [<     inline     >] __handle_mm_fault mm/memory.c:3417
> >      [<ffffffff816ecec3>] handle_mm_fault+0x2483/0x4640 mm/memory.c:3446
> >      [<ffffffff8127eff6>] __do_page_fault+0x376/0x960 arch/x86/mm/fault.c:1238
> >      [<ffffffff8127f738>] trace_do_page_fault+0xe8/0x420 arch/x86/mm/fault.c:1331
> >      [<ffffffff812705c4>] do_async_page_fault+0x14/0xd0 arch/x86/kernel/kvm.c:264
> >      [<ffffffff86338f78>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:986
> >      [<ffffffff86336c36>] entry_SYSCALL_64_fastpath+0x16/0x7a
> >     arch/x86/entry/entry_64.S:185
> >     ---[ end trace dae21e0f85f1f98c ]---
> > 
> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > Fixes: 5a023cdba50c ("block: enable dax for raw block devices")
> > Reported-by: Dmitry Vyukov <dvyukov@google.com>
> > Reported-by: Kirill A. Shutemov <kirill@shutemov.name>
> > Suggested-by: Jan Kara <jack@suse.cz>
> > Reviewed-by: Jan Kara <jack@suse.cz>
> > Suggested-by: Matthew Wilcox <willy@linux.intel.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> 
> I had a test case where I was hitting a warning while inserting into the page
> cache when the inode was supposed to be DAX, and this clears up my issue as
> well.
> 
> Tested-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> > ---
> >  include/linux/fs.h |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 1a2046275cdf..b10002d4a5f5 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -2907,7 +2907,7 @@ extern void replace_mount_options(struct super_block *sb, char *options);
> >  
> >  static inline bool io_is_direct(struct file *filp)
> >  {
> > -	return (filp->f_flags & O_DIRECT) || IS_DAX(file_inode(filp));
> > +	return (filp->f_flags & O_DIRECT) || IS_DAX(filp->f_mapping->host);
> >  }
> >  
> >  static inline int iocb_flags(struct file *file)

My testing has turned up another case where we can end up doing both page
cache I/O and DAX I/O to the same raw block device.  Here is the stack trace
of the error, passed through kasan_symbolize.py:

------------[ cut here ]------------                                            
WARNING: CPU: 1 PID: 598 at mm/filemap.c:590 __add_to_page_cache_locked+0x30d/0x3c0()
Modules linked in: nd_pmem nd_btt nd_e820 libnvdimm                             
CPU: 1 PID: 598 Comm: systemd-udevd Tainted: G        W       4.5.0-rc1+ #1     
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150714_191134- 04/01/2014
 0000000000000000 0000000001e02977 ffff88040ff9fa88 ffffffff81576db2            
 0000000000000000 ffff88040ff9fac0 ffffffff810a65a2 ffff8804103d9020            
 0000000000000000 ffff8804103d9008 00000000ffffffea ffffea0002ebf080            
Call Trace:                                                                     
 [<     inline     >] __dump_stack lib/dump_stack.c:15                          
 [<ffffffff81576db2>] dump_stack+0x44/0x62 lib/dump_stack.c:50                  
 [<ffffffff810a65a2>] warn_slowpath_common+0x82/0xc0 kernel/panic.c:482         
 [<ffffffff810a66ea>] warn_slowpath_null+0x1a/0x20 kernel/panic.c:515           
 [<     inline     >] page_cache_tree_insert mm/filemap.c:590                   
 [<ffffffff811ca32d>] __add_to_page_cache_locked+0x30d/0x3c0 mm/filemap.c:649   
 [<ffffffff811ca449>] add_to_page_cache_lru+0x49/0xd0 mm/filemap.c:697          
 [<     inline     >] __read_cache_page mm/filemap.c:2300                       
 [<ffffffff811ca87b>] do_read_cache_page+0x6b/0x300 mm/filemap.c:2330           
 [<ffffffff811cab2c>] read_cache_page+0x1c/0x20 mm/filemap.c:2377               
 [<     inline     >] read_mapping_page include/linux/pagemap.h:391             
 [<ffffffff81558d74>] read_dev_sector+0x34/0xf0 block/partition-generic.c:558   
 [<     inline     >] read_part_sector block/partitions/check.h:37              
 [<ffffffff81560c4e>] read_lba+0x18e/0x290 block/partitions/efi.c:264           
 [<     inline     >] find_valid_gpt block/partitions/efi.c:610                 
 [<ffffffff81561542>] efi_partition+0xf2/0x7d0 block/partitions/efi.c:692       
 [<ffffffff8155b47e>] check_partition+0x13e/0x220 block/partitions/check.c:166  
 [<ffffffff81559670>] rescan_partitions+0xc0/0x2b0 block/partition-generic.c:434
 [<ffffffff81553aeb>] __blkdev_reread_part+0x6b/0xa0 block/ioctl.c:171          
 [<ffffffff81553b45>] blkdev_reread_part+0x25/0x40 block/ioctl.c:191            
 [<ffffffff815547b9>] blkdev_ioctl+0x5a9/0xab0 block/ioctl.c:624                
 [<ffffffff812a2303>] block_ioctl+0x43/0x50 fs/block_dev.c:1624                 
 [<     inline     >] vfs_ioctl fs/ioctl.c:43                                   
 [<ffffffff81274452>] do_vfs_ioctl+0xa2/0x6a0 fs/ioctl.c:674                    
 [<     inline     >] SYSC_ioctl fs/ioctl.c:689                                 
 [<ffffffff81274ac9>] SyS_ioctl+0x79/0x90 fs/ioctl.c:680                        
 [<ffffffff81a6a732>] entry_SYSCALL_64_fastpath+0x12/0x76 arch/x86/entry/entry_64.S:185
---[ end trace 96171b39eee8b31b ]---   

Here is my minimal reproducer:

#define _GNU_SOURCE                                                             
#include <sys/mman.h>                                                           
#include <sys/types.h>                                                          
#include <sys/stat.h>                                                           
#include <fcntl.h>                                                              
#include <linux/falloc.h>                                                       
#include <stdio.h>                                                              
#include <string.h>                                                             
#include <errno.h>                                                              
#include <unistd.h>                                                             
                                                                                
#define PAGE(a) ((a)*0x1000)                                                    
                                                                                
int main(int argc, char *argv[])                                                
{                                                                               
        int i, fd;                                                              
        char *data_array = (char*) 0x10200000; /* request a 2MiB aligned address with mmap() */
        int a;                                                                  
                                                                                
        fd = open("/dev/pmem0", O_RDWR);                                        
        if (fd < 0) {                                                           
                perror("fd");                                                   
                return 1;                                                       
        }                                                                       
                                                                                
        data_array = mmap(data_array, PAGE(0x300), PROT_READ|PROT_WRITE,        
                        MAP_SHARED, fd, PAGE(0));                               
                                                                                
        data_array[PAGE(0x0)] = 1;                                              
        close(fd);                                                              
        return 0;                                                               
} 

I believe what is happening is that I am doing a DAX PMD fault, and that fault
is happening at the same time that an IOCTL is doing a scan for partition
tables.  The above stack trace is for a scan of an efi_partition(), but I get a
similar stack trace going through sgi_partition(), ldm_partition(),
msdos_partition(), etc.  This looping is happening in check_partition(), as it
loops through the various partition types.

I think the issue essentially is that the partition scanning code doesn't have
a direct I/O code path, at least from what I have found.  This means that it's
not calling into DAX, and instead is just using the page cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
