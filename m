Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B24816B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 19:14:18 -0500 (EST)
From: Seiji Aguchi <seiji.aguchi@hds.com>
Date: Wed, 22 Dec 2010 18:35:40 -0500
Subject: [RFC][PATCH] Add a sysctl option controlling kexec when MCE occurred
Message-ID: <5C4C569E8A4B9B42A84A977CF070A35B2C132F68FC@USINDEVS01.corp.hds.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linuxfoundation.org" <akpm@linuxfoundation.org>, "eugeneteo@kernel.org" <eugeneteo@kernel.org>, "kees.cook@canonical.com" <kees.cook@canonical.com>, "drosenberg@vsecurity.com" <drosenberg@vsecurity.com>, "ying.huang@intel.com" <ying.huang@intel.com>, "len.brown@intel.com" <len.brown@intel.com>, "seto.hidetoshi@jp.fujitsu.com" <seto.hidetoshi@jp.fujitsu.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "davem@davemloft.net" <davem@davemloft.net>, "hadi@cyberus.ca" <hadi@cyberus.ca>, "hawk@comx.dk" <hawk@comx.dk>, "opurdila@ixiacom.com" <opurdila@ixiacom.com>, "hidave.darkstar@gmail.com" <hidave.darkstar@gmail.com>, "dzickus@redhat.com" <dzickus@redhat.com>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>, "ext-andriy.shevchenko@nokia.com" <ext-andriy.shevchenko@nokia.com>, "tj@kernel.org" <tj@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>
Cc: Satoru Moriya <satoru.moriya@hds.com>, Seiji Aguchi <seiji.aguchi@hds.com>
List-ID: <linux-mm.kvack.org>

Hi,

[Purpose]
Kexec may trigger additional hardware errors and multiply the damage=20
if it works after MCE occurred because there are some hardware-related=20
operations in kexec as follows.
  - Sending NMI to cpus
  - Initializing hardware during boot process of second kernel.
  - Accessing to memory and dumping it to disks.

So, I propose adding a new option controlling kexec behaviour when MCE=20
occurred.
This patch prevents unnecessary hardware errors and avoid expanding=20
the damage.

[Patch Description]
I added a sysctl option ,kernel.kexec_on_mce, controlling kexec behaviour=20
when MCE occurred.

 - Permission
   - 0644
 - Value(default is "1")
   - non-zero: Kexec is enabled regardless of MCE.
   - 0: Kexec is disabled when MCE occurred.

Matrix of kernel.kexec_on_mce value, MCE and kexec behaviour

--------------------------------------------------
kernel.kexec_on_mce| MCE          | kexec behaviour
--------------------------------------------------
non-zero           | occurred     | enabled
                   -------------------------------
                   | not occurred | enabled
--------------------------------------------------
0                  | occurred     | disabled
                   |------------------------------
                   | not occurred | enabled
--------------------------------------------------

Any comments and suggestions are welcome.

Signed-off-by: Seiji Aguchi <seiji.aguchi@hds.com>

---
 Documentation/sysctl/kernel.txt  |   12 ++++++++++++
 arch/x86/include/asm/mce.h       |    2 ++
 arch/x86/kernel/cpu/mcheck/mce.c |    4 ++++
 include/linux/sysctl.h           |    1 +
 kernel/kexec.c                   |    7 +++++++
 kernel/sysctl.c                  |   12 ++++++++++++
 kernel/sysctl_binary.c           |    1 +
 mm/memory-failure.c              |    9 +++++++++
 8 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.=
txt
index 209e158..ce3240e 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -34,6 +34,7 @@ show up in /proc/sys/kernel:
 - hotplug
 - java-appletviewer           [ binfmt_java, obsolete ]
 - java-interpreter            [ binfmt_java, obsolete ]
+- kexec_on_mce                [ X86 only ]
 - kstack_depth_to_print       [ X86 only ]
 - l2cr                        [ PPC only ]
 - modprobe                    =3D=3D> Documentation/debugging-modules.txt
@@ -261,6 +262,17 @@ This flag controls the L2 cache of G3 processor boards=
. If
=20
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
+kexec_on_mce: (X86 only)
+
+Controls the kexec behaviour when MCE occurred.
+Default value is 1.
+
+0: Kexec is disabled when MCE occurred.
+non-zero: Kexec is enabled regardless of MCE.
+
+
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
 kstack_depth_to_print: (X86 only)
=20
 Controls the number of words to print when dumping the raw
diff --git a/arch/x86/include/asm/mce.h b/arch/x86/include/asm/mce.h
index c62c13c..062dabd 100644
--- a/arch/x86/include/asm/mce.h
+++ b/arch/x86/include/asm/mce.h
@@ -123,6 +123,8 @@ extern struct atomic_notifier_head x86_mce_decoder_chai=
n;
=20
 extern int mce_disabled;
 extern int mce_p5_enabled;
