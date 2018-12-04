Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A83FB6B6D3F
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 01:23:34 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t2so13220603pfj.15
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 22:23:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t2si15339359plz.344.2018.12.03.22.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 22:23:32 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB46JN5x104963
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 01:23:32 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p5k3rjdc3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:23:31 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 4 Dec 2018 06:23:29 -0000
Date: Mon, 3 Dec 2018 22:23:18 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20181108201231.GE5481@ram.oc3035372033.ibm.com>
 <87bm6z71yw.fsf@oldenburg.str.redhat.com>
 <20181109180947.GF5481@ram.oc3035372033.ibm.com>
 <87efbqqze4.fsf@oldenburg.str.redhat.com>
 <20181127102350.GA5795@ram.oc3035372033.ibm.com>
 <87zhtuhgx0.fsf@oldenburg.str.redhat.com>
 <58e263a6-9a93-46d6-c5f9-59973064d55e@intel.com>
 <87va4g5d3o.fsf@oldenburg.str.redhat.com>
 <20181203040249.GA11930@ram.oc3035372033.ibm.com>
 <87pnuibobh.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
In-Reply-To: <87pnuibobh.fsf@oldenburg.str.redhat.com>
Message-Id: <20181204062318.GC11930@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Mon, Dec 03, 2018 at 04:52:02PM +0100, Florian Weimer wrote:
> * Ram Pai:
> 
> > So the problem is as follows:
> >
> > Currently the kernel supports  'disable-write'  and 'disable-access'.
> >
> > On x86, cpu supports 'disable-write' and 'disable-access'. This
> > matches with what the kernel supports. All good.
> >
> > However on power, cpu supports 'disable-read' too. Since userspace can
> > program the cpu directly, userspace has the ability to set
> > 'disable-read' too.  This can lead to inconsistency between the kernel
> > and the userspace.
> >
> > We want the kernel to match userspace on all architectures.
> 
> Correct.
> 
> > Proposed Solution:
> >
> > Enhance the kernel to understand 'disable-read', and facilitate architectures
> > that understand 'disable-read' to allow it.
> >
> > Also explicitly define the semantics of disable-access  as 
> > 'disable-read and disable-write'
> >
> > Did I get this right?  Assuming I did, the implementation has to do
> > the following --
> >   
> > 	On power, sys_pkey_alloc() should succeed if the init_val
> > 	is PKEY_DISABLE_READ, PKEY_DISABLE_WRITE, PKEY_DISABLE_ACCESS
> > 	or any combination of the three.
> 
> Agreed.
> 
> > 	On x86, sys_pkey_alloc() should succeed if the init_val is
> > 	PKEY_DISABLE_WRITE or PKEY_DISABLE_ACCESS or PKEY_DISABLE_READ
> > 	or any combination of the three, except  PKEY_DISABLE_READ
> >       	specified all by itself.
> 
> Again agreed.  That's a clever way of phrasing it actually.
> 
> > 	On all other arches, none of the flags are supported.
> >
> >
> > Are we on the same plate?
> 
> I think so, thanks.
> 
> Florian

Ok. here is a patch, compiled but not tested. See if this meets the
specifications.

-----------------------------------------------------------------------------------

commit 3dc06e73f3795921265d5d1d935e428deab01616
Author: Ram Pai <linuxram@us.ibm.com>
Date:   Tue Dec 4 00:04:11 2018 -0500

    pkeys: add support of PKEY_DISABLE_READ
    
    Kernel supports  'disable-write'  and 'disable-access'.
    
    x86 cpu supports 'disable-write' and 'disable-access'. This
    matches with the kernel support.
    
    However POWER cpu supports 'disable-read' too. Since userspace can
    program the cpu directly, userspace has the ability to set
    'disable-read' too.  This can lead to inconsistency between the kernel
    and the userspace.
    
    Make kernel match userspace on all architectures.
    
    Enhance the kernel to understand 'disable-read', and facilitate architectures
    that understand 'disable-read' to allow it.
    
    Define the semantics of disable-access  as 'disable-read and disable-write'
    
    Signed-off-by: Ram Pai <linuxram@us.ibm.com>

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 20ebf15..4bd09d0 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -19,11 +19,7 @@
 #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | \
 			    VM_PKEY_BIT3 | VM_PKEY_BIT4)
 
-/* Override any generic PKEY permission defines */
 #define PKEY_DISABLE_EXECUTE   0x4
-#define PKEY_ACCESS_MASK       (PKEY_DISABLE_ACCESS | \
-				PKEY_DISABLE_WRITE  | \
-				PKEY_DISABLE_EXECUTE)
 
 static inline u64 pkey_to_vmflag_bits(u16 pkey)
 {
@@ -199,6 +195,16 @@ static inline bool arch_pkeys_enabled(void)
 	return !static_branch_likely(&pkey_disabled);
 }
 
+extern bool __arch_pkey_access_rights_valid(unsigned long rights);
+
+static inline bool arch_pkey_access_rights_valid(unsigned long rights)
+{
+	if (static_branch_likely(&pkey_disabled))
+		return false;
+
+	return __arch_pkey_access_rights_valid(rights);
+}
+
 extern void pkey_mm_init(struct mm_struct *mm);
 extern bool arch_supports_pkeys(int cap);
 extern unsigned int arch_usable_pkeys(void);
diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index 65065ce..e63bc37 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -30,10 +30,4 @@
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
 
-/* Override any generic PKEY permission defines */
-#define PKEY_DISABLE_EXECUTE   0x4
-#undef PKEY_ACCESS_MASK
-#define PKEY_ACCESS_MASK       (PKEY_DISABLE_ACCESS |\
-				PKEY_DISABLE_WRITE  |\
-				PKEY_DISABLE_EXECUTE)
 #endif /* _UAPI_ASM_POWERPC_MMAN_H */
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 5d65c47..a4f288b 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -67,7 +67,7 @@ int pkey_initialize(void)
 	 * Ensure that the bits a distinct.
 	 */
 	BUILD_BUG_ON(PKEY_DISABLE_EXECUTE &
-		     (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
+		(PKEY_DISABLE_READ | PKEY_DISABLE_WRITE | PKEY_DISABLE_ACCESS));
 
 	/*
 	 * pkey_to_vmflag_bits() assumes that the pkey bits are contiguous
@@ -259,11 +259,20 @@ int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		new_amr_bits |= AMR_RD_BIT | AMR_WR_BIT;
 	else if (init_val & PKEY_DISABLE_WRITE)
 		new_amr_bits |= AMR_WR_BIT;
+	else if (init_val & PKEY_DISABLE_READ)
+		new_amr_bits |= AMR_RD_BIT;
 
 	init_amr(pkey, new_amr_bits);
 	return 0;
 }
 
+bool __arch_pkey_access_rights_valid(unsigned long rights)
+{
+	unsigned long mask = PKEY_DISABLE_READ | PKEY_DISABLE_WRITE |\
+			     PKEY_DISABLE_ACCESS;
+	return (rights & mask);
+}
+
 void thread_pkey_regs_save(struct thread_struct *thread)
 {
 	if (static_branch_likely(&pkey_disabled))
diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
index 19b137f..4f36a7e 100644
--- a/arch/x86/include/asm/pkeys.h
+++ b/arch/x86/include/asm/pkeys.h
@@ -14,6 +14,15 @@ static inline bool arch_pkeys_enabled(void)
 	return boot_cpu_has(X86_FEATURE_OSPKE);
 }
 
+extern bool __arch_pkey_access_rights_valid(unsigned long rights);
+static inline bool arch_pkey_access_rights_valid(unsigned long rights)
+{
+	if (!boot_cpu_has(X86_FEATURE_OSPKE))
+		return false;
+
+	return __arch_pkey_access_rights_valid(rights);
+}
+
 /*
  * Try to dedicate one of the protection keys to be used as an
  * execute-only protection key.
diff --git a/arch/x86/mm/pkeys.c b/arch/x86/mm/pkeys.c
index 6e98e0a..fcfe1b2 100644
--- a/arch/x86/mm/pkeys.c
+++ b/arch/x86/mm/pkeys.c
@@ -72,6 +72,17 @@ int __execute_only_pkey(struct mm_struct *mm)
 	return execute_only_pkey;
 }
 
+bool __arch_pkey_access_rights_valid(unsigned long rights)
+{
+	unsigned long mask = PKEY_DISABLE_READ | PKEY_DISABLE_WRITE |\
+				PKEY_DISABLE_ACCESS;
+	if (!(rights & mask))
+		return false;
+
+	/* return failure if only PKEY_DISABLE_READ is specified */
+	return ((rights & mask) != PKEY_DISABLE_READ);
+}
+
 static inline bool vma_is_pkey_exec_only(struct vm_area_struct *vma)
 {
 	/* Do this check first since the vm_flags should be hot */
diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
index 2955ba97..2c330fa 100644
--- a/include/linux/pkeys.h
+++ b/include/linux/pkeys.h
@@ -48,6 +48,11 @@ static inline void copy_init_pkru_to_fpregs(void)
 {
 }
 
+static inline bool arch_pkey_access_rights_valid(unsigned long rights)
+{
+	return false;
+}
+
 #endif /* ! CONFIG_ARCH_HAS_PKEYS */
 
 #endif /* _LINUX_PKEYS_H */
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index e7ee328..d2e1a5e 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -71,7 +71,5 @@
 
 #define PKEY_DISABLE_ACCESS	0x1
 #define PKEY_DISABLE_WRITE	0x2
-#define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
-				 PKEY_DISABLE_WRITE)
-
+#define PKEY_DISABLE_READ	0x10
 #endif /* __ASM_GENERIC_MMAN_COMMON_H */
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 6d33162..f4cefc3 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -597,7 +597,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 	if (flags)
 		return -EINVAL;
 	/* check for unsupported init values */
-	if (init_val & ~PKEY_ACCESS_MASK)
+	if (!arch_pkey_access_rights_valid(init_val))
 		return -EINVAL;
 
 	down_write(&current->mm->mmap_sem);

-----------------------------------------------------------------------------
