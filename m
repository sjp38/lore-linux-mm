Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2A06B0253
	for <linux-mm@kvack.org>; Sun,  5 Nov 2017 07:19:09 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id b79so7969103pfk.9
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 04:19:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j11sor3011952plt.137.2017.11.05.04.19.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 05 Nov 2017 04:19:07 -0800 (PST)
Date: Sun, 5 Nov 2017 23:18:50 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
Message-ID: <20171105231850.5e313e46@roar.ozlabs.ibm.com>
In-Reply-To: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
References: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

On Fri, 3 Nov 2017 18:05:20 +0100
Florian Weimer <fweimer@redhat.com> wrote:

> We are seeing an issue on ppc64le and ppc64 (and perhaps on some arm 
> variant, but I have not seen it on our own builders) where running 
> localedef as part of the glibc build crashes with a segmentation fault.
> 
> Kernel version is 4.13.9 (Fedora 26 variant).
> 
> I have only seen this with an explicit loader invocation, like this:
> 
> while I18NPATH=. /lib64/ld64.so.1 /usr/bin/localedef 
> --alias-file=../intl/locale.alias --no-archive -i locales/nl_AW -c -f 
> charmaps/UTF-8 
> --prefix=/builddir/build/BUILDROOT/glibc-2.26-16.fc27.ppc64 nl_AW ; do : 
> ; done
> 
> To be run in the localedata subdirectory of a glibc *source* tree, after 
> a build.  You may have to create the 
> /builddir/build/BUILDROOT/glibc-2.26-16.fc27.ppc64/usr/lib/locale 
> directory.  I have only reproduced this inside a Fedora 27 chroot on a 
> Fedora 26 host, but there it does not matter if you run the old (chroot) 
> or newly built binary.
> 
> I filed this as a glibc bug for tracking:
> 
>    https://sourceware.org/bugzilla/show_bug.cgi?id=22390
> 
> There's an strace log and a coredump from the crash.
> 
> I think the data shows that the address in question should be writable.
> 
> The crossed 0x0000800000000000 binary is very suggestive.  I think that 
> based on the operation of glibc's malloc, this write would be the first 
> time this happens during the lifetime of the process.
> 
> Does that ring any bells?  Is there anything I can do to provide more 
> data?  The host is an LPAR with a stock Fedora 26 kernel, so I can use 
> any diagnostics tool which is provided by Fedora.

There was a recent change to move to 128TB address space by default,
and option for 512TB addresses if explicitly requested.

Your brk request asked for > 128TB which the kernel gave it, but the
address limit in the paca that the SLB miss tests against was not
updated to reflect the switch to 512TB address space.

Why is your brk starting so high? Are you trying to test the > 128TB
case, or maybe something is confused by the 64->128TB change? What's
the strace look like if you run on a distro or <= 4.10 kernel?

Something like the following patch may help if you could test.

Thanks,
Nick

---
 arch/powerpc/mm/hugetlbpage-radix.c    | 18 ++++++++++++++----
 arch/powerpc/mm/mmap.c                 | 34 +++++++++++++++++++++++++---------
 arch/powerpc/mm/mmu_context_book3s64.c | 14 +++++++-------
 arch/powerpc/mm/slice.c                | 28 +++++++++++++++++++---------
 4 files changed, 65 insertions(+), 29 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage-radix.c b/arch/powerpc/mm/hugetlbpage-radix.c
index a12e86395025..44e1109765b5 100644
--- a/arch/powerpc/mm/hugetlbpage-radix.c
+++ b/arch/powerpc/mm/hugetlbpage-radix.c
@@ -50,8 +50,16 @@ radix__hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	struct hstate *h = hstate_file(file);
 	struct vm_unmapped_area_info info;
 
