Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DCC16B0253
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 12:05:04 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e26so2240770pgv.16
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 09:05:04 -0800 (PST)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id h7si727009pgv.172.2018.01.19.09.05.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 09:05:02 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
	<1516326648-22775-28-git-send-email-linuxram@us.ibm.com>
	<87shb1de4a.fsf@xmission.com>
	<20180119165050.GK5612@ram.oc3035372033.ibm.com>
Date: Fri, 19 Jan 2018 11:04:02 -0600
In-Reply-To: <20180119165050.GK5612@ram.oc3035372033.ibm.com> (Ram Pai's
	message of "Fri, 19 Jan 2018 08:50:50 -0800")
Message-ID: <87efmldblp.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v10 27/27] mm: display pkey in smaps if arch_pkeys_enabled() is true
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com

Ram Pai <linuxram@us.ibm.com> writes:

> On Fri, Jan 19, 2018 at 10:09:41AM -0600, Eric W. Biederman wrote:
>> Ram Pai <linuxram@us.ibm.com> writes:
>> 
>> > Currently the  architecture  specific code is expected to
>> > display  the  protection  keys  in  smap  for a given vma.
>> > This can lead to redundant code and possibly to divergent
>> > formats in which the key gets displayed.
>> >
>> > This  patch  changes  the implementation. It displays the
>> > pkey only if the architecture support pkeys.
>> >
>> > x86 arch_show_smap() function is not needed anymore.
>> > Delete it.
>> >
>> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
>> > ---
>> >  arch/x86/kernel/setup.c |    8 --------
>> >  fs/proc/task_mmu.c      |   11 ++++++-----
>> >  2 files changed, 6 insertions(+), 13 deletions(-)
>> >
>> > diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
>> > index 8af2e8d..ddf945a 100644
>> > --- a/arch/x86/kernel/setup.c
>> > +++ b/arch/x86/kernel/setup.c
>> > @@ -1326,11 +1326,3 @@ static int __init register_kernel_offset_dumper(void)
>> >  	return 0;
>> >  }
>> >  __initcall(register_kernel_offset_dumper);
>> > -
>> > -void arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
>> > -{
>> > -	if (!boot_cpu_has(X86_FEATURE_OSPKE))
>> > -		return;
>> > -
>> > -	seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
>> > -}
>> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> > index 0edd4da..4b39a94 100644
>> > --- a/fs/proc/task_mmu.c
>> > +++ b/fs/proc/task_mmu.c
>> > @@ -18,6 +18,7 @@
>> >  #include <linux/page_idle.h>
>> >  #include <linux/shmem_fs.h>
>> >  #include <linux/uaccess.h>
>> > +#include <linux/pkeys.h>
>> >  
>> >  #include <asm/elf.h>
>> >  #include <asm/tlb.h>
>> > @@ -728,10 +729,6 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
>> >  }
>> >  #endif /* HUGETLB_PAGE */
>> >  
>> > -void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
>> > -{
>> > -}
>> > -
>> >  static int show_smap(struct seq_file *m, void *v, int is_pid)
>> >  {
>> >  	struct proc_maps_private *priv = m->private;
>> > @@ -851,9 +848,13 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>> >  			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
>> >  
>> >  	if (!rollup_mode) {
>> > -		arch_show_smap(m, vma);
>> > +#ifdef CONFIG_ARCH_HAS_PKEYS
>> > +		if (arch_pkeys_enabled())
>> > +			seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
>> > +#endif
>> 
>> Would it be worth it making vma_pkey a noop on architectures that don't
>> support protection keys so that we don't need the #ifdef here?
>
> You mean something like this?
> 	#define vma_pkey(vma)  
> It will lead to compilation error.
>
>
> I can make it
> 	#define vma_pkey(vma)  0
>
> and that will work and get rid of the #ifdef

Yes the second is what I was thinking.

I don't know if it is worth it but #ifdefs can be problematic as the
result in code not being compile tested.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
