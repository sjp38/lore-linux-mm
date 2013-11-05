Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id C5AF66B00A4
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 18:51:09 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id jt11so8182825pbb.15
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 15:51:09 -0800 (PST)
Received: from psmtp.com ([74.125.245.117])
        by mx.google.com with SMTP id jp3si15065520pbc.186.2013.11.05.15.51.07
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 15:51:08 -0800 (PST)
Date: Tue, 5 Nov 2013 15:51:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 1/2] mm: factor commit limit calculation
Message-Id: <20131105155105.41c9a624689c3262f5141e41@linux-foundation.org>
In-Reply-To: <1382101019-23563-1-git-send-email-jmarchan@redhat.com>
References: <1382101019-23563-1-git-send-email-jmarchan@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com

On Fri, 18 Oct 2013 14:56:58 +0200 Jerome Marchand <jmarchan@redhat.com> wrote:

> Change since v3:
>  - rebase on 3.12-rc5
> 
> The same calculation is currently done in three differents places.
> Factor that code so future changes has to be made at only one place.
> 

lgtm.

> --- a/include/linux/mman.h
> +++ b/include/linux/mman.h
> @@ -7,6 +7,9 @@
>  #include <linux/atomic.h>
>  #include <uapi/linux/mman.h>
>  
> +#include <linux/hugetlb.h>
> +#include <linux/swap.h>
> +
>  extern int sysctl_overcommit_memory;
>  extern int sysctl_overcommit_ratio;
>  extern struct percpu_counter vm_committed_as;
> @@ -87,4 +90,13 @@ calc_vm_flag_bits(unsigned long flags)
>  	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
>  	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
>  }
> +
> +/*
> + * Commited memory limit enforced when OVERCOMMIT_NEVER policy is used
> + */
> +static inline unsigned long vm_commit_limit()
> +{
> +	return ((totalram_pages - hugetlb_total_pages())
> +		* sysctl_overcommit_ratio / 100) + total_swap_pages;
> +}

Not sure I like this part much.  This function is large and slow and
doesn't merit inlining, plus it requires worsening our nested-include
mess.  This?

Also, it should be vm_commit_limit(void).



From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-factor-commit-limit-calculation-fix

Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Jerome Marchand <jmarchan@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mman.h |   12 +-----------
 mm/mmap.c            |    9 +++++++++
 2 files changed, 10 insertions(+), 11 deletions(-)

diff -puN fs/proc/meminfo.c~mm-factor-commit-limit-calculation-fix fs/proc/meminfo.c
diff -puN include/linux/mman.h~mm-factor-commit-limit-calculation-fix include/linux/mman.h
--- a/include/linux/mman.h~mm-factor-commit-limit-calculation-fix
+++ a/include/linux/mman.h
@@ -7,9 +7,6 @@
 #include <linux/atomic.h>
 #include <uapi/linux/mman.h>
 
-#include <linux/hugetlb.h>
-#include <linux/swap.h>
-
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern struct percpu_counter vm_committed_as;
@@ -91,12 +88,5 @@ calc_vm_flag_bits(unsigned long flags)
 	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
 }
 
-/*
- * Commited memory limit enforced when OVERCOMMIT_NEVER policy is used
- */
-static inline unsigned long vm_commit_limit()
-{
-	return ((totalram_pages - hugetlb_total_pages())
-		* sysctl_overcommit_ratio / 100) + total_swap_pages;
-}
+unsigned long vm_commit_limit(void);
 #endif /* _LINUX_MMAN_H */
diff -puN mm/mmap.c~mm-factor-commit-limit-calculation-fix mm/mmap.c
--- a/mm/mmap.c~mm-factor-commit-limit-calculation-fix
+++ a/mm/mmap.c
@@ -110,6 +110,15 @@ unsigned long vm_memory_committed(void)
 EXPORT_SYMBOL_GPL(vm_memory_committed);
 
 /*
+ * Commited memory limit enforced when OVERCOMMIT_NEVER policy is used
+ */
+unsigned long vm_commit_limit(void)
+{
+	return ((totalram_pages - hugetlb_total_pages())
+		* sysctl_overcommit_ratio / 100) + total_swap_pages;
+}
+
+/*
  * Check that a process has enough memory to allocate a new virtual
  * mapping. 0 means there is enough memory for the allocation to
  * succeed and -ENOMEM implies there is not.
diff -puN mm/nommu.c~mm-factor-commit-limit-calculation-fix mm/nommu.c
diff -puN mm/util.c~mm-factor-commit-limit-calculation-fix mm/util.c
diff -puN include/linux/mm.h~mm-factor-commit-limit-calculation-fix include/linux/mm.h
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
