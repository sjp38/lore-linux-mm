Date: Wed, 27 Oct 2004 22:40:27 +0900 (JST)
Message-Id: <20041027.224027.100405498.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041026.224550.109999656.taka@valinux.co.jp>
References: <20041026.153731.38067476.taka@valinux.co.jp>
	<20041026092011.GD24462@logos.cnet>
	<20041026.224550.109999656.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi, Marcelo,

Oops has occurred on on my box with the migration cache patch
after the long run. I tested it with Iwamoto's zone hotplug
emulation patch.

There may be some migration cache related bugs there. 
Some pages seem to remain in the migration cache
after page migration.

> +	if (!c->i) {
> +		remove_from_migration_cache(page, page->private);
> +		kfree(c);
> 
> page_cache_release(page) should be invoked here, as the count for
> the migration cache must be decreased.
> With this fix, your migration cache started to work very fine!
> 
> +	}
> +		
> +}

Please take a look at the attached logs.

Some pages might have been put in LRU, and they seems to
have been chosen as target pages to migrate again.
The pages are handled as swap-cache pages accidentally.
And both of the swp_offset in the logs seem to be
very big. This looks like some pages in the migration cache
haven't been released yet.

"swap file entry f8000223" means:
    - swp_type is 0x1f, which is MIGRATION_TYPE.
    - swp_offset is 0x223.

"swap file entry f8005ff4" means:
    - swp_type is 0x1f, which is MIGRATION_TYPE.
    - swp_offset is 0x5ff4.

