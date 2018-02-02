Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 992326B0003
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 02:21:58 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id b185so15144996qkc.7
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 23:21:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n6si1549195qtk.199.2018.02.01.23.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 23:21:57 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w127IcdL034696
	for <linux-mm@kvack.org>; Fri, 2 Feb 2018 02:21:56 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fvhbhcvn6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Feb 2018 02:21:55 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Fri, 2 Feb 2018 07:21:53 -0000
Date: Thu, 1 Feb 2018 23:21:39 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v11 3/3] mm, x86: display pkey in smaps only if arch
 supports pkeys
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1517341452-11924-4-git-send-email-linuxram@us.ibm.com>
 <201802021225.JPjLbdCs%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201802021225.JPjLbdCs%fengguang.wu@intel.com>
Message-Id: <20180202072139.GD5411@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

On Fri, Feb 02, 2018 at 12:27:27PM +0800, kbuild test robot wrote:
> Hi Ram,
> 
> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.15 next-20180201]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://urldefense.proofpoint.com/v2/url?u=https-3A__github.com_0day-2Dci_linux_commits_Ram-2DPai_mm-2Dx86-2Dpowerpc-2DEnhancements-2Dto-2DMemory-2DProtection-2DKeys_20180202-2D120004&d=DwIBAg&c=jf_iaSHvJObTbx-siA1ZOg&r=m-UrKChQVkZtnPpjbF6YY99NbT8FBByQ-E-ygV8luxw&m=Fv3tEHet1bTUrDjOnzEhXvGM_4tGlkYhJHPBnWNWgVA&s=Z1W6CV2tfPmLYU8lVv1oDRl2cAyQA76KE2P064A2CQY&e=
> config: x86_64-randconfig-x005-201804 (attached as .config)
> compiler: gcc-7 (Debian 7.2.0-12) 7.2.1 20171025
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from arch/x86/include/asm/mmu_context.h:8:0,
>                     from arch/x86/events/core.c:36:
> >> include/linux/pkeys.h:16:23: error: expected identifier or '(' before numeric constant
>     #define vma_pkey(vma) 0
>                           ^
> >> arch/x86/include/asm/mmu_context.h:298:19: note: in expansion of macro 'vma_pkey'
>     static inline int vma_pkey(struct vm_area_struct *vma)
>                       ^~~~~~~~
> 
> vim +16 include/linux/pkeys.h
> 
>      7	
>      8	#ifdef CONFIG_ARCH_HAS_PKEYS
>      9	#include <asm/pkeys.h>
>     10	#else /* ! CONFIG_ARCH_HAS_PKEYS */
>     11	#define arch_max_pkey() (1)
>     12	#define execute_only_pkey(mm) (0)
>     13	#define arch_override_mprotect_pkey(vma, prot, pkey) (0)
>     14	#define PKEY_DEDICATED_EXECUTE_ONLY 0
>     15	#define ARCH_VM_PKEY_FLAGS 0
>   > 16	#define vma_pkey(vma) 0

Oops. Thanks for catching the issue. The following fix will resolve the error.

diff --git a/arch/x86/include/asm/mmu_context.h
b/arch/x86/include/asm/mmu_context.h
index 6d16d15..c1aeb19 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -238,11 +238,6 @@ static inline int vma_pkey(struct vm_area_struct
		*vma)
 
        return (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
}
-#else
-static inline int vma_pkey(struct vm_area_struct *vma)
-{
-       return 0;
-}
 #endif

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
