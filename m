Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 33E176B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 17:15:02 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so21970044pbc.39
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 14:15:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qx4si9438982pbc.45.2013.12.03.14.15.00
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 14:15:00 -0800 (PST)
Date: Tue, 3 Dec 2013 14:14:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5] mm: add overcommit_kbytes sysctl variable
Message-Id: <20131203141458.5e0980df43c7a248578b3e72@linux-foundation.org>
In-Reply-To: <529DDDAF.1000202@redhat.com>
References: <1382101019-23563-1-git-send-email-jmarchan@redhat.com>
	<1382101019-23563-2-git-send-email-jmarchan@redhat.com>
	<529DDDAF.1000202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com

On Tue, 03 Dec 2013 14:33:35 +0100 Jerome Marchand <jmarchan@redhat.com> wrote:

> 
> Changes since v4:
>  - revert to my initial overcommit_kbytes design as it is more
>  consistent with current *_ratio/*_bytes implementation for other
>  variables.
> 
> Some applications that run on HPC clusters are designed around the
> availability of RAM and the overcommit ratio is fine tuned to get the
> maximum usage of memory without swapping. With growing memory, the
> 1%-of-all-RAM grain provided by overcommit_ratio has become too coarse
> for these workload (on a 2TB machine it represents no less than
> 20GB).
> 
> This patch adds the new overcommit_kbytes sysctl variable that allow a
> much finer grain.

Seems OK to me.

> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -574,6 +575,17 @@ The default value is 0.
>  
>  ==============================================================
>  
> +overcommit_kbytes:
> +
> +When overcommit_memory is set to 2, the committed address space is not
> +permitted to exceed swap plus this amount of physical RAM. See below.
> +
> +Note: overcommit_kbytes is the counterpart of overcommit_ratio. Only one
> +of them may be specified at a time. Setting one disable the other (which


--- a/Documentation/sysctl/vm.txt~mm-add-overcommit_kbytes-sysctl-variable-fix
+++ a/Documentation/sysctl/vm.txt
@@ -581,7 +581,7 @@ When overcommit_memory is set to 2, the
 permitted to exceed swap plus this amount of physical RAM. See below.
 
 Note: overcommit_kbytes is the counterpart of overcommit_ratio. Only one
-of them may be specified at a time. Setting one disable the other (which
+of them may be specified at a time. Setting one disables the other (which
 then appears as 0 when read).
 
 ==============================================================



Please do use checkpatch.

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-add-overcommit_kbytes-sysctl-variable-checkpatch-fixes

WARNING: Non-standard signature: Signed-of-by:
#13: 
Signed-of-by: Jerome Marchand <jmarchan@redhat.com>

WARNING: externs should be avoided in .c files
#115: FILE: kernel/sysctl.c:100:
+extern unsigned long sysctl_overcommit_kbytes;

ERROR: do not initialise globals to 0 or NULL
#142: FILE: mm/mmap.c:89:
+unsigned long sysctl_overcommit_kbytes __read_mostly = 0;

ERROR: do not initialise globals to 0 or NULL
#184: FILE: mm/nommu.c:63:
+unsigned long sysctl_overcommit_kbytes __read_mostly = 0;

total: 2 errors, 2 warnings, 145 lines checked

./patches/mm-add-overcommit_kbytes-sysctl-variable.patch has style problems, please review.

If any of these errors are false positives, please report
them to the maintainer, see CHECKPATCH in MAINTAINERS.

Please run checkpatch prior to sending patches

Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Jerome Marchand <jmarchan@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mm.h |    4 ++++
 kernel/sysctl.c    |    3 ---
 mm/mmap.c          |    2 +-
 mm/nommu.c         |    2 +-
 4 files changed, 6 insertions(+), 5 deletions(-)

diff -puN include/linux/mm.h~mm-add-overcommit_kbytes-sysctl-variable-checkpatch-fixes include/linux/mm.h
--- a/include/linux/mm.h~mm-add-overcommit_kbytes-sysctl-variable-checkpatch-fixes
+++ a/include/linux/mm.h
@@ -57,6 +57,10 @@ extern int sysctl_legacy_va_layout;
 extern unsigned long sysctl_user_reserve_kbytes;
 extern unsigned long sysctl_admin_reserve_kbytes;
 
+extern int sysctl_overcommit_memory;
+extern int sysctl_overcommit_ratio;
+extern unsigned long sysctl_overcommit_kbytes;
+
 extern int overcommit_ratio_handler(struct ctl_table *, int, void __user *,
 				    size_t *, loff_t *);
 extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
diff -puN kernel/sysctl.c~mm-add-overcommit_kbytes-sysctl-variable-checkpatch-fixes kernel/sysctl.c
--- a/kernel/sysctl.c~mm-add-overcommit_kbytes-sysctl-variable-checkpatch-fixes
+++ a/kernel/sysctl.c
@@ -95,9 +95,6 @@
 #if defined(CONFIG_SYSCTL)
 
 /* External variables not in a header file. */
-extern int sysctl_overcommit_memory;
-extern int sysctl_overcommit_ratio;
-extern unsigned long sysctl_overcommit_kbytes;
 extern int max_threads;
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
diff -puN mm/mmap.c~mm-add-overcommit_kbytes-sysctl-variable-checkpatch-fixes mm/mmap.c
--- a/mm/mmap.c~mm-add-overcommit_kbytes-sysctl-variable-checkpatch-fixes
+++ a/mm/mmap.c
@@ -86,7 +86,7 @@ EXPORT_SYMBOL(vm_get_page_prot);
 
 int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic overcommit */
 int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
-unsigned long sysctl_overcommit_kbytes __read_mostly = 0;
+unsigned long sysctl_overcommit_kbytes __read_mostly;
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
 unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
diff -puN mm/nommu.c~mm-add-overcommit_kbytes-sysctl-variable-checkpatch-fixes mm/nommu.c
--- a/mm/nommu.c~mm-add-overcommit_kbytes-sysctl-variable-checkpatch-fixes
+++ a/mm/nommu.c
@@ -60,7 +60,7 @@ unsigned long highest_memmap_pfn;
 struct percpu_counter vm_committed_as;
 int sysctl_overcommit_memory = OVERCOMMIT_GUESS; /* heuristic overcommit */
 int sysctl_overcommit_ratio = 50; /* default is 50% */
-unsigned long sysctl_overcommit_kbytes __read_mostly = 0;
+unsigned long sysctl_overcommit_kbytes __read_mostly;
 int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
 int sysctl_nr_trim_pages = CONFIG_NOMMU_INITIAL_TRIM_EXCESS;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
