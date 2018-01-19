Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3AEC6B0253
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 11:51:16 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id o22so3297468qtb.17
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 08:51:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 50si1022537qts.167.2018.01.19.08.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 08:51:15 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0JGmbV7132856
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 11:51:14 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fkk0jv7s8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 11:51:14 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Fri, 19 Jan 2018 16:51:11 -0000
Date: Fri, 19 Jan 2018 08:50:50 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v10 27/27] mm: display pkey in smaps if
 arch_pkeys_enabled() is true
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
 <1516326648-22775-28-git-send-email-linuxram@us.ibm.com>
 <87shb1de4a.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87shb1de4a.fsf@xmission.com>
Message-Id: <20180119165050.GK5612@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com

On Fri, Jan 19, 2018 at 10:09:41AM -0600, Eric W. Biederman wrote:
> Ram Pai <linuxram@us.ibm.com> writes:
> 
> > Currently the  architecture  specific code is expected to
> > display  the  protection  keys  in  smap  for a given vma.
> > This can lead to redundant code and possibly to divergent
> > formats in which the key gets displayed.
> >
> > This  patch  changes  the implementation. It displays the
> > pkey only if the architecture support pkeys.
> >
> > x86 arch_show_smap() function is not needed anymore.
> > Delete it.
> >
> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> > ---
> >  arch/x86/kernel/setup.c |    8 --------
> >  fs/proc/task_mmu.c      |   11 ++++++-----
> >  2 files changed, 6 insertions(+), 13 deletions(-)
> >
> > diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> > index 8af2e8d..ddf945a 100644
> > --- a/arch/x86/kernel/setup.c
> > +++ b/arch/x86/kernel/setup.c
> > @@ -1326,11 +1326,3 @@ static int __init register_kernel_offset_dumper(void)
> >  	return 0;
> >  }
> >  __initcall(register_kernel_offset_dumper);
> > -
> > -void arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> > -{
> > -	if (!boot_cpu_has(X86_FEATURE_OSPKE))
> > -		return;
> > -
> > -	seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> > -}
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 0edd4da..4b39a94 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -18,6 +18,7 @@
> >  #include <linux/page_idle.h>
> >  #include <linux/shmem_fs.h>
> >  #include <linux/uaccess.h>
> > +#include <linux/pkeys.h>
> >  
> >  #include <asm/elf.h>
> >  #include <asm/tlb.h>
> > @@ -728,10 +729,6 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
> >  }
> >  #endif /* HUGETLB_PAGE */
> >  
> > -void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> > -{
> > -}
> > -
> >  static int show_smap(struct seq_file *m, void *v, int is_pid)
> >  {
> >  	struct proc_maps_private *priv = m->private;
> > @@ -851,9 +848,13 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
> >  			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
> >  
> >  	if (!rollup_mode) {
> > -		arch_show_smap(m, vma);
> > +#ifdef CONFIG_ARCH_HAS_PKEYS
> > +		if (arch_pkeys_enabled())
> > +			seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> > +#endif
> 
> Would it be worth it making vma_pkey a noop on architectures that don't
> support protection keys so that we don't need the #ifdef here?

You mean something like this?
	#define vma_pkey(vma)  
It will lead to compilation error.


I can make it
	#define vma_pkey(vma)  0

and that will work and get rid of the #ifdef

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