-	if (unlikely(addr > mm->context.addr_limit && addr < TASK_SIZE))
-		mm->context.addr_limit = TASK_SIZE;
+	/*
+	 * If address is specified explicitly and crosses addr_limit, or if
+	 * address is unspecified but len is greater than addr_limit, then
+	 * expand out to TASK_SIZE.
+	 */
+	if (unlikely(addr + len >= mm->context.addr_limit)) {
+		if ((!addr || addr + len > mm->context.addr_limit) &&
+				mm->context.addr_limit != TASK_SIZE)
+			mm->context.addr_limit = TASK_SIZE;
+	}
 
 	if (len & ~huge_page_mask(h))
 		return -EINVAL;
@@ -82,8 +90,10 @@ radix__hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
 	info.align_offset = 0;
 
-	if (addr > DEFAULT_MAP_WINDOW)
-		info.high_limit += mm->context.addr_limit - DEFAULT_MAP_WINDOW;
+	if (addr + len >= DEFAULT_MAP_WINDOW) {
+		if (!addr || addr + len > DEFAULT_MAP_WINDOW)
+			info.high_limit += mm->context.addr_limit - DEFAULT_MAP_WINDOW;
+	}
 
 	return vm_unmapped_area(&info);
 }
diff --git a/arch/powerpc/mm/mmap.c b/arch/powerpc/mm/mmap.c
index 5d78b193fec4..a8fe1eaf1d96 100644
--- a/arch/powerpc/mm/mmap.c
+++ b/arch/powerpc/mm/mmap.c
@@ -108,9 +108,16 @@ radix__arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	struct vm_area_struct *vma;
 	struct vm_unmapped_area_info info;
 
-	if (unlikely(addr > mm->context.addr_limit &&
-		     mm->context.addr_limit != TASK_SIZE))
-		mm->context.addr_limit = TASK_SIZE;
+	/*
+	 * If address is specified explicitly and crosses addr_limit, or if
+	 * address is unspecified but len is greater than addr_limit, then
+	 * expand out to TASK_SIZE.
+	 */
+	if (unlikely(addr + len >= mm->context.addr_limit)) {
+		if ((!addr || addr + len > mm->context.addr_limit) &&
+				mm->context.addr_limit != TASK_SIZE)
+			mm->context.addr_limit = TASK_SIZE;
+	}
 
 	if (len > mm->task_size - mmap_min_addr)
 		return -ENOMEM;
@@ -131,7 +138,7 @@ radix__arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.low_limit = mm->mmap_base;
 	info.align_mask = 0;
 
-	if (unlikely(addr > DEFAULT_MAP_WINDOW))
+	if (unlikely(addr + len > DEFAULT_MAP_WINDOW))
 		info.high_limit = mm->context.addr_limit;
 	else
 		info.high_limit = DEFAULT_MAP_WINDOW;
