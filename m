Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B70156B000A
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 17:54:18 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i81-v6so13326608pfj.1
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:54:18 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 138-v6si2307645pgc.218.2018.10.12.14.54.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 14:54:17 -0700 (PDT)
Message-ID: <1d293d2fb0df99fdb0048825b4e39640840bfabb.camel@intel.com>
Subject: Re: [PATCH v5 07/27] mm/mmap: Create a guard area between VMAs
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 12 Oct 2018 14:49:28 -0700
In-Reply-To: <CALCETrUJ1t_K=FQExa_K0yg+aXkPot6wn6RHBPDc3BsAxtmMBw@mail.gmail.com>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
	 <20181011151523.27101-8-yu-cheng.yu@intel.com>
	 <CAG48ez3R7XL8MX_sjff1FFYuARX_58wA_=ACbv2im-XJKR8tvA@mail.gmail.com>
	 <CALCETrUJ1t_K=FQExa_K0yg+aXkPot6wn6RHBPDc3BsAxtmMBw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Jann Horn <jannh@google.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, Daniel Micay <danielmicay@gmail.com>

On Thu, 2018-10-11 at 13:55 -0700, Andy Lutomirski wrote:
> On Thu, Oct 11, 2018 at 1:39 PM Jann Horn <jannh@google.com> wrote:
> > 
> > On Thu, Oct 11, 2018 at 5:20 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > > Create a guard area between VMAs to detect memory corruption.
> > 
> > [...]
> > > +config VM_AREA_GUARD
> > > +       bool "VM area guard"
> > > +       default n
> > > +       help
> > > +         Create a guard area between VM areas so that access beyond
> > > +         limit can be detected.
> > > +
> > >  endmenu
> > 
> > Sorry to bring this up so late, but Daniel Micay pointed out to me
> > that, given that VMA guards will raise the number of VMAs by
> > inhibiting vma_merge(), people are more likely to run into
> > /proc/sys/vm/max_map_count (which limits the number of VMAs to ~65k by
> > default, and can't easily be raised without risking an overflow of
> > page->_mapcount on systems with over ~800GiB of RAM, see
> > https://lore.kernel.org/lkml/20180208021112.GB14918@bombadil.infradead.org/
> > and replies) with this change.
> > 
> > Playing with glibc's memory allocator, it looks like glibc will use
> > mmap() for 128KB allocations; so at 65530*128KB=8GB of memory usage in
> > 128KB chunks, an application could run out of VMAs.
> 
> Ugh.
> 
> Do we have a free VM flag so we could do VM_GUARD to force a guard
> page?  (And to make sure that, when a new VMA is allocated, it won't
> be directly adjacent to a VM_GUARD VMA.)

Maybe something like the following?  These vm_start_gap()/vm_end_gap() are used
in many architectures.  Do we want to put them in a different series?  Comments?

Yu-cheng




diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0416a7204be3..92b580542411 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -224,11 +224,13 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit
architectures */
 #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit
architectures */
 #define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit
architectures */
+#define VM_HIGH_ARCH_BIT_5	37	/* bit only usable on 64-bit
architectures */
 #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
 #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
+#define VM_HIGH_ARCH_5	BIT(VM_HIGH_ARCH_BIT_5)
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -266,6 +268,12 @@ extern unsigned int kobjsize(const void *objp);
 # define VM_MPX		VM_NONE
 #endif
 
+#ifdef CONFIG_ARCH_USES_HIGH_VMA_FLAGS
+#define VM_GUARD	VM_HIGH_ARCH_5
+#else
+#define VM_GUARD	VM_NONE
+#endif
+
 #ifndef VM_GROWSUP
 # define VM_GROWSUP	VM_NONE
 #endif
@@ -2417,24 +2425,34 @@ static inline struct vm_area_struct *
find_vma_intersection(struct mm_struct * m
-static inline unsigned long vm_start_gap(struct vm_area_struct *vma)
+static inline unsigned long vm_start_gap(struct vm_area_struct *vma, vm_flags_t
flags)
 {
 	unsigned long vm_start = vma->vm_start;
+	unsigned long gap = 0;
+
+	if (vma->vm_flags & VM_GROWSDOWN)
+		gap = stack_guard_gap;
+	else if ((vma->vm_flags & VM_GUARD) || (flags & VM_GUARD))
+		gap = PAGE_SIZE;
+
+	vm_start -= gap;
+	if (vm_start > vma->vm_start)
+		vm_start = 0;
 
-	if (vma->vm_flags & VM_GROWSDOWN) {
-		vm_start -= stack_guard_gap;
-		if (vm_start > vma->vm_start)
-			vm_start = 0;
-	}
 	return vm_start;
 }
 
-static inline unsigned long vm_end_gap(struct vm_area_struct *vma)
+static inline unsigned long vm_end_gap(struct vm_area_struct *vma, vm_flags_t
flags)
 {
 	unsigned long vm_end = vma->vm_end;
+	unsigned long gap = 0;
+
+	if (vma->vm_flags & VM_GROWSUP)
+		gap = stack_guard_gap;
+	else if ((vma->vm_flags & VM_GUARD) || (flags & VM_GUARD))
+		gap = PAGE_SIZE;
+
+	vm_end += gap;
+	if (vm_end < vma->vm_end)
+		vm_end = -PAGE_SIZE;
 
-	if (vma->vm_flags & VM_GROWSUP) {
-		vm_end += stack_guard_gap;
-		if (vm_end < vma->vm_end)
-			vm_end = -PAGE_SIZE;
-	}
 	return vm_end;
 }
