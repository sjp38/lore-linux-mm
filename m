Date: Thu, 26 Feb 2004 22:46:51 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: mapped page in prep_new_page()..
Message-ID: <Pine.LNX.4.58.0402262230040.2563@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hmm.. I've never seen this before myself, but I know there have been
similar reports. Earlier today I got

	Bad page state at prep_new_page
	flags:0x00000000 mapping:0000000000000000 mapped:1 count:0
	Backtrace:
	Call Trace:
	[c000000000075fe4] .prep_new_page+0x5c/0x98
	[c000000000076604] .buffered_rmqueue+0x130/0x1e8
	[c0000000000767a4] .__alloc_pages+0xe8/0x420
	[c000000000076b18] .__get_free_pages+0x3c/0xa0
	[c00000000007b020] .cache_grow+0x128/0x644
	[c00000000007b7c8] .cache_alloc_refill+0x28c/0x338
	[c00000000007bc94] .kmem_cache_alloc+0x70/0x74
	[c0000000000f377c] .ext3_alloc_inode+0x24/0x64
	[c0000000000bbab4] .alloc_inode+0x48/0x138
	[c0000000000bcc5c] .get_new_inode_fast+0x38/0x15c
	[c0000000000ef67c] .ext3_lookup+0xb0/0x14c
	[c0000000000ad050] .real_lookup+0x18c/0x1f4
	[c0000000000ad4f4] .do_lookup+0xe8/0x108
	[c0000000000adbfc] .link_path_walk+0x6e8/0xc88
	[c0000000000ae928] .__user_walk+0x78/0x98
	[c0000000000a7a74] .vfs_lstat+0x24/0x74
	[c0000000000cf378] .compat_sys_newlstat+0x1c/0x5c
	[c000000000011964] .ret_from_syscall_1+0x0/0xa4
	Trying to fix it up, but a reboot is needed

which I didn't even notice initially (it happened at 4:04 AM, apparently 
during the nigthly cron run). Now, it claims to try to fix things up, but 
for "page_mapped(page)" that isn't true - it leaves the page pte pointers 
alone (it should probably clear the rmap list).

So once the machine needed memory (12 hours later - the thing has 2GB of
RAM in it, so it was in no hurry) I got another message at
kmem_cache_free:

	Bad page state at free_hot_cold_page
	kernel: flags:0x00000000 mapping:0000000000000000 mapped:1 count:0
	Backtrace:
	Call Trace:
	[c0000000000763f0] .free_hot_cold_page+0xcc/0x1a0
	[c00000000007a130] .slab_destroy+0x1e0/0x2a4
	..

and soon afterwards the same page got re-used for a page cache 
page, and that makes it really unhappy:

	Bad page state at prep_new_page
	flags:0x00000000 mapping:0000000000000000 mapped:1 count:0
	Backtrace:
	Call Trace:
	[c000000000075fe4] .prep_new_page+0x5c/0x98
	[c000000000076604] .buffered_rmqueue+0x130/0x1e8
	[c0000000000767a4] .__alloc_pages+0xe8/0x420
	[c000000000086e04] .do_anonymous_page+0x1a8/0x50c
	[c000000000087204] .do_no_page+0x9c/0x570
	[c0000000000879b0] .handle_mm_fault+0x1b0/0x26c
	[c0000000000431c8] .do_page_fault+0x120/0x3f8
	[c00000000000aa94] stab_bolted_user_return+0x118/0x11c
	Trying to fix it up, but a reboot is needed

	Oops: Kernel access of bad area, sig: 11 [#1]
	SMP NR_CPUS=2 
	NIP: C00000000008D7C4 XER: 0000000020000000 LR: C000000000086F70
	REGS: c00000007a43b7f0 TRAP: 0300    Not tainted
	MSR: 9000000000009032 EE: 1 PR: 0 FP: 0 ME: 1 IR/DR: 11
	DAR: 0000005f00000008, DSISR: 0000000040000000
	TASK: c000000059819b20[8510] 'bk' THREAD: c00000007a438000 CPU: 0
	GPR00: 0000000000000000 C00000007A43BA70 C0000000006AD0D0 C000000000FFFFC0 
	GPR04: C00000002CBC30F0 C000000032F2F200 C000000002FD64D0 C0000000004D8050 
	GPR08: 0000000002AFE480 0000000000000000 0000005F00000000 0000000000000004 
	GPR12: 0000000042008488 C0000000004E0000 0000000002000000 0000000011A1E004 
	GPR16: C00000005EC23400 0000000000000050 C000000054447000 4000000000000000 
	GPR20: C0000000005714C8 C0000000006F6B80 0000000000001580 C000000032F2F200 
	GPR24: 0000000000532000 0000000000000532 C00000000072FFB8 C000000000FFFFC0 
	GPR28: CCCCCCCCCCCCCCCD 00000001A88C0397 C000000000586978 C00000002CBC30F0 
	NIP [c00000000008d7c4] .page_add_rmap+0xb4/0x1b4
	LR [c000000000086f70] .do_anonymous_page+0x314/0x50c
	Call Trace:
	[c000000000087204] .do_no_page+0x9c/0x570
	[c0000000000879b0] .handle_mm_fault+0x1b0/0x26c
	[c0000000000431c8] .do_page_fault+0x120/0x3f8
	[c00000000000aa94] stab_bolted_user_return+0x118/0x11c

So I've obviously got two questions:
 - shouldn't we try to clear the rmap list in bad_page() too?
 - does anybody have any idea why the page had been left mapped when 
   free'd, without the test triggering in free_pages_check()? Memory 
   corruption? Has anybody ever seen any pattern to this?

Ideas?

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