@@ -151,9 +158,16 @@ radix__arch_get_unmapped_area_topdown(struct file *filp,
 	unsigned long addr = addr0;
 	struct vm_unmapped_area_info info;
 
-	if (unlikely(addr > mm->context.addr_limit &&
-		     mm->context.addr_limit != TASK_SIZE))
-		mm->context.addr_limit = TASK_SIZE;
+	/*
+	 * If address is specified explicitly and crosses addr_limit, or if
+	 * address is unspecified but len is greater than addr_limit, then
+	 * expand out to TASK_SIZE.
+	 */
+	if (unlikely(addr + len >= mm->context.addr_limit)) {
+		if ((!addr || addr + len > mm->context.addr_limit) &&
+				mm->context.addr_limit != TASK_SIZE)
+			mm->context.addr_limit = TASK_SIZE;
+	}
 
 	/* requested length too big for entire address space */
 	if (len > mm->task_size - mmap_min_addr)
@@ -177,8 +191,10 @@ radix__arch_get_unmapped_area_topdown(struct file *filp,
 	info.high_limit = mm->mmap_base;
 	info.align_mask = 0;
 
-	if (addr > DEFAULT_MAP_WINDOW)
-		info.high_limit += mm->context.addr_limit - DEFAULT_MAP_WINDOW;
+	if (addr + len >= DEFAULT_MAP_WINDOW) {
+		if (!addr || addr + len > DEFAULT_MAP_WINDOW)
+			info.high_limit += mm->context.addr_limit - DEFAULT_MAP_WINDOW;
+	}
 
 	addr = vm_unmapped_area(&info);
 	if (!(addr & ~PAGE_MASK))
diff --git a/arch/powerpc/mm/mmu_context_book3s64.c b/arch/powerpc/mm/mmu_context_book3s64.c
index 05e15386d4cb..1116ea0ddb2e 100644
--- a/arch/powerpc/mm/mmu_context_book3s64.c
+++ b/arch/powerpc/mm/mmu_context_book3s64.c
@@ -92,13 +92,6 @@ static int hash__init_new_context(struct mm_struct *mm)
 	if (index < 0)
 		return index;
 
-	/*
-	 * We do switch_slb() early in fork, even before we setup the
-	 * mm->context.addr_limit. Default to max task size so that we copy the
-	 * default values to paca which will help us to handle slb miss early.
-	 */
-	mm->context.addr_limit = DEFAULT_MAP_WINDOW_USER64;
-
 	/*
 	 * The old code would re-promote on fork, we don't do that when using
 	 * slices as it could cause problem promoting slices that have been
@@ -162,6 +155,13 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	if (index < 0)
 		return index;
 
+	/*
+	 * In the case of exec, use the default limit,
+	 * otherwise inherit it from the mm we are duplicating.
+	 */
+	if (!mm->context.addr_limit)
+		mm->context.addr_limit = DEFAULT_MAP_WINDOW_USER64;
+
 	mm->context.id = index;
 
 #ifdef CONFIG_PPC_64K_PAGES
diff --git a/arch/powerpc/mm/slice.c b/arch/powerpc/mm/slice.c
index 45f6740dd407..aa55523b6759 100644
--- a/arch/powerpc/mm/slice.c
+++ b/arch/powerpc/mm/slice.c
@@ -329,7 +329,7 @@ static unsigned long slice_find_area_topdown(struct mm_struct *mm,
 	 * Only for that request for which high_limit is above
 	 * DEFAULT_MAP_WINDOW we should apply this.
 	 */
-	if (high_limit  > DEFAULT_MAP_WINDOW)
+	if (high_limit > DEFAULT_MAP_WINDOW)
 		addr += mm->context.addr_limit - DEFAULT_MAP_WINDOW;
 
 	while (addr > PAGE_SIZE) {
@@ -418,19 +418,29 @@ unsigned long slice_get_unmapped_area(unsigned long addr, unsigned long len,
 
 	/*
 	 * Check if we need to expland slice area.
+	 *
+	 * If address is specified explicitly and crosses addr_limit, or if
+	 * address is unspecified but len is greater than addr_limit, then
+	 * expand out to TASK_SIZE.
 	 */
-	if (unlikely(addr > mm->context.addr_limit &&
-		     mm->context.addr_limit != TASK_SIZE)) {
-		mm->context.addr_limit = TASK_SIZE;
-		on_each_cpu(slice_flush_segments, mm, 1);
+	if (unlikely(addr + len >= mm->context.addr_limit)) {
+		if ((!addr || addr + len > mm->context.addr_limit) &&
+				mm->context.addr_limit != TASK_SIZE) {
+			mm->context.addr_limit = TASK_SIZE;
+			on_each_cpu(slice_flush_segments, mm, 1);
+		}
 	}
+
 	/*
 	 * This mmap request can allocate upt to 512TB
 	 */
-	if (addr > DEFAULT_MAP_WINDOW)
-		high_limit = mm->context.addr_limit;
-	else
-		high_limit = DEFAULT_MAP_WINDOW;
+	high_limit = DEFAULT_MAP_WINDOW;
+	if (addr + len >= DEFAULT_MAP_WINDOW) {
+		if (!addr || addr + len > DEFAULT_MAP_WINDOW)
+			high_limit = mm->context.addr_limit;
+	}
+
+
 	/*
 	 * init different masks
 	 */
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
