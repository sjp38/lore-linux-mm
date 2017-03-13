Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB996B038D
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:14:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n11so15927423wma.5
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:14:24 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Subject: [RFC PATCH 01/13] mm: Add mm_struct argument to 'mmap_region'
Date: Mon, 13 Mar 2017 15:14:03 -0700
Message-Id: <20170313221415.9375-2-till.smejkal@gmail.com>
In-Reply-To: <20170313221415.9375-1-till.smejkal@gmail.com>
References: <20170313221415.9375-1-till.smejkal@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

Add to the 'mmap_region' function the mm_struct that it should operate on
as additional argument. Before, the function simply used the memory map of
the current task. However, with the introduction of first class virtual
address spaces, mmap_region needs also be able to operate on other memory
maps than only the current task ones. By adding it as argument we can now
explicitly define which memory map to use.

Signed-off-by: Till Smejkal <till.smejkal@gmail.com>
---
 arch/mips/kernel/vdso.c |  2 +-
 arch/tile/mm/elf.c      |  2 +-
 include/linux/mm.h      |  5 +++--
 mm/mmap.c               | 10 +++++-----
 4 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
index f9dbfb14af33..9631b42908f3 100644
--- a/arch/mips/kernel/vdso.c
+++ b/arch/mips/kernel/vdso.c
@@ -108,7 +108,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		return -EINTR;
 
 	/* Map delay slot emulation page */
-	base = mmap_region(NULL, STACK_TOP, PAGE_SIZE,
+	base = mmap_region(mm, NULL, STACK_TOP, PAGE_SIZE,
 			   VM_READ|VM_WRITE|VM_EXEC|
 			   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
 			   0);
diff --git a/arch/tile/mm/elf.c b/arch/tile/mm/elf.c
index 6225cc998db1..a22768059b7a 100644
--- a/arch/tile/mm/elf.c
+++ b/arch/tile/mm/elf.c
@@ -141,7 +141,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	 */
 	if (!retval) {
 		unsigned long addr = MEM_USER_INTRPT;
-		addr = mmap_region(NULL, addr, INTRPT_SIZE,
+		addr = mmap_region(mm, NULL, addr, INTRPT_SIZE,
 				   VM_READ|VM_EXEC|
 				   VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC, 0);
 		if (addr > (unsigned long) -PAGE_SIZE)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b84615b0f64c..fa483d2ff3eb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2016,8 +2016,9 @@ extern int install_special_mapping(struct mm_struct *mm,
 
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
-extern unsigned long mmap_region(struct file *file, unsigned long addr,
-	unsigned long len, vm_flags_t vm_flags, unsigned long pgoff);
+extern unsigned long mmap_region(struct mm_struct *mm, struct file *file,
+				 unsigned long addr, unsigned long len,
+				 vm_flags_t vm_flags, unsigned long pgoff);
 extern unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot, unsigned long flags,
 	vm_flags_t vm_flags, unsigned long pgoff, unsigned long *populate);
diff --git a/mm/mmap.c b/mm/mmap.c
index dc4291dcc99b..5ac276ac9807 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1447,7 +1447,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 			vm_flags |= VM_NORESERVE;
 	}
 
-	addr = mmap_region(file, addr, len, vm_flags, pgoff);
+	addr = mmap_region(mm, file, addr, len, vm_flags, pgoff);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
 	     (flags & (MAP_POPULATE | MAP_NONBLOCK)) == MAP_POPULATE))
@@ -1582,10 +1582,10 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
 }
 
-unsigned long mmap_region(struct file *file, unsigned long addr,
-		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff)
+unsigned long mmap_region(struct mm_struct *mm, struct file *file,
+		unsigned long addr, unsigned long len, vm_flags_t vm_flags,
+		unsigned long pgoff)
 {
-	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
 	int error;
 	struct rb_node **rb_link, *rb_parent;
@@ -1704,7 +1704,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	vm_stat_account(mm, vm_flags, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
-					vma == get_gate_vma(current->mm)))
+					vma == get_gate_vma(mm)))
 			mm->locked_vm += (len >> PAGE_SHIFT);
 		else
 			vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
