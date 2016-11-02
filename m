Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4D536B027E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 19:48:04 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id o20so5966692lfg.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 16:48:04 -0700 (PDT)
Received: from mx4.wp.pl (mx4.wp.pl. [212.77.101.12])
        by mx.google.com with ESMTPS id z131si3199860lfa.326.2016.11.02.16.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 16:48:03 -0700 (PDT)
Date: Wed, 2 Nov 2016 23:47:55 +0000
From: Jakub Kicinski <kubakici@wp.pl>
Subject: [RFC] make kmemleak scan __ro_after_init section (was: Re: [PATCH
 0/5] genetlink improvements)
Message-ID: <20161102234755.4381f528@jkicinski-Precision-T1700>
In-Reply-To: <CAM_iQpV_0gyrJC0U6Qk9VSSaNOphe_0tq5o2kt8-r0UybLU5FA@mail.gmail.com>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
	<20161101172840.6d7d6278@jkicinski-Precision-T1700>
	<CAM_iQpVeB+2M1MPxjRx++E=q4mDuo7XQqfQn3-160PqG8bNLdQ@mail.gmail.com>
	<20161101185630.3c7d326f@jkicinski-Precision-T1700>
	<CAM_iQpV_0gyrJC0U6Qk9VSSaNOphe_0tq5o2kt8-r0UybLU5FA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Johannes Berg <johannes@sipsolutions.net>, Linux Kernel Network Developers <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org