I have no idea why this has happened yet.


Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f8000223
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f8000224
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f8000225
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f8000226
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f8000227
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f8000228
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f8000229
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f800022a
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f800022b
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f800022c
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f800022d
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f800022e
Oct 26 21:28:06 target1 kernel: swap_free: Bad swap file entry f800022f
Oct 26 21:28:08 target1 kernel: swap_free: Bad swap file entry f8000230
Oct 26 21:28:08 target1 kernel: swap_free: Bad swap file entry f8000231
Oct 26 21:28:08 target1 kernel: swap_free: Bad swap file entry f8000232
Oct 26 21:28:08 target1 kernel: swap_free: Bad swap file entry f8000233
Oct 26 21:28:08 target1 kernel: swap_free: Bad swap file entry f8000234
Oct 26 21:28:08 target1 kernel: swap_free: Bad swap file entry f8000235
Oct 26 21:28:08 target1 kernel: swap_free: Bad swap file entry f8000236
Oct 26 21:28:08 target1 kernel: Unable to handle kernel NULL pointer dereference at virtual address 00000028
Oct 26 21:28:08 target1 kernel:  printing eip:
Oct 26 21:28:08 target1 kernel: c028ef60
Oct 26 21:28:08 target1 kernel: *pde = 00000000
Oct 26 21:28:08 target1 kernel: Oops: 0002 [#1]
Oct 26 21:28:08 target1 kernel: SMP 
Oct 26 21:28:08 target1 kernel: Modules linked in:
Oct 26 21:28:08 target1 kernel: CPU:    0
Oct 26 21:28:08 target1 kernel: EIP:    0060:[_spin_lock+0/16]    Not tainted VLI
Oct 26 21:28:08 target1 kernel: EIP:    0060:[<c028ef60>]    Not tainted VLI
Oct 26 21:28:08 target1 kernel: EFLAGS: 00010282   (2.6.9-rc4-mm1) 
Oct 26 21:28:08 target1 kernel: EIP is at _spin_lock+0x0/0x10
Oct 26 21:28:09 target1 kernel: eax: 00000028   ebx: 00008097   ecx: ce0e7ed0   edx: ce0e7f24
Oct 26 21:28:09 target1 kernel: esi: 00000000   edi: f71fa8a0   ebp: 00000000   esp: ce0e7ec4
Oct 26 21:28:09 target1 kernel: ds: 007b   es: 007b   ss: 0068
Oct 26 21:28:09 target1 kernel: Process migrate131072 (pid: 1700, threadinfo=ce0e6000 task=cf01a100)
Oct 26 21:28:09 target1 kernel: Stack: c014ca72 00000000 00000000 00000001 cc9c7414 00000022 00000246 c013a5f1 
Oct 26 21:28:09 target1 kernel:        c1187420 f71fa8a0 c1187420 c03036e0 00000000 f71fa8a0 ce0e7f24 f71fa8a0 
Oct 26 21:28:09 target1 kernel:        00000000 c014ccc7 f71fa8a0 ce0e7f24 ce0e7f24 c0154b1f f71fa8a0 ce0e7f24 
Oct 26 21:28:09 target1 kernel: Call Trace:
Oct 26 21:28:09 target1 kernel:  [try_to_unmap_file+50/576] try_to_unmap_file+0x32/0x240
Oct 26 21:28:09 target1 kernel:  [<c014ca72>] try_to_unmap_file+0x32/0x240
Oct 26 21:28:09 target1 kernel:  [buffered_rmqueue+433/480] buffered_rmqueue+0x1b1/0x1e0
Oct 26 21:28:09 target1 kernel:  [<c013a5f1>] buffered_rmqueue+0x1b1/0x1e0
Oct 26 21:28:09 target1 kernel:  [try_to_unmap+71/89] try_to_unmap+0x47/0x59
Oct 26 21:28:09 target1 kernel:  [<c014ccc7>] try_to_unmap+0x47/0x59
Oct 26 21:28:09 target1 kernel:  [generic_migrate_page+95/688] generic_migrate_page+0x5f/0x2b0
Oct 26 21:28:09 target1 kernel:  [<c0154b1f>] generic_migrate_page+0x5f/0x2b0
Oct 26 21:28:09 target1 kernel:  [migrate_onepage+308/416] migrate_onepage+0x134/0x1a0
Oct 26 21:28:09 target1 kernel:  [<c0154ea4>] migrate_onepage+0x134/0x1a0
Oct 26 21:28:09 target1 kernel:  [migrate_page_common+0/256] migrate_page_common+0x0/0x100
Oct 26 21:28:09 target1 kernel:  [<c01545e0>] migrate_page_common+0x0/0x100
Oct 26 21:28:09 target1 kernel:  [try_to_migrate_pages+1144/1616] try_to_migrate_pages+0x478/0x650
Oct 26 21:28:09 target1 kernel:  [<c0155388>] try_to_migrate_pages+0x478/0x650
Oct 26 21:28:09 target1 kernel:  [mmigrated+146/201] mmigrated+0x92/0xc9
Oct 26 21:28:09 target1 kernel:  [<c01559b2>] mmigrated+0x92/0xc9
Oct 26 21:28:09 target1 kernel:  [mmigrated+0/201] mmigrated+0x0/0xc9
Oct 26 21:28:09 target1 kernel:  [<c0155920>] mmigrated+0x0/0xc9
Oct 26 21:28:09 target1 kernel:  [kernel_thread_helper+5/24] kernel_thread_helper+0x5/0x18
Oct 26 21:28:09 target1 kernel:  [<c010408d>] kernel_thread_helper+0x5/0x18
Oct 26 21:28:09 target1 kernel: Code: 00 00 01 74 05 e8 79 ec ff ff c3 ba 00 e0 ff ff 21 e2 81 42 14 00 01 00 00 f0 81 28 00 00 00 01 74 05 e8 5c ec ff ff c3 8d 76 00 <f0> fe 08 79 09 f3 90 80 38 00 7e f9 eb f2 c3 90 f0 81 28 00 00 





Oct 27 05:50:48 target1 kernel: swap_dup: Bad swap file entry f8005ff4
Oct 27 05:50:49 target1 kernel: ------------[ cut here ]------------
Oct 27 05:50:49 target1 kernel: kernel BUG at mm/mmigrate.c:115!
Oct 27 05:50:49 target1 kernel: invalid operand: 0000 [#1]
Oct 27 05:50:49 target1 kernel: SMP 
Oct 27 05:50:49 target1 kernel: Modules linked in:
Oct 27 05:50:49 target1 kernel: CPU:    0
Oct 27 05:50:49 target1 kernel: EIP:    0060:[migration_remove_entry+24/80]    Not tainted VLI
Oct 27 05:50:49 target1 kernel: EIP:    0060:[<c0154158>]    Not tainted VLI
Oct 27 05:50:49 target1 kernel: EFLAGS: 00010246   (2.6.9-rc4-mm1) 
Oct 27 05:50:49 target1 kernel: EIP is at migration_remove_entry+0x18/0x50
Oct 27 05:50:49 target1 kernel: eax: c0303700   ebx: 00000000   ecx: c0303704   edx: f8005ff4
Oct 27 05:50:49 target1 kernel: esi: 00000000   edi: 00000000   ebp: c12033a0   esp: cb681e08
Oct 27 05:50:49 target1 kernel: ds: 007b   es: 007b   ss: 0068
Oct 27 05:50:49 target1 kernel: Process migrate65536 (pid: 22493, threadinfo=cb680000 task=cee90a80)
Oct 27 05:50:49 target1 kernel: Stack: 00005ff4 c0145c61 f8005ff4 c68e9f64 00004000 bffd5000 c0000000 c40b5c00 
Oct 27 05:50:49 target1 kernel:        00000000 c0145ce5 c12033a0 c40b5bfc bffd5000 0002b000 00000000 bffd5000 
Oct 27 05:50:49 target1 kernel:        c40b5c00 c0000000 00000000 c0145d55 c12033a0 c40b5bfc bffd5000 0002b000 
Oct 27 05:50:49 target1 kernel: Call Trace:
Oct 27 05:50:49 target1 kernel:  [zap_pte_range+705/768] zap_pte_range+0x2c1/0x300
Oct 27 05:50:49 target1 kernel:  [<c0145c61>] zap_pte_range+0x2c1/0x300
Oct 27 05:50:49 target1 kernel:  [zap_pmd_range+69/112] zap_pmd_range+0x45/0x70
Oct 27 05:50:49 target1 kernel:  [<c0145ce5>] zap_pmd_range+0x45/0x70
Oct 27 05:50:49 target1 kernel:  [unmap_page_range+69/112] unmap_page_range+0x45/0x70
Oct 27 05:50:49 target1 kernel:  [<c0145d55>] unmap_page_range+0x45/0x70
Oct 27 05:50:49 target1 kernel:  [unmap_vmas+376/640] unmap_vmas+0x178/0x280
Oct 27 05:50:49 target1 kernel:  [<c0145ef8>] unmap_vmas+0x178/0x280
Oct 27 05:50:49 target1 kernel:  [exit_mmap+123/336] exit_mmap+0x7b/0x150
Oct 27 05:50:49 target1 kernel:  [<c014a64b>] exit_mmap+0x7b/0x150
Oct 27 05:50:49 target1 kernel:  [mmput+33/160] mmput+0x21/0xa0
Oct 27 05:50:49 target1 kernel:  [<c011a611>] mmput+0x21/0xa0
Oct 27 05:50:49 target1 kernel:  [touch_unmapped_address+208/256] touch_unmapped_address+0xd0/0x100
Oct 27 05:50:50 target1 kernel:  [<c014c480>] touch_unmapped_address+0xd0/0x100
Oct 27 05:50:50 target1 kernel:  [generic_migrate_page+482/688] generic_migrate_page+0x1e2/0x2b0
Oct 27 05:50:50 target1 kernel:  [<c0154cc2>] generic_migrate_page+0x1e2/0x2b0
Oct 27 05:50:50 target1 kernel:  [migrate_onepage+308/416] migrate_onepage+0x134/0x1a0
Oct 27 05:50:50 target1 kernel:  [<c0154ec4>] migrate_onepage+0x134/0x1a0
Oct 27 05:50:50 target1 kernel:  [migrate_page_common+0/256] migrate_page_common+0x0/0x100
Oct 27 05:50:50 target1 kernel:  [<c0154600>] migrate_page_common+0x0/0x100
Oct 27 05:50:50 target1 kernel:  [try_to_migrate_pages+648/1616] try_to_migrate_pages+0x288/0x650
Oct 27 05:50:50 target1 kernel:  [<c01551b8>] try_to_migrate_pages+0x288/0x650
Oct 27 05:50:50 target1 kernel:  [mmigrated+146/201] mmigrated+0x92/0xc9
Oct 27 05:50:50 target1 kernel:  [<c01559d2>] mmigrated+0x92/0xc9
Oct 27 05:50:50 target1 kernel:  [mmigrated+0/201] mmigrated+0x0/0xc9
Oct 27 05:50:50 target1 kernel:  [<c0155940>] mmigrated+0x0/0xc9
Oct 27 05:50:50 target1 kernel:  [kernel_thread_helper+5/24] kernel_thread_helper+0x5/0x18
Oct 27 05:50:50 target1 kernel:  [<c010408d>] kernel_thread_helper+0x5/0x18
Oct 27 05:50:50 target1 kernel: Code: 0c 00 00 00 00 ff 0d 80 36 30 c0 e8 03 af 13 00 5b 5e c3 53 8b 4c 24 08 51 68 00 37 30 c0 e8 40 23 fe ff 89 c3 58 85 db 5a 75 08 <0f> 0b 73 00 ee 43 2a c0 31 c0 f0 0f ab 03 19 c0 85 c0 74 07 89 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
