Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 678F16B00A6
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 21:03:44 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBR23fR6012305
	for <linux-mm@kvack.org> (envelope-from seto.hidetoshi@jp.fujitsu.com);
	Mon, 27 Dec 2010 11:03:41 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C5C6645DE65
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 11:03:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0B2645DE5C
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 11:03:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 85F3EE1800A
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 11:03:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41516E18004
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 11:03:40 +0900 (JST)
Message-ID: <4D17F269.3000904@jp.fujitsu.com>
Date: Mon, 27 Dec 2010 10:56:57 +0900
From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Add a sysctl option controlling kexec when MCE occurred
References: <5C4C569E8A4B9B42A84A977CF070A35B2C132F68FC@USINDEVS01.corp.hds.com>
In-Reply-To: <5C4C569E8A4B9B42A84A977CF070A35B2C132F68FC@USINDEVS01.corp.hds.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Seiji Aguchi <seiji.aguchi@hds.com>
Cc: "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linuxfoundation.org" <akpm@linuxfoundation.org>, "eugeneteo@kernel.org" <eugeneteo@kernel.org>, "kees.cook@canonical.com" <kees.cook@canonical.com>, "drosenberg@vsecurity.com" <drosenberg@vsecurity.com>, "ying.huang@intel.com" <ying.huang@intel.com>, "len.brown@intel.com" <len.brown@intel.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "davem@davemloft.net" <davem@davemloft.net>, "hadi@cyberus.ca" <hadi@cyberus.ca>, "hawk@comx.dk" <hawk@comx.dk>, "opurdila@ixiacom.com" <opurdila@ixiacom.com>, "hidave.darkstar@gmail.com" <hidave.darkstar@gmail.com>, "dzickus@redhat.com" <dzickus@redhat.com>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>, "ext-andriy.shevchenko@nokia.com" <ext-andriy.shevchenko@nokia.com>, "tj@kernel.org" <tj@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Satoru Moriya <satoru.moriya@hds.com>
List-ID: <linux-mm.kvack.org>

(2010/12/23 8:35), Seiji Aguchi wrote:
> Hi,
> 
> [Purpose]
> Kexec may trigger additional hardware errors and multiply the damage 
> if it works after MCE occurred because there are some hardware-related 
> operations in kexec as follows.
>   - Sending NMI to cpus
>   - Initializing hardware during boot process of second kernel.
>   - Accessing to memory and dumping it to disks.
> 
> So, I propose adding a new option controlling kexec behaviour when MCE 
> occurred.
> This patch prevents unnecessary hardware errors and avoid expanding 
> the damage.
> 
> [Patch Description]
> I added a sysctl option ,kernel.kexec_on_mce, controlling kexec behaviour 
> when MCE occurred.
> 
>  - Permission
>    - 0644
>  - Value(default is "1")
>    - non-zero: Kexec is enabled regardless of MCE.
>    - 0: Kexec is disabled when MCE occurred.
> 
> Matrix of kernel.kexec_on_mce value, MCE and kexec behaviour
> 
> --------------------------------------------------
> kernel.kexec_on_mce| MCE          | kexec behaviour
> --------------------------------------------------
> non-zero           | occurred     | enabled
>                    -------------------------------
>                    | not occurred | enabled
> --------------------------------------------------
> 0                  | occurred     | disabled
>                    |------------------------------
>                    | not occurred | enabled
> --------------------------------------------------
> 
> Any comments and suggestions are welcome.

This reminds me of a quite similar patch that I've made a long time ago
but haven't posted.

Following is what I found still in a branch of my private git tree.
I guess it cannot be applied without rebase, but I think the description
of my patch could give you some different point of view etc.
Feel free to use this debris to improve yours.


Thanks,
H.Seto

<*__NOTE_THIS_PATCH_IS_NOT_READY_TO_APPLY__*>
=====
From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 10 Jul 2009 15:55:42 +0900
Subject: [PATCH] kdump, sysctl: kdump_on_safe

This patch adds a sysctl kdump_on_safe, to limit kdump to run only
on safe situation.

Quote from document in this patch:
 > kdump_on_safe:
 >
 > When the system experiences panic, kdump will be triggered if
 > crash kernel is configured.  However the kdump might fail if
 > the panic was caused by fatal error, such as hardware error
 > reported by machine check exception.  It should be rare case,
 > but in the worst case, it will result in data corruption and/or
 > fatal damage on the hardware.
 >
 > If this flag is 1, it prevents kdump from running on such
 > unstable system situation.  Default is 0.

