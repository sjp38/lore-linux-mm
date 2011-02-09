Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC3C68D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 11:38:39 -0500 (EST)
From: Seiji Aguchi <seiji.aguchi@hds.com>
Date: Wed, 9 Feb 2011 11:35:43 -0500
Subject: [RFC][PATCH v2] Controlling kexec behaviour when hardware error
 happened.
Message-ID: <5C4C569E8A4B9B42A84A977CF070A35B2C1494DBE0@USINDEVS01.corp.hds.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hpa@zytor.com" <hpa@zytor.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "bp@alien8.de" <bp@alien8.de>, "seto.hidetoshi@jp.fujitsu.com" <seto.hidetoshi@jp.fujitsu.com>, "gregkh@suse.de" <gregkh@suse.de>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, "amwang@redhat.com" <amwang@redhat.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>

Hi,

I submitted a quite similar patch last December.

http://www.spinics.net/lists/linux-mm/msg13157.html

I retry it with different description of the purpose.

[Changelog]
from v1:
    - Change name of sysctl parameter ,kexec_on_mce, to kexec_on_hwerr.=20
    - Move variable declaration from <asm/mce.h> to <kernel/panic.h>.
    - Remove CONFIG_X86_MCE in *.c files.
    - Modify [Purpose]/[Patch Description].

[Purpose]
There are some logging features of firmware/hardware, SEL,BMC, etc, in ente=
rprise servers.
We investigate the firmware/hardware logs first when MCE occurred and repla=
ce the broken hardware.
So, memory dump is not necessary for detecting root cause of machine check.
Also, we can reduce down-time by skipping kdump.

Of course, there are a lot of servers which don't have logging features of =
firmware/hardware.
So, I proposed a option controlling kexec behaviour when hardware error occ=
urred.=20

[Patch Description]
This patch adds a sysctl option ,kernel.kexec_on_hwerr, controlling kexec b=
ehaviour when hardware error occurred.

 - Permission
=1B$B!!!!=1B(B- 0644
 - Value(default is "1")
   - non-zero: Kexec is enabled regardless of hardware error.
   - 0: Kexec is disabled when MCE occurred.
  =20

Matrix of kernel.kexec_on_hwerr value ,hardware error and kexec

--------------------------------------------------
kernel.kexec_on_hwerr| hardware error | kexec
--------------------------------------------------
non-zero             | occurred       | enabled
                     -----------------------------
                     | not occurred   | enabled
--------------------------------------------------
0                    | occurred       | disabled
                     |----------------------------
                     | not occurred   | enabled
--------------------------------------------------


Any comments and suggestions are welcome.

 Signed-off-by: Seiji Aguchi <seiji.aguchi@hds.com>

---
 Documentation/sysctl/kernel.txt  |   11 +++++++++++
 arch/x86/kernel/cpu/mcheck/mce.c |    2 ++
 include/linux/kernel.h           |    2 ++
 include/linux/sysctl.h           |    1 +
 kernel/panic.c                   |   15 ++++++++++++++-
 kernel/sysctl.c                  |    8 ++++++++
 kernel/sysctl_binary.c           |    1 +
 mm/memory-failure.c              |    2 ++
 8 files changed, 41 insertions(+), 1 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.=
txt index 11d5ced..3159111 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -34,6 +34,7 @@ show up in /proc/sys/kernel:
 - hotplug
 - java-appletviewer           [ binfmt_java, obsolete ]
 - java-interpreter            [ binfmt_java, obsolete ]
+- kexec_on_hwerr              [ x86 only ]
 - kptr_restrict
 - kstack_depth_to_print       [ X86 only ]
 - l2cr                        [ PPC only ]
@@ -261,6 +262,16 @@ This flag controls the L2 cache of G3 processor boards=
. If  0, the cache is disabled. Enabled if nonzero.
=20
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+kexec_on_hwerr: (X86 only)
+
+Controls the behaviour of kexec when panic occurred due to hardware=20
+error.
+Default value is 1.
+
+0: Kexec is disabled.
+non-zero: Kexec is enabled.
+
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
 kptr_restrict:
=20
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/=
mce.c
index d916183..e76b47b 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -944,6 +944,8 @@ void do_machine_check(struct pt_regs *regs, long error_=
code)
=20
 	percpu_inc(mce_exception_count);
=20
+	hwerr_flag =3D 1;
+
 	if (notify_die(DIE_NMI, "machine check", regs, error_code,
 			   18, SIGKILL) =3D=3D NOTIFY_STOP)
 		goto out;
diff --git a/include/linux/kernel.h b/include/linux/kernel.h index 2fe6e84.=
.c2fba7c 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -242,6 +242,8 @@ extern void add_taint(unsigned flag);  extern int test_=
taint(unsigned flag);  extern unsigned long get_taint(void);  extern int ro=
ot_mountflags;
+extern int kexec_on_hwerr;
+extern int hwerr_flag;
=20
 extern bool early_boot_irqs_disabled;
=20
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h index 7bb5cb6.=
.8ae5bfe 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -153,6 +153,7 @@ enum
 	KERN_MAX_LOCK_DEPTH=3D74, /* int: rtmutex's maximum lock depth */
 	KERN_NMI_WATCHDOG=3D75, /* int: enable/disable nmi watchdog */
 	KERN_PANIC_ON_NMI=3D76, /* int: whether we will panic on an unrecovered *=
/
+	KERN_KEXEC_ON_HWERR=3D77, /* int: bevaviour of kexec for hardware error=20
+*/
 };
