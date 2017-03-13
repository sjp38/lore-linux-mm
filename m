Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0986B039D
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:14:49 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u48so46009536wrc.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:14:49 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Subject: [RFC PATCH 07/13] kernel/fork: Split and export 'mm_alloc' and 'mm_init'
Date: Mon, 13 Mar 2017 15:14:09 -0700
Message-Id: <20170313221415.9375-8-till.smejkal@gmail.com>
In-Reply-To: <20170313221415.9375-1-till.smejkal@gmail.com>
References: <20170313221415.9375-1-till.smejkal@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

The only way until now to create a new memory map was via the exported
function 'mm_alloc'. Unfortunately, this function not only allocates a new
memory map, but also completely initializes it. However, with the
introduction of first class virtual address spaces, some initialization
steps done in 'mm_alloc' are not applicable to the memory maps needed for
this feature and hence would lead to errors in the kernel code.

Instead of introducing a new function that can allocate and initialize
memory maps for first class virtual address spaces and potentially
duplicate some code, I decided to split the mm_alloc function as well as
the 'mm_init' function that it uses.

Now there are four functions exported instead of only one. The new
'mm_alloc' function only allocates a new mm_struct and zeros it out. If one
want to have the old behavior of mm_alloc one can use the newly introduced
function 'mm_alloc_and_setup' which not only allocates a new mm_struct but
also fully initializes it.

The old 'mm_init' function which fully initialized a mm_struct was split up
into two separate functions. The first one - 'mm_setup' - does all the
initialization of the mm_struct that is not related to the mm_struct
belonging to a particular task. This part of the initialization is done in
the 'mm_set_task' function. This way it is possible to create memory maps
that don't have any task-specific information as needed by the first class
virtual address space feature. Both functions, 'mm_setup' and 'mm_set_task'
are also exported, so that they can be used in all files in the source
tree.

Signed-off-by: Till Smejkal <till.smejkal@gmail.com>
---
 arch/arm/mach-rpc/ecard.c |  2 +-
 fs/exec.c                 |  2 +-
 include/linux/sched.h     |  7 +++++-
 kernel/fork.c             | 64 +++++++++++++++++++++++++++++++++++++----------
 4 files changed, 59 insertions(+), 16 deletions(-)

diff --git a/arch/arm/mach-rpc/ecard.c b/arch/arm/mach-rpc/ecard.c
index dc67a7fb3831..15845e8abd7e 100644
--- a/arch/arm/mach-rpc/ecard.c
+++ b/arch/arm/mach-rpc/ecard.c
@@ -245,7 +245,7 @@ static void ecard_init_pgtables(struct mm_struct *mm)
 
 static int ecard_init_mm(void)
 {
-	struct mm_struct * mm = mm_alloc();
+	struct mm_struct *mm = mm_alloc_and_setup();
 	struct mm_struct *active_mm = current->active_mm;
 
 	if (!mm)
diff --git a/fs/exec.c b/fs/exec.c
index e57946610733..68d7908a1e5a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -380,7 +380,7 @@ static int bprm_mm_init(struct linux_binprm *bprm)
 	int err;
 	struct mm_struct *mm = NULL;
 
-	bprm->mm = mm = mm_alloc();
+	bprm->mm = mm = mm_alloc_and_setup();
 	err = -ENOMEM;
 	if (!mm)
 		goto err;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 42b9b93a50ac..7955adc00397 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2922,7 +2922,12 @@ static inline unsigned long sigsp(unsigned long sp, struct ksignal *ksig)
 /*
  * Routines for handling mm_structs
  */
-extern struct mm_struct * mm_alloc(void);
+extern struct mm_struct *mm_setup(struct mm_struct *mm);
+extern struct mm_struct *mm_set_task(struct mm_struct *mm,
+				     struct task_struct *p,
+				     struct user_namespace *user_ns);
+extern struct mm_struct *mm_alloc(void);
+extern struct mm_struct *mm_alloc_and_setup(void);
 
 /* mmdrop drops the mm and the page tables */
 extern void __mmdrop(struct mm_struct *);
diff --git a/kernel/fork.c b/kernel/fork.c
index 11c5c8ab827c..9209f6d5d7c0 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -747,8 +747,10 @@ static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
 #endif
 }
 