This will be a possible option if your hardware can provide good error
report (in SEL etc.) and/or kernel can provide other data enough for
error investigation (console log, mcelog on x86 etc.), and you'd like
to reduce down-time by skipping kdump on such situation.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 Documentation/sysctl/kernel.txt  |   15 +++++++++++++++
 arch/x86/kernel/cpu/mcheck/mce.c |    3 +++
 include/linux/kexec.h            |    3 +++
 kernel/kexec.c                   |    8 ++++++++
 kernel/sysctl.c                  |   13 +++++++++++++
 5 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 3894eaa..9d66ab9 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -33,6 +33,7 @@ show up in /proc/sys/kernel:
 - hotplug
 - java-appletviewer           [ binfmt_java, obsolete ]
 - java-interpreter            [ binfmt_java, obsolete ]
+- kdump_on_safe               [ kexec ]
 - kstack_depth_to_print       [ X86 only ]
 - l2cr                        [ PPC only ]
 - modprobe                    ==> Documentation/debugging-modules.txt
@@ -247,6 +248,20 @@ This flag controls the L2 cache of G3 processor boards. If
 
 ==============================================================
 
+kdump_on_safe:
+
+When the system experiences panic, kdump will be triggered if
+crash kernel is configured.  However the kdump might fail if
+the panic was caused by fatal error, such as hardware error
+reported by machine check exception.  It should be rare case,
+but in the worst case, it will result in data corruption and/or
+fatal damage on the hardware.
+
+If this flag is 1, it prevents kdump from running on such
+unstable system situation.  Default is 0.
+
+==============================================================
+
 kstack_depth_to_print: (X86 only)
 
 Controls the number of words to print when dumping the raw
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 3e2ab18..c93bb38 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -23,6 +23,7 @@
 #include <linux/sysdev.h>
 #include <linux/delay.h>
 #include <linux/ctype.h>
+#include <linux/kexec.h>
 #include <linux/sched.h>
 #include <linux/sysfs.h>
 #include <linux/types.h>
@@ -291,6 +292,8 @@ static void mce_panic(char *msg, struct mce *final, char *exp)
 	int cpu;
 
 	if (!fake_panic) {
+		set_kdump_might_fail();
+
 		/*
 		 * Make sure only one CPU runs in machine check panic
 		 */
diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index 03e8e8d..41e9ab0 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -209,10 +209,13 @@ int __init parse_crashkernel(char *cmdline, unsigned long long system_ram,
 int crash_shrink_memory(unsigned long new_size);
 size_t crash_get_memory_size(void);
 
+extern int kdump_might_fail;
+static inline void set_kdump_might_fail(void) { kdump_might_fail = 1; }
 #else /* !CONFIG_KEXEC */
 struct pt_regs;
 struct task_struct;
 static inline void crash_kexec(struct pt_regs *regs) { }
 static inline int kexec_should_crash(struct task_struct *p) { return 0; }
+static inline void set_kdump_might_fail(void) { }
 #endif /* CONFIG_KEXEC */
 #endif /* LINUX_KEXEC_H */
diff --git a/kernel/kexec.c b/kernel/kexec.c
index 87ebe8a..182c2f3 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -40,6 +40,9 @@
 #include <asm/system.h>
 #include <asm/sections.h>
 
+int kdump_on_safe;
+int kdump_might_fail;
+
 /* Per cpu memory for storing cpu states in case of system crash. */
 note_buf_t __percpu *crash_notes;
 
@@ -1064,6 +1067,11 @@ asmlinkage long compat_sys_kexec_load(unsigned long entry,
 
 void crash_kexec(struct pt_regs *regs)
 {
+	if (kdump_on_safe && kdump_might_fail) {
+		printk(KERN_EMERG "kexec cancelled due to unstable system.\n");
+		return;
+	}
+
 	/* Take the kexec_mutex here to prevent sys_kexec_load
 	 * running on one cpu from replacing the crash kernel
 	 * we are using after a panic on a different cpu.
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 8686b0f..8564e5c 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -156,6 +156,10 @@ extern int unaligned_dump_stack;
 
 extern struct ratelimit_state printk_ratelimit_state;
 
+#ifdef CONFIG_KEXEC
+extern int kdump_on_safe;
+#endif
+
 #ifdef CONFIG_PROC_SYSCTL
 static int proc_do_cad_pid(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos);
@@ -926,6 +930,15 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 #endif
+#ifdef CONFIG_KEXEC
+	{
+		.procname	= "kdump_on_safe",
+		.data		= &kdump_on_safe,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
-- 
1.7.3.2
</*__NOTE_THIS_PATCH_IS_NOT_READY_TO_APPLY__*>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