=20
=20
diff --git a/kernel/panic.c b/kernel/panic.c index 991bb87..84c1d2e 100644
--- a/kernel/panic.c
+++ b/kernel/panic.c
@@ -28,6 +28,8 @@
 #define PANIC_BLINK_SPD 18
=20
 int panic_on_oops;
+int kexec_on_hwerr =3D 1;
+int hwerr_flag;
 static unsigned long tainted_mask;
 static int pause_on_oops;
 static int pause_on_oops_flag;
@@ -45,6 +47,16 @@ static long no_blink(int state)
 	return 0;
 }
=20
+static int kexec_should_skip(void)
+{
+	if (!kexec_on_hwerr && hwerr_flag) {
+		printk(KERN_WARNING "Kexec is skipped because hardware error "
+		       "occurred.\n");
+		return 1;
+	}
+	return 0;
+}
+
 /* Returns how long it waited in ms */
 long (*panic_blink)(int state);
 EXPORT_SYMBOL(panic_blink);
@@ -86,7 +98,8 @@ NORET_TYPE void panic(const char * fmt, ...)
 	 * everything else.
 	 * Do we want to call this before we try to display a message?
 	 */
-	crash_kexec(NULL);
+	if (!kexec_should_skip())
+		crash_kexec(NULL);
=20
 	kmsg_dump(KMSG_DUMP_PANIC);
=20
diff --git a/kernel/sysctl.c b/kernel/sysctl.c index 0f1bd83..f78edd8 10064=
4
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -811,6 +811,14 @@ static struct ctl_table kern_table[] =3D {
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec,
 	},
+	{
+		.procname	=3D "kexec_on_hwerr",
+		.data		=3D &kexec_on_hwerr,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec,
+	},
+
 #endif
 #if defined(CONFIG_MMU)
 	{
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c index b875bed.=
.8d572ca 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -137,6 +137,7 @@ static const struct bin_table bin_kern_table[] =3D {
 	{ CTL_INT,	KERN_COMPAT_LOG,		"compat-log" },
 	{ CTL_INT,	KERN_MAX_LOCK_DEPTH,		"max_lock_depth" },
 	{ CTL_INT,	KERN_PANIC_ON_NMI,		"panic_on_unrecovered_nmi" },
+	{ CTL_INT,	KERN_KEXEC_ON_HWERR,		"kexec_on_hwerr" },
 	{}
 };
=20
diff --git a/mm/memory-failure.c b/mm/memory-failure.c index 0207c2f..0178f=
47 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -994,6 +994,8 @@ int __memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	int res;
 	unsigned int nr_pages;
=20
+	hwerr_flag =3D 1;
+
 	if (!sysctl_memory_failure_recovery)
 		panic("Memory failure from trap %d on page %lx", trapno, pfn);
=20
--
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
