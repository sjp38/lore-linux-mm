Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B53B76B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 07:58:26 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z96so7905669wrb.21
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 04:58:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v11sor6749443edb.25.2017.10.30.04.58.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Oct 2017 04:58:22 -0700 (PDT)
Date: Mon, 30 Oct 2017 14:58:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [pgtable_trans_huge_withdraw] BUG: unable to handle kernel NULL
 pointer dereference at 0000000000000020
Message-ID: <20171030115819.33y7g47qnzrsmwwb@node.shutemov.name>
References: <CA+55aFxSJGeN=2X-uX-on1Uq2Nb8+v1aiMDz5H1+tKW_N5Q+6g@mail.gmail.com>
 <20171029225155.qcum5i75awrt5tzm@wfg-t540p.sh.intel.com>
 <20171029233701.4pjqaesnrjqshmzn@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171029233701.4pjqaesnrjqshmzn@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Geliang Tang <geliangtang@163.com>

On Mon, Oct 30, 2017 at 12:37:01AM +0100, Fengguang Wu wrote:
> CC MM people.
> 
> On Sun, Oct 29, 2017 at 11:51:55PM +0100, Fengguang Wu wrote:
> > Hi Linus,
> > 
> > Up to now we see the below boot error/warnings when testing v4.14-rc6.
> > 
> > They hit the RC release mainly due to various imperfections in 0day's
> > auto bisection. So I manually list them here and CC the likely easy to
> > debug ones to the corresponding maintainers in the followup emails.
> > 
> > boot_successes: 4700
> > boot_failures: 247
> > 
> > BUG:kernel_hang_in_test_stage: 152
> > BUG:kernel_reboot-without-warning_in_test_stage: 10
> > BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/mutex.c: 1
> > BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/rwsem.c: 3
> > BUG:sleeping_function_called_from_invalid_context_at_mm/page_alloc.c: 21
> > BUG:soft_lockup-CPU##stuck_for#s: 1
> > BUG:unable_to_handle_kernel: 13
> 
> Here is the call trace:
> 
> [  956.669197] [  956.670421] stress-ng: fail:  [27945] stress-ng-numa:
> get_mempolicy: errno=22 (Invalid argument)
> [  956.670422] [  956.671375] stress-ng: info:  [27945] 5 failures reached,
> aborting stress process
> [  956.671376] [  956.671551] BUG: unable to handle kernel NULL pointer
> dereference at 0000000000000020
> [  956.671557] IP: pgtable_trans_huge_withdraw+0x4c/0xc0
> [  956.671558] PGD 0 P4D 0 [  956.671560] Oops: 0000 [#1] SMP
> [  956.671562] Modules linked in: salsa20_generic salsa20_x86_64 camellia_generic camellia_aesni_avx2 camellia_aesni_avx_x86_64 camellia_x86_64 cast6_avx_x86_64 cast6_generic cast_common serpent_avx2 serpent_avx_x86_64 serpent_sse2_x86_64 serpent_generic twofish_generic twofish_avx_x86_64 ablk_helper twofish_x86_64_3way twofish_x86_64 twofish_common lrw tgr192 wp512 rmd320 rmd256 rmd160 rmd128 md4 sha512_ssse3 sha512_generic rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp sd_mod sg coretemp kvm_intel kvm mgag200 irqbypass ttm crct10dif_pclmul crc32_pclmul drm_kms_helper crc32c_intel syscopyarea ghash_clmulni_intel snd_pcm sysfillrect snd_timer pcbc sysimgblt fb_sys_fops ahci snd aesni_intel crypto_simd mxm_wmi glue_helper libahci soundcore cryptd
> [  956.671592]  drm ipmi_si pcspkr libata shpchp ipmi_devintf ipmi_msghandler acpi_pad acpi_power_meter wmi ip_tables
> [  956.671600] CPU: 78 PID: 28007 Comm: stress-ng-numa Not tainted 4.14.0-rc6 #1
> [  956.671600] Hardware name: Intel Corporation S2600WT2R/S2600WT2R, BIOS SE5C610.86B.01.01.0020.122820161512 12/28/2016
> [  956.671601] task: ffff88101c97cd00 task.stack: ffffc90026b04000
> [  956.671603] RIP: 0010:pgtable_trans_huge_withdraw+0x4c/0xc0
> [  956.671604] RSP: 0018:ffffc90026b07c20 EFLAGS: 00010202
> [  956.671604] RAX: ffffea00404c7b80 RBX: 0000000000000000 RCX: 0000000000000001
> [  956.671605] RDX: 0000000000000001 RSI: ffff8810931ee000 RDI: ffff881020f11000
> [  956.671605] RBP: ffffc90026b07c28 R08: ffff88101a96a190 R09: 000055c2d5137000
> [  956.671606] R10: 0000000000000000 R11: 0000000000000000 R12: ffff881020f11000
> [  956.671606] R13: ffffc90026b07dd8 R14: ffff8810131ee538 R15: ffffea00404c7bb0
> [  956.671607] FS:  0000000000000000(0000) GS:ffff882023080000(0000) knlGS:0000000000000000
> [  956.671608] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  956.671609] CR2: 0000000000000020 CR3: 000000207ee09001 CR4: 00000000003606e0
> [  956.671609] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  956.671610] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [  956.671610] Call Trace:
> [  956.671614]  zap_huge_pmd+0x28a/0x3a0
> [  956.671617]  unmap_page_range+0x918/0x9c0
> [  956.671619]  unmap_single_vma+0x7d/0xe0
> [  956.671621]  unmap_vmas+0x51/0xa0
> [  956.671622]  exit_mmap+0x96/0x190
> [  956.671625]  mmput+0x6e/0x160
> [  956.671626]  do_exit+0x2b3/0xb90
> [  956.671627]  do_group_exit+0x43/0xb0
> [  956.671628]  SyS_exit_group+0x14/0x20
> [  956.671630]  entry_SYSCALL_64_fastpath+0x1a/0xa5
> [  956.671631] RIP: 0033:0x7f92a15e11c8
> [  956.671631] RSP: 002b:00007fff12384aa8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> [  956.671632] RAX: ffffffffffffffda RBX: 00007f92a1dea000 RCX: 00007f92a15e11c8
> [  956.671633] RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
> [  956.671633] RBP: 00007fff12384aa0 R08: 00000000000000e7 R09: ffffffffffffff90
> [  956.671634] R10: 00007f92a088b070 R11: 0000000000000246 R12: 00007f92a088add8
> [  956.671634] R13: 00007fff12384a18 R14: 00007f92a1df4048 R15: 0000000000000000
> [  956.671635] Code: 77 00 00 48 01 f0 48 ba 00 00 00 00 00 ea ff ff 48 c1
> e8 0c 48 c1 e0 06 48 01 d0 8b 50 30 85 d2 74 6d 55 48 89 e5 53 48 8b 58 28
> <48> 8b 53 20 48 8d 7b 20 48 39 d7 74 49 48 83 ea 20 48 85 d2 48 [
> 956.671650] RIP: pgtable_trans_huge_withdraw+0x4c/0xc0 RSP: ffffc90026b07c20
> [  956.671651] CR2: 0000000000000020
> [  956.671695] ---[ end trace 9ac71716a2cdb192 ]---
> [  956.672896] stress-ng: fail:  [27986] stress-ng-numa: get_mempolicy: errno=22 (Invalid argument)

+Zi Yan.

Could you check if the patch below helps?

It seems we forgot to deposit page table on copying pmd migration entry.
Current code just leaks newly allocated page table.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 269b5df58543..84beba5dedda 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -941,6 +941,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 				pmd = pmd_swp_mksoft_dirty(pmd);
 			set_pmd_at(src_mm, addr, src_pmd, pmd);
 		}
+		pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
 		ret = 0;
 		goto out_unlock;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