-static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
-	struct user_namespace *user_ns)
+/**
+ * Initialize all the task-unrelated fields of a mm_struct.
+ **/
+struct mm_struct *mm_setup(struct mm_struct *mm)
 {
 	mm->mmap = NULL;
 	mm->mm_rb = RB_ROOT;
@@ -767,24 +769,37 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	spin_lock_init(&mm->page_table_lock);
 	mm_init_cpumask(mm);
 	mm_init_aio(mm);
-	mm_init_owner(mm, p);
 	mmu_notifier_mm_init(mm);
 	clear_tlb_flush_pending(mm);
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
 #endif
 
+	mm->flags = default_dump_filter;
+	mm->def_flags = 0;
+
+	if (mm_alloc_pgd(mm))
+		goto fail_nopgd;
+
+	return mm;
+
+fail_nopgd:
+	free_mm(mm);
+	return NULL;
+}
+
+/**
+ * Initialize all the task-related fields of a mm_struct.
+ **/
+struct mm_struct *mm_set_task(struct mm_struct *mm, struct task_struct *p,
+			      struct user_namespace *user_ns)
+{
 	if (current->mm) {
 		mm->flags = current->mm->flags & MMF_INIT_MASK;
 		mm->def_flags = current->mm->def_flags & VM_INIT_DEF_MASK;
-	} else {
-		mm->flags = default_dump_filter;
-		mm->def_flags = 0;
 	}
 
-	if (mm_alloc_pgd(mm))
-		goto fail_nopgd;
-
+	mm_init_owner(mm, p);
 	if (init_new_context(p, mm))
 		goto fail_nocontext;
 
@@ -793,11 +808,21 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 
 fail_nocontext:
 	mm_free_pgd(mm);
-fail_nopgd:
 	free_mm(mm);
 	return NULL;
 }
 
+static struct mm_struct *mm_setup_all(struct mm_struct *mm,
+				      struct task_struct *p,
+				      struct user_namespace *user_ns)
+{
+	mm = mm_setup(mm);
+	if (!mm)
+		return NULL;
+
+	return mm_set_task(mm, p, user_ns);
+}
+
 static void check_mm(struct mm_struct *mm)
 {
 	int i;
@@ -822,10 +847,22 @@ static void check_mm(struct mm_struct *mm)
 #endif
 }
 
+struct mm_struct *mm_alloc(void)
+{
+	struct mm_struct *mm;
+
+	mm = allocate_mm();
+	if (!mm)
+		return NULL;
+
+	memset(mm, 0, sizeof(*mm));
+	return mm;
+}
+
 /*
  * Allocate and initialize an mm_struct.
  */
-struct mm_struct *mm_alloc(void)
+struct mm_struct *mm_alloc_and_setup(void)
 {
 	struct mm_struct *mm;
 
@@ -834,9 +871,10 @@ struct mm_struct *mm_alloc(void)
 		return NULL;
 
 	memset(mm, 0, sizeof(*mm));
-	return mm_init(mm, current, current_user_ns());
+	return mm_setup_all(mm, current, current_user_ns());
 }
 
+
 /*
  * Called when the last reference to the mm
  * is dropped: either by a lazy thread or by
@@ -1131,7 +1169,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 
 	memcpy(mm, oldmm, sizeof(*mm));
 
-	if (!mm_init(mm, tsk, mm->user_ns))
+	if (!mm_setup_all(mm, tsk, mm->user_ns))
 		goto fail_nomem;
 
 	err = dup_mmap(mm, oldmm);
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
