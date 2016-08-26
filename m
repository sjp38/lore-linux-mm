Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8DE1830BE
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 12:30:14 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p85so56445138lfg.3
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 09:30:14 -0700 (PDT)
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [46.235.227.227])
        by mx.google.com with ESMTPS id w6si38080975wmw.38.2016.08.26.09.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Aug 2016 09:30:13 -0700 (PDT)
From: robert.foss@collabora.com
Subject: [PATCH v1] mm, sysctl: Add sysctl for controlling VM_MAYEXEC taint
Date: Fri, 26 Aug 2016 12:30:04 -0400
Message-Id: <1472229004-9658-1-git-send-email-robert.foss@collabora.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, dave.hansen@linux.intel.com, hannes@cmpxchg.org, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, acme@redhat.com, keescook@chromium.org, mgorman@techsingularity.net, atomlin@redhat.com, hughd@google.com, dyoung@redhat.com, viro@zeniv.linux.org.uk, dcashman@google.com, w@1wt.eu, idryomov@gmail.com, yang.shi@linaro.org, wad@chromium.org, vkuznets@redhat.com, vdavydov@virtuozzo.com, vitalywool@gmail.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, koct9i@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, kuleshovmail@gmail.com, minchan@kernel.org, mguzik@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, krasin@google.com, Roland McGrath <mcgrathr@chromium.org>, Mandeep Singh Baines <msb@chromium.org>, Ben Zhang <benzh@chromium.org>, Filipe Brandenburger <filbranden@chromium.org>
Cc: Robert Foss <robert.foss@collabora.com>

From: Will Drewry <wad@chromium.org>

This patch proposes a sysctl knob that allows a privileged user to
disable ~VM_MAYEXEC tainting when mapping in a vma from a MNT_NOEXEC
mountpoint.  It does not alter the normal behavior resulting from
attempting to directly mmap(PROT_EXEC) a vma (-EPERM) nor the behavior
of any other subsystems checking MNT_NOEXEC.

It is motivated by a common /dev/shm, /tmp usecase. There are few
facilities for creating a shared memory segment that can be remapped in
the same process address space with different permissions.  Often, a
file in /tmp provides this functionality.  However, on distributions
that are more restrictive/paranoid, world-writeable directories are
often mounted "noexec".  The only workaround to support software that
needs this behavior is to either not use that software or remount /tmp
exec.  (E.g., https://bugs.gentoo.org/350336?id=350336)  Given that
the only recourse is using SysV IPC, the application programmer loses
many of the useful ABI features that they get using a mmap'd file.

With this patch, it would be possible to change the sysctl variable
such that mprotect(PROT_EXEC) would succeed.  In cases like the example
above, an additional userspace mmap-wrapper would be needed, but in
other cases, like how code.google.com/p/nativeclient mmap()s then
mprotect()s, the behavior would be unaffected.

The tradeoff is a loss of defense in depth, but it seems reasonable when
the alternative is frequently to disable the defense entirely.

(There are many other ways to approach this problem, but this seemed to
 be the most practical and feel the least like a hack or a major change.)

Signed-off-by: Will Drewry <wad@chromium.org>
Signed-off-by: Robert Foss <robert.foss@collabora.com>
Tested-by: Robert Foss <robert.foss@collabora.com>
---
 include/linux/mm.h |  2 ++
 kernel/sysctl.c    |  9 +++++++++
 mm/Kconfig         | 17 +++++++++++++++++
 mm/mmap.c          |  3 ++-
 mm/util.c          |  1 +
 5 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 08ed53e..e2090c5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -108,6 +108,8 @@ extern int mmap_rnd_compat_bits __read_mostly;
 
 extern int sysctl_max_map_count;
 
+extern int sysctl_mmap_noexec_taint;
+
 extern unsigned long sysctl_user_reserve_kbytes;
 extern unsigned long sysctl_admin_reserve_kbytes;
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index b43d0b2..ab1d714 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1564,6 +1564,15 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= mmap_min_addr_handler,
 	},
+	{
+		.procname	= "mmap_noexec_taint",
+		.data		= &sysctl_mmap_noexec_taint,
+		.maxlen		= sizeof(sysctl_mmap_noexec_taint),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 #endif
 #ifdef CONFIG_NUMA
 	{
diff --git a/mm/Kconfig b/mm/Kconfig
index 78a23c5..08d9bc8 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -353,6 +353,23 @@ config DEFAULT_MMAP_MIN_ADDR
 	  This value can be changed after boot using the
 	  /proc/sys/vm/mmap_min_addr tunable.
 
+config MMAP_NOEXEC_TAINT
+	int "Turns on tainting of mmap()d files from noexec mountpoints"
+	depends on MMU
+	default 1
+	help
+	  By default, the ability to change the protections of a virtual
+	  memory area to allow execution depend on if the vma has the
+	  VM_MAYEXEC flag.  When mapping regions from files, VM_MAYEXEC
+	  will be unset if the containing mountpoint is mounted MNT_NOEXEC.
+	  By setting the value to 0, any mmap()d region may be later
+	  mprotect()d with PROT_EXEC.
+
+	  If unsure, keep the value set to 1.
+
+	  This value can be changed after boot using the
+	  /proc/sys/vm/mmap_noexec_taint tunable.
+
 config ARCH_SUPPORTS_MEMORY_FAILURE
 	bool
 
diff --git a/mm/mmap.c b/mm/mmap.c
index ca9d91b..b8be093 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1246,7 +1246,8 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			if (path_noexec(&file->f_path)) {
 				if (vm_flags & VM_EXEC)
 					return -EPERM;
-				vm_flags &= ~VM_MAYEXEC;
+				if (sysctl_mmap_noexec_taint)
+					vm_flags &= ~VM_MAYEXEC;
 			}
 
 			if (!file->f_op->mmap)
diff --git a/mm/util.c b/mm/util.c
index 662cddf..701f0a3 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -430,6 +430,7 @@ int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;
 int sysctl_overcommit_ratio __read_mostly = 50;
 unsigned long sysctl_overcommit_kbytes __read_mostly;
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
+int sysctl_mmap_noexec_taint __read_mostly = CONFIG_MMAP_NOEXEC_TAINT;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
 unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
