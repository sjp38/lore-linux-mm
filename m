Date: Mon, 14 Apr 2008 14:58:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: npiggin@suse.de, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

In 2.6.25-rc8-mm2.

I saw below warning at memory offlining. please help.
(ia64/NUMA box with ext3 file system. Almost all memory are free memory.)
==

localhost.localdomain login: ------------[ cut here ]------------
WARNING: at fs/buffer.c:720 __set_page_dirty+0x330/0x360()
Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge ipv6 ipmi_watchdog mptctl ipmi_devintf ipmi_si ipmi_msghandler vfat fat dm_multipath parport_pc lp parport sg tg3 e100 mii button shpchp dm_snapshot dm_zero dm_mirror dm_log dm_mod usb_storage mptspi mptscsih scsi_transport_spi mptbase sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd [last unloaded: ipmi_watchdog]

Call Trace:
 [<a000000100015220>] show_stack+0x80/0xa0
                                sp=e000012027b9fae0 bsp=e000012027b99398
 [<a000000100015270>] dump_stack+0x30/0x60
                                sp=e000012027b9fcb0 bsp=e000012027b99380
 [<a000000100089ed0>] warn_on_slowpath+0x90/0xe0
                                sp=e000012027b9fcb0 bsp=e000012027b99358
 [<a0000001001f8b10>] __set_page_dirty+0x330/0x360
                                sp=e000012027b9fda0 bsp=e000012027b99328
 [<a0000001001ffb90>] __set_page_dirty_buffers+0xd0/0x280
                                sp=e000012027b9fda0 bsp=e000012027b992f8
 [<a00000010012fec0>] set_page_dirty+0xc0/0x260
                                sp=e000012027b9fda0 bsp=e000012027b992d0
 [<a000000100195670>] migrate_page_copy+0x5d0/0x5e0
                                sp=e000012027b9fda0 bsp=e000012027b992a8
 [<a000000100197840>] buffer_migrate_page+0x2e0/0x3c0
                                sp=e000012027b9fda0 bsp=e000012027b99260
 [<a000000100195eb0>] migrate_pages+0x770/0xe00
                                sp=e000012027b9fda0 bsp=e000012027b991a8
 [<a000000100191250>] offline_pages+0x6f0/0xa20
                                sp=e000012027b9fdf0 bsp=e000012027b99118
 [<a00000010006b1f0>] remove_memory+0x30/0x60
                                sp=e000012027b9fe20 bsp=e000012027b990f0
 [<a000000100482c50>] memory_block_change_state+0x390/0x400
                                sp=e000012027b9fe20 bsp=e000012027b990a0
 [<a000000100483720>] store_mem_state+0x1e0/0x200
                                sp=e000012027b9fe20 bsp=e000012027b99068
 [<a0000001004718a0>] sysdev_store+0x60/0xa0
                                sp=e000012027b9fe20 bsp=e000012027b99030
 [<a000000100246100>] sysfs_write_file+0x220/0x300
                                sp=e000012027b9fe20 bsp=e000012027b98fd0
 [<a00000010019e2e0>] vfs_write+0x1a0/0x320
                                sp=e000012027b9fe20 bsp=e000012027b98f80
 [<a00000010019edf0>] sys_write+0x70/0xe0
                                sp=e000012027b9fe20 bsp=e000012027b98f08
 [<a00000010000a570>] ia64_trace_syscall+0xd0/0x110
                                sp=e000012027b9fe30 bsp=e000012027b98f08
 [<a000000000010720>] __start_ivt_text+0xffffffff00010720/0x400
                                sp=e000012027ba0000 bsp=e000012027b98f08
==

This comes from fs/buffer.c
==
static int __set_page_dirty(struct page *page,
                struct address_space *mapping, int warn)
{
        if (unlikely(!mapping))
                return !TestSetPageDirty(page);

        if (TestSetPageDirty(page))
                return 0;

        write_lock_irq(&mapping->tree_lock);
        if (page->mapping) {    /* Race with truncate? */
                WARN_ON_ONCE(warn && !PageUptodate(page)); ---------(*)

                if (mapping_cap_account_dirty(mapping)) {
                        __inc_zone_page_state(page, NR_FILE_DIRTY);
                        __inc_bdi_stat(mapping->backing_dev_info,
                                        BDI_RECLAIMABLE);
                        task_io_account_write(PAGE_CACHE_SIZE);
                }
                radix_tree_tag_set(&mapping->page_tree,
                                page_index(page), PAGECACHE_TAG_DIRTY);
        }
        write_unlock_irq(&mapping->tree_lock);
        __mark_inode_dirty(mapping->host, I_DIRTY_PAGES);

        return 1;
}
==
Then, "page" is not Uptodate when it reaches (*).

But, migrate_page() call path is
==
   buffer_migrate_page()
	-> lock all buffers on old pages.
	-> move buffers to newpage.
	-> migrate_page_copy(page, newpage)
		-> set_page_dirty().
	-> unlock all buffers().
==
static void migrate_page_copy(struct page *newpage, struct page *page)
{
        copy_highpage(newpage, page);
<snip>
        if (PageUptodate(page))
                SetPageUptodate(newpage);
<snip>
        if (PageDirty(page)) {
                clear_page_dirty_for_io(page);
                set_page_dirty(newpage);------------------------(**)
        }

==
Then, Uptodate() is copied before set_page_dirty(). 
So, "page" is not Uptodate and Dirty when it reaches (**)

"newpage" has buffers but not dirty and Uptodate().

>From patch comment, http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=787d2214c19bcc9b6ac48af0ce098277a801eded

"It is a bug to set a page dirty if it is not uptodate unless it has
 buffers."

__set_page_dirty() should be following ?
=
if (TestSetPageDirty(page))
	return 0;
if (PagePrivate(page))
	return 0;
if (page->mapping) {
	...
   }
=

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