+extern int kexec_on_mce;
+extern int mce_flag;
=20
 #ifdef CONFIG_X86_MCE
 int mcheck_init(void);
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/=
mce.c
index 7a35b72..edbaf77 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -85,6 +85,8 @@ static int			mce_dont_log_ce		__read_mostly;
 int				mce_cmci_disabled	__read_mostly;
 int				mce_ignore_ce		__read_mostly;
 int				mce_ser			__read_mostly;
+int				kexec_on_mce =3D 1;
+int				mce_flag;
=20
 struct mce_bank                *mce_banks		__read_mostly;
=20
@@ -944,6 +946,8 @@ void do_machine_check(struct pt_regs *regs, long error_=
code)
=20
 	percpu_inc(mce_exception_count);
=20
+	mce_flag =3D 1;
+
 	if (notify_die(DIE_NMI, "machine check", regs, error_code,
 			   18, SIGKILL) =3D=3D NOTIFY_STOP)
 		goto out;
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 7bb5cb6..0ebe708 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -153,6 +153,7 @@ enum
 	KERN_MAX_LOCK_DEPTH=3D74, /* int: rtmutex's maximum lock depth */
 	KERN_NMI_WATCHDOG=3D75, /* int: enable/disable nmi watchdog */
 	KERN_PANIC_ON_NMI=3D76, /* int: whether we will panic on an unrecovered *=
/
+	KERN_KEXEC_ON_MCE=3D77, /* int: whether we will dump memory on mce */
 };
=20
=20
diff --git a/kernel/kexec.c b/kernel/kexec.c
index b55045b..3e5c41a 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -39,6 +39,7 @@
 #include <asm/io.h>
 #include <asm/system.h>
 #include <asm/sections.h>
+#include <asm/mce.h>
=20
 /* Per cpu memory for storing cpu states in case of system crash. */
 note_buf_t __percpu *crash_notes;
@@ -1074,6 +1075,12 @@ void crash_kexec(struct pt_regs *regs)
 	 * of memory the xchg(&kexec_crash_image) would be
 	 * sufficient.  But since I reuse the memory...
 	 */
+#ifdef CONFIG_X86_MCE
+	if (!kexec_on_mce && mce_flag) {
+		printk(KERN_WARNING "Kexec is disabled because MCE occurred\n");
+		return;
+	}
+#endif
 	if (mutex_trylock(&kexec_mutex)) {
 		if (kexec_crash_image) {
 			struct pt_regs fixed_regs;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 5abfa15..3a64cd6 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -81,6 +81,9 @@
 #include <linux/nmi.h>
 #endif
=20
+#ifdef CONFIG_X86_MCE
+#include <asm/mce.h>
+#endif
=20
 #if defined(CONFIG_SYSCTL)
=20
@@ -963,6 +966,15 @@ static struct ctl_table kern_table[] =3D {
 		.proc_handler	=3D proc_dointvec,
 	},
 #endif
+#if defined(CONFIG_X86_MCE)
+	{
+		.procname	=3D "kexec_on_mce",
+		.data		=3D &kexec_on_mce,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec,
+	},
+#endif
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 1357c57..a25f971 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -138,6 +138,7 @@ static const struct bin_table bin_kern_table[] =3D {
 	{ CTL_INT,	KERN_MAX_LOCK_DEPTH,		"max_lock_depth" },
 	{ CTL_INT,	KERN_NMI_WATCHDOG,		"nmi_watchdog" },
 	{ CTL_INT,	KERN_PANIC_ON_NMI,		"panic_on_unrecovered_nmi" },
+	{ CTL_INT,	KERN_KEXEC_ON_MCE,		"kexec_on_mce" },
 	{}
 };
=20
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 46ab2c0..3ec075a 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -52,6 +52,11 @@
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
 #include <linux/memory_hotplug.h>
+
+#ifdef CONFIG_X86_MCE
+#include <asm/mce.h>
+#endif
+
 #include "internal.h"
=20
 int sysctl_memory_failure_early_kill __read_mostly =3D 0;
@@ -949,6 +954,10 @@ int __memory_failure(unsigned long pfn, int trapno, in=
t flags)
 	int res;
 	unsigned int nr_pages;
=20
+#ifdef CONFIG_X86_MCE
+	mce_flag =3D 1;
+#endif
+
 	if (!sysctl_memory_failure_recovery)
 		panic("Memory failure from trap %d on page %lx", trapno, pfn);
=20
--=20
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