On Wed, 2 Nov 2016 13:30:34 -0700, Cong Wang wrote:
> On Tue, Nov 1, 2016 at 11:56 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> > On Tue, 1 Nov 2016 11:32:52 -0700, Cong Wang wrote:  
> >> On Tue, Nov 1, 2016 at 10:28 AM, Jakub Kicinski <kubakici@wp.pl> wrote:  
> >> > unreferenced object 0xffff8807389cba28 (size 128):
> >> >   comm "swapper/0", pid 1, jiffies 4294898463 (age 781.332s)
> >> >   hex dump (first 32 bytes):
> >> >     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> >> >     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> >> >   backtrace:
> >> >     [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
> >> >     [<ffffffff84771246>] __kmalloc+0x206/0x5a0
> >> >     [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
> >> >     [<ffffffff888d9524>] netlbl_mgmt_genl_init+0x10/0x12
> >> >     [<ffffffff888d91e8>] netlbl_netlink_init+0x9/0x26
> >> >     [<ffffffff888d9254>] netlbl_init+0x4f/0x85
> >> >     [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
> >> >     [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
> >> >     [<ffffffff85de7793>] kernel_init+0x13/0x140
> >> >     [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40  
> >>
> >> Looks like we are missing a kfree(family->attrbuf); on error path,
> >> but it is not related to Johannes' recent patches.
> >>
> >> Could the attached patch help?
> >
> > Still there:
> >
> > unreferenced object 0xffff88073fb204e8 (size 64):
> >   comm "swapper/0", pid 1, jiffies 4294898455 (age 88.528s)
> >   hex dump (first 32 bytes):
> >     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> >     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> >   backtrace:
> >     [<ffffffff93decbf8>] kmemleak_alloc+0x28/0x50
> >     [<ffffffff92771246>] __kmalloc+0x206/0x5a0
> >     [<ffffffff939e1471>] genl_register_family+0x921/0x1270
> >     [<ffffffff968d0ecf>] genl_init+0x11/0x43
> >     [<ffffffff920022b7>] do_one_initcall+0xb7/0x2a0
> >     [<ffffffff967f9102>] kernel_init_freeable+0x597/0x636
> >     [<ffffffff93de78b3>] kernel_init+0x13/0x140
> >     [<ffffffff93e0256a>] ret_from_fork+0x2a/0x40
> >     [<ffffffffffffffff>] 0xffffffffffffffff
> >
> > etc.  
> 
> Interesting, from the size it does look like we are leaking family->attrbuf,
> but I don't see other cases could leak it except the error path I fixed.
> 
> Mind doing a quick bisect?

Thanks for looking into this!  Bisect led me to the following commit:

commit 56989f6d8568c21257dcec0f5e644d5570ba3281
Author: Johannes Berg <johannes.berg@intel.com>
Date:   Mon Oct 24 14:40:05 2016 +0200

    genetlink: mark families as __ro_after_init
    
    Now genl_register_family() is the only thing (other than the
    users themselves, perhaps, but I didn't find any doing that)
    writing to the family struct.
    
    In all families that I found, genl_register_family() is only
    called from __init functions (some indirectly, in which case
    I've add __init annotations to clarifly things), so all can
    actually be marked __ro_after_init.
    
    This protects the data structure from accidental corruption.
    
    Signed-off-by: Johannes Berg <johannes.berg@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


I realized that kmemleak is not scanning the __ro_after_init section...
Following patch solves the false positives but I wonder if it's the
right/acceptable solution.

--->8----------------------------------------------------------------

diff --git a/arch/s390/kernel/vmlinux.lds.S b/arch/s390/kernel/vmlinux.lds.S
index 000e6e91f6a0..841579932c52 100644
--- a/arch/s390/kernel/vmlinux.lds.S
+++ b/arch/s390/kernel/vmlinux.lds.S
@@ -62,9 +62,11 @@ SECTIONS
 
 	. = ALIGN(PAGE_SIZE);
 	__start_ro_after_init = .;
+	VMLINUX_SYMBOL(__start_data_ro_after_init) = .;
 	.data..ro_after_init : {
 		 *(.data..ro_after_init)
 	}
+	VMLINUX_SYMBOL(__end_data_ro_after_init) = .;
 	EXCEPTION_TABLE(16)
 	. = ALIGN(PAGE_SIZE);
 	__end_ro_after_init = .;
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index af0254c09424..4df64a1fc09e 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -14,6 +14,8 @@
  * [_sdata, _edata]: contains .data.* sections, may also contain .rodata.*
  *                   and/or .init.* sections.
  * [__start_rodata, __end_rodata]: contains .rodata.* sections
+ * [__start_data_ro_after_init, __end_data_ro_after_init]:
+ *		     contains data.ro_after_init section
  * [__init_begin, __init_end]: contains .init.* sections, but .init.text.*
  *                   may be out of this range on some architectures.
  * [_sinittext, _einittext]: contains .init.text.* sections
@@ -31,6 +33,7 @@
 extern char __bss_start[], __bss_stop[];
 extern char __init_begin[], __init_end[];
 extern char _sinittext[], _einittext[];
+extern char __start_data_ro_after_init[], __end_data_ro_after_init[];
 extern char _end[];
 extern char __per_cpu_load[], __per_cpu_start[], __per_cpu_end[];
 extern char __kprobes_text_start[], __kprobes_text_end[];
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 30747960bc54..71c75fb64945 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -259,7 +259,10 @@
  * own by defining an empty RO_AFTER_INIT_DATA.
  */
 #ifndef RO_AFTER_INIT_DATA
-#define RO_AFTER_INIT_DATA *(.data..ro_after_init)
+#define RO_AFTER_INIT_DATA						\
+	VMLINUX_SYMBOL(__start_data_ro_after_init) = .;			\
+	*(.data..ro_after_init)						\
+	VMLINUX_SYMBOL(__end_data_ro_after_init) = .;
 #endif
 
 /*
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index e5355a5b423f..d1380ed93fdf 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1414,6 +1414,7 @@ static void kmemleak_scan(void)
 	/* data/bss scanning */
 	scan_large_block(_sdata, _edata);
 	scan_large_block(__bss_start, __bss_stop);
+	scan_large_block(__start_data_ro_after_init, __end_data_ro_after_init);
 
 #ifdef CONFIG_SMP
 	/* per-cpu sections scanning */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
