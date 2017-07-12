Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 42EE7440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 18:23:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e3so36767963pfc.4
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 15:23:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l5si2792947pgu.532.2017.07.12.15.23.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 15:23:47 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6CMNks0068497
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 18:23:46 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bnt3wn0ac-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 18:23:46 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Wed, 12 Jul 2017 18:23:41 -0400
Date: Wed, 12 Jul 2017 15:23:31 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v5 11/38] mm: introduce an additional vma bit for powerpc
 pkey
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-12-git-send-email-linuxram@us.ibm.com>
 <290636b0-aafd-9bcd-d309-4cff41ce923c@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <290636b0-aafd-9bcd-d309-4cff41ce923c@intel.com>
Message-Id: <20170712222331.GD5525@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Tue, Jul 11, 2017 at 11:10:46AM -0700, Dave Hansen wrote:
> On 07/05/2017 02:21 PM, Ram Pai wrote:
> > Currently there are only 4bits in the vma flags to support 16 keys
> > on x86.  powerpc supports 32 keys, which needs 5bits. This patch
> > introduces an addition bit in the vma flags.
> > 
> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> > ---
> >  fs/proc/task_mmu.c |    6 +++++-
> >  include/linux/mm.h |   18 +++++++++++++-----
> >  2 files changed, 18 insertions(+), 6 deletions(-)
> > 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index f0c8b33..2ddc298 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -666,12 +666,16 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
> >  		[ilog2(VM_MERGEABLE)]	= "mg",
> >  		[ilog2(VM_UFFD_MISSING)]= "um",
> >  		[ilog2(VM_UFFD_WP)]	= "uw",
> > -#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> > +#ifdef CONFIG_ARCH_HAS_PKEYS
> >  		/* These come out via ProtectionKey: */
> >  		[ilog2(VM_PKEY_BIT0)]	= "",
> >  		[ilog2(VM_PKEY_BIT1)]	= "",
> >  		[ilog2(VM_PKEY_BIT2)]	= "",
> >  		[ilog2(VM_PKEY_BIT3)]	= "",
> > +#endif /* CONFIG_ARCH_HAS_PKEYS */
> > +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> > +		/* Additional bit in ProtectionKey: */
> > +		[ilog2(VM_PKEY_BIT4)]	= "",
> >  #endif
> 
> I'd probably just leave the #ifdef out and eat the byte or whatever of
> storage that this costs us on x86.

fine with me.

> 
> >  	};
> >  	size_t i;
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 7cb17c6..3d35bcc 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -208,21 +208,29 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
> >  #define VM_HIGH_ARCH_BIT_1	33	/* bit only usable on 64-bit architectures */
> >  #define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit architectures */
> >  #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
> > +#define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit arch */
> 
> Please just copy the above lines.

Just copying over makes checkpatch.pl unhappy. It exceeds 80 columns.

> 
> >  #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
> >  #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
> >  #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
> >  #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
> > +#define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
> >  #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
> >  
> > -#if defined(CONFIG_X86)
> > -# define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
> > -#if defined (CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS)
> > +#ifdef CONFIG_ARCH_HAS_PKEYS
> >  # define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
> > -# define VM_PKEY_BIT0	VM_HIGH_ARCH_0	/* A protection key is a 4-bit value */
> > +# define VM_PKEY_BIT0	VM_HIGH_ARCH_0
> >  # define VM_PKEY_BIT1	VM_HIGH_ARCH_1
> >  # define VM_PKEY_BIT2	VM_HIGH_ARCH_2
> >  # define VM_PKEY_BIT3	VM_HIGH_ARCH_3
> > -#endif
> > +#endif /* CONFIG_ARCH_HAS_PKEYS */
> 
> We have the space here, so can we just say that it's 4-bits on x86 and 5
> on ppc?

sure.

> 
> > +#if defined(CONFIG_PPC64_MEMORY_PROTECTION_KEYS)
> > +# define VM_PKEY_BIT4	VM_HIGH_ARCH_4 /* additional key bit used on ppc64 */
> > +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> 
> Why bother #ifdef'ing a #define?

ok. 

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
