Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id D9ACF6B0038
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 18:17:39 -0400 (EDT)
Received: by qgdy78 with SMTP id y78so31379896qgd.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 15:17:39 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r40si2017515yhr.144.2015.04.30.15.17.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Apr 2015 15:17:38 -0700 (PDT)
Message-ID: <5542A9FE.1000604@oracle.com>
Date: Thu, 30 Apr 2015 18:17:34 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: hangs in collapse_huge_page
References: <534DE5C0.2000408@oracle.com> <20140430154230.GA23371@node.dhcp.inet.fi>
In-Reply-To: <20140430154230.GA23371@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/30/2014 11:42 AM, Kirill A. Shutemov wrote:
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index b4b1feba6472..1c6ace5207b9 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1986,6 +1986,8 @@ static void insert_to_mm_slots_hash(struct mm_struct *mm,
>  
>  static inline int khugepaged_test_exit(struct mm_struct *mm)
>  {
> +       VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem) &&
> +                       !spin_is_locked(&khugepaged_mm_lock));
>         return atomic_read(&mm->mm_users) == 0;
>  }

I've managed to hit this during testing:

[ 8048.304275] kernel BUG at mm/huge_memory.c:2060!
[ 8048.305878] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[ 8048.307479] Modules linked in: quota_v2 quota_tree xfs libcrc32c x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel ast kvm ttm drm_kms_helper crct10dif_pclmul crc32_pclmul drm ghash_clmulni_intel aesni_
intel aes_x86_64 lrw glue_helper ablk_helper cryptd joydev i2c_algo_bit sb_edac syscopyarea sysfillrect edac_core sysimgblt lpc_ich ipmi_si ipmi_msghandler ioatdma shpchp mac_hid btrfs xor mlx4_en vxlan raid6_pq
hid_generic ixgbe mlx4_core usbhid hid dca megaraid_sas ahci ptp libahci pps_core mdio
[ 8048.314422] CPU: 31 PID: 13065 Comm: thp01 Not tainted 4.1.0-rc1-next-20150430+ #8
[ 8048.316215] Hardware name: Oracle Corporation OVCA X3-2             /ASSY,MOTHERBOARD,1U   , BIOS 17021300 06/19/2012
[ 8048.318070] task: ffff8837ba9b3b40 ti: ffff8837bfcf8000 task.ti: ffff8837bfcf8000
[ 8048.319941] RIP: __khugepaged_enter (mm/huge_memory.c:2059 mm/huge_memory.c:2075)
[ 8048.321856] RSP: 0018:ffff8837bfcff8a0  EFLAGS: 00010246
[ 8048.323752] RAX: 000000000000d800 RBX: ffff8837b8314b00 RCX: 0000000000000000
[ 8048.325665] RDX: 00000000000000d8 RSI: 00000000000000fc RDI: ffff8837b8314ba8
[ 8048.327570] RBP: ffff8837bfcff8e0 R08: ffff8837df1e5040 R09: ffffed06f4b701b8
[ 8048.329486] R10: 000000002a82d01f R11: 1ffff106f82c0f77 R12: ffff8837a5b80d98
[ 8048.331414] R13: ffff8837c6c58b80 R14: ffff8837c6c58bd0 R15: 0000000000000000
[ 8048.333357] FS:  00007f238e593740(0000) GS:ffff8837df1c0000(0000) knlGS:0000000000000000
[ 8048.335329] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 8048.337304] CR2: 00007f8a8d2c4740 CR3: 00000037c7c10000 CR4: 00000000000407e0
[ 8048.339369] Stack:
[ 8048.341343]  0000000000000000 00000007fffffffe ffff883700000001 ffff8837b8314b00
[ 8048.343382]  00007fffffc00000 ffff8837c6c58b80 ffff8837c6c58bd0 0000000000000000
[ 8048.345421]  ffff8837bfcff910 ffffffff815cfa60 ffff8837bfcff910 ffffffff81249cd3
[ 8048.347473] Call Trace:
[ 8048.349502] khugepaged_enter_vma_merge (include/linux/khugepaged.h:46 mm/huge_memory.c:2115)
[ 8048.351584] ? up_write (kernel/locking/rwsem.h:9 kernel/locking/rwsem.c:93)
[ 8048.353654] expand_downwards (mm/mmap.c:2278)
[ 8048.355719] ? __mem_cgroup_count_vm_event (mm/memcontrol.c:1156)
[ 8048.357791] handle_mm_fault (mm/memory.c:2673 mm/memory.c:3250 mm/memory.c:3371 mm/memory.c:3400)
[ 8048.359886] ? follow_page_pte (mm/gup.c:48)
[ 8048.361952] ? __pmd_alloc (mm/memory.c:3382)
[ 8048.364020] ? _raw_spin_unlock (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:154 kernel/locking/spinlock.c:183)
[ 8048.366083] ? follow_page_pte (mm/gup.c:125)
[ 8048.368139] ? follow_page_mask (mm/gup.c:209)
[ 8048.370181] __get_user_pages (mm/gup.c:285 mm/gup.c:477)
[ 8048.372214] ? follow_page_mask (mm/gup.c:420)
[ 8048.374242] ? might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3762)
[ 8048.376269] get_user_pages (mm/gup.c:818)
[ 8048.378295] copy_strings.isra.20 (fs/exec.c:197 fs/exec.c:510)
[ 8048.380392] ? count.isra.18.constprop.36 (fs/exec.c:454)
[ 8048.382439] ? copy_strings_kernel (fs/exec.c:556)
[ 8048.384464] do_execveat_common.isra.32 (fs/exec.c:1577)
[ 8048.386469] ? do_execveat_common.isra.32 (include/linux/spinlock.h:312 fs/exec.c:1263 fs/exec.c:1518)
[ 8048.388448] ? prepare_bprm_creds (fs/exec.c:1475)
[ 8048.390395] ? kmem_cache_alloc (include/trace/events/kmem.h:53 mm/slub.c:2524)
[ 8048.392309] ? getname_flags (fs/namei.c:135)
[ 8048.394187] ? up_read (./arch/x86/include/asm/rwsem.h:156 kernel/locking/rwsem.c:81)
[ 8048.396027] ? getname_flags (fs/namei.c:146)
[ 8048.397869] SyS_execve (fs/exec.c:1701)
[ 8048.399715] stub_execve (arch/x86/kernel/entry_64.S:510)
[ 8048.401482] ? system_call_fastpath (arch/x86/kernel/entry_64.S:261)
[ 8048.403207] Code: 1f 84 00 00 00 00 00 b8 f4 ff ff ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f b7 05 a9 fb db 01 0f b6 d4 31 d0 a8 fe 0f 85 3e fe ff ff <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 48 89 df e8 18 88 f6 ff 0f
All code
========
   0:   1f                      (bad)
   1:   84 00                   test   %al,(%rax)
   3:   00 00                   add    %al,(%rax)
   5:   00 00                   add    %al,(%rax)
   7:   b8 f4 ff ff ff          mov    $0xfffffff4,%eax
   c:   c3                      retq
   d:   66 2e 0f 1f 84 00 00    nopw   %cs:0x0(%rax,%rax,1)
  14:   00 00 00
  17:   0f b7 05 a9 fb db 01    movzwl 0x1dbfba9(%rip),%eax        # 0x1dbfbc7
  1e:   0f b6 d4                movzbl %ah,%edx
  21:   31 d0                   xor    %edx,%eax
  23:   a8 fe                   test   $0xfe,%al
  25:   0f 85 3e fe ff ff       jne    0xfffffffffffffe69
  2b:*  0f 0b                   ud2             <-- trapping instruction
  2d:   66 2e 0f 1f 84 00 00    nopw   %cs:0x0(%rax,%rax,1)
  34:   00 00 00
  37:   48 89 df                mov    %rbx,%rdi
  3a:   e8 18 88 f6 ff          callq  0xfffffffffff68857
  3f:

Code starting with the faulting instruction
===========================================
   0:   0f 0b                   ud2
   2:   66 2e 0f 1f 84 00 00    nopw   %cs:0x0(%rax,%rax,1)
   9:   00 00 00
   c:   48 89 df                mov    %rbx,%rdi
   f:   e8 18 88 f6 ff          callq  0xfffffffffff6882c
  14:
[ 8048.406837] RIP __khugepaged_enter (mm/huge_memory.c:2059 mm/huge_memory.c:2075)
[ 8048.408525]  RSP <ffff8837bfcff8a0>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
