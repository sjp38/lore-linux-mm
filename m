Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 068FE6B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 18:30:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id r88so6883221pfi.23
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 15:30:36 -0800 (PST)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTPS id o11si4390187pgp.238.2017.12.07.15.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 15:30:35 -0800 (PST)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [RFC PATCH] mm: kasan: suppress soft lockup in slub when !CONFIG_PREEMPT
Date: Fri, 08 Dec 2017 07:30:07 +0800
Message-Id: <1512689407-100663-1-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, akpm@linux-foundation.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org

When running stress test with KASAN enabled, the below softlockup may
happen occasionally:

NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[blogbench:2997]
Modules linked in: dm_mod(E) binfmt_misc(E)
salsa20_generic(E) salsa20_x86_64(E) camellia_generic(E)
camellia_aesni_avx_x86_64(E) camellia_x86_64(E) cast6_avx_x86_64(E)
cast6_generic(E) cast_common(E) serpent_avx_x86_64(E)
serpent_sse2_x86_64(E) serpent_generic(E) twofish_generic(E)
twofish_avx_x86_64(E) twofish_x86_64_3way(E) twofish_x86_64(E)
twofish_common(E) xts(E) tgr192(E) wp512(E) rmd320(E) rmd256(E)
rmd160(E) rmd128(E) md4(E) sha512_ssse3(E) sha512_generic(E) tcp_diag(E)
inet_diag(E) bonding(E) intel_rapl(E) iosf_mbi(E)
x86_pkg_temp_thermal(E) coretemp(E) kvm_intel(E) kvm(E) irqbypass(E)
iTCO_wdt(E) iTCO_vendor_support(E) crct10dif_pclmul(E) dcdbas(E)
crc32_pclmul(E) sg(E) ipmi_devintf(E) ghash_clmulni_intel(E)
aesni_intel(E) lrw(E) gf128mul(E) glue_helper(E) ablk_helper(E)
cryptd(E) ipmi_si(E) mei_me(E) pcspkr(E) lpc_ich(E) mfd_core(E)
mei(E) shpchp(E) wmi(E) ipmi_msghandler(E) acpi_power_meter(E) nfsd(E)
auth_rpcgss(E) nfs_acl(E) lockd(E) grace(E) sunrpc(E) ip_tables(E)
ext4(E) jbd2(E) mbcache(E) sd_mod(E) mgag200(E) drm_kms_helper(E)
syscopyarea(E) sysfillrect(E) sysimgblt(E) fb_sys_fops(E) ixgbe(E)
igb(E) mdio(E) ttm(E) ptp(E) drm(E) pps_core(E) crc32c_intel(E)
i2c_algo_bit(E) i2c_core(E) megaraid_sas(E) dca(E)
irq event stamp: 0
hardirqs lastA  enabled at (0): [<A  A  A  A  A  (null)>] A  A  A (null)
hardirqs last disabled at (0): [] copy_process.part.30+0x5c6/0x1f50
softirqs lastA  enabled at (0): [] copy_process.part.30+0x5c6/0x1f50
softirqs last disabled at (0): [<A  A  A  A  A  (null)>] A  A  A (null)
CPU: 7 PID: 2997 Comm: blogbench Tainted: GA  A  A  A  W A  E
  4.9.44-003.ali3000.alios7.x86_64.debug #1
Hardware name: Dell Inc. PowerEdge R720xd/0X6FFV, BIOS 1.6.0 03/07/2013
task: ffff884f7ca93340 task.stack: ffff884f7caa0000
RIP: 0010:[]A  [] put_cpu_partial+0xf5/0x160
RSP: 0018:ffff884f7caa7c90A  EFLAGS: 00000202
RAX: ffff884f7ca93340 RBX: ffffea0146720a00 RCX: 0000000000000002
RDX: ffff884f7ca93340 RSI: 0000000000000001 RDI: 0000000000000202
RBP: ffff884f7caa7cb0 R08: 0000000000000000 R09: 0000000000000630
R10: 0000000000000000 R11: 0000000000000000 R12: ffff8852bb0f5f80
R13: 0000000000000001 R14: 0000000000000202 R15: 0000000000000000
FS:A  00007fb74867c700(0000) GS:ffff8852bc400000(0000) knlGS:0000000000000000
CS:A  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fded6b49c90 CR3: 0000005032bc6000 CR4: 00000000000406e0
Stack:
 0000000000000000 0000000000070006 ffff8852bb0f5f80 ffffea0146720a00
 ffff884f7caa7d60 ffffffff8126798c 0000000000000286 ffff88519c828000
 ffff88525334a200 0000000100070001 ffff88519c828000 ffff8852bb0f0001
Call Trace:
 [] __slab_free+0x19c/0x270
 [] ___cache_free+0xa6/0xb0
 [] qlist_free_all+0x47/0x80
 [] quarantine_reduce+0x159/0x190
 [] kasan_kmalloc+0xaf/0xc0
 [] kasan_slab_alloc+0x12/0x20
 [] kmem_cache_alloc+0xfa/0x360
 [] ? getname_flags+0x4f/0x1f0
 [] getname_flags+0x4f/0x1f0
 [] getname+0x12/0x20
 [] do_sys_open+0xf9/0x210
 [] SyS_open+0x1e/0x20
 [] entry_SYSCALL_64_fastpath+0x1f/0xc2
Code: ff 31 c9 e9 65 ff ff ff 41 8b 44 24 24 85 c0 74 2d
65 ff 0d 16 17 db 7e 5b 41 5c 41 5d 41 5e 5d c3 e8 60 c3 e9 ff 4c 89 f7
57 9d <66> 66 90 66 90 ba 01 00 00 00 31 ff 31 c9 e9 2f ff ff ff e8 83

The code is run in irq disabled or preempt disabled context, so
cond_resched() can't be used in this case. Touch softlockup watchdog when
KASAN is enabled to suppress the warning.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
 mm/slub.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index cfd56e5..4ae435e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -35,6 +35,7 @@
 #include <linux/prefetch.h>
 #include <linux/memcontrol.h>
 #include <linux/random.h>
+#include <linux/nmi.h>
 
 #include <trace/events/kmem.h>
 
@@ -2266,6 +2267,10 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 		page->pobjects = pobjects;
 		page->next = oldpage;
 
+#ifdef CONFIG_KASAN
+		touch_softlockup_watchdog();
+#endif
+
 	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
 								!= oldpage);
 	if (unlikely(!s->cpu_partial)) {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
