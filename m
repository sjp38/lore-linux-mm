Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B47B6B02F3
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:49:15 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p64so21635803wrc.8
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 22:49:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d11si5697836wmi.97.2017.07.09.22.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jul 2017 22:49:14 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6A5mVHe082228
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:49:12 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bjuhhqpb0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:49:12 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sun, 9 Jul 2017 23:49:12 -0600
Date: Sun, 9 Jul 2017 22:49:00 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v5 32/38] powerpc: capture the violated protection key on
 fault
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-33-git-send-email-linuxram@us.ibm.com>
 <5fa43f48-d3b3-89f2-0bbd-58be3e07f4b8@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5fa43f48-d3b3-89f2-0bbd-58be3e07f4b8@linux.vnet.ibm.com>
Message-Id: <20170710054900.GB5713@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Mon, Jul 10, 2017 at 08:40:19AM +0530, Anshuman Khandual wrote:
> On 07/06/2017 02:52 AM, Ram Pai wrote:
> > Capture the protection key that got violated in paca.
> > This value will be used by used to inform the signal
> > handler.
> > 
> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> > ---
> >  arch/powerpc/include/asm/paca.h   |    1 +
> >  arch/powerpc/kernel/asm-offsets.c |    1 +
> >  arch/powerpc/mm/fault.c           |    3 +++
> >  3 files changed, 5 insertions(+), 0 deletions(-)
> > 
> > diff --git a/arch/powerpc/include/asm/paca.h b/arch/powerpc/include/asm/paca.h
> > index c8bd1fc..0c06188 100644
> > --- a/arch/powerpc/include/asm/paca.h
> > +++ b/arch/powerpc/include/asm/paca.h
> > @@ -94,6 +94,7 @@ struct paca_struct {
> >  	u64 dscr_default;		/* per-CPU default DSCR */
> >  #ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> >  	u64 paca_amr;			/* value of amr at exception */
> > +	u16 paca_pkey;                  /* exception causing pkey */
> >  #endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> >  
> >  #ifdef CONFIG_PPC_STD_MMU_64
> > diff --git a/arch/powerpc/kernel/asm-offsets.c b/arch/powerpc/kernel/asm-offsets.c
> > index 17f5d8a..7dff862 100644
> > --- a/arch/powerpc/kernel/asm-offsets.c
> > +++ b/arch/powerpc/kernel/asm-offsets.c
> > @@ -244,6 +244,7 @@ int main(void)
> >  
> >  #ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> >  	OFFSET(PACA_AMR, paca_struct, paca_amr);
> > +	OFFSET(PACA_PKEY, paca_struct, paca_pkey);
> >  #endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> >  
> >  	OFFSET(ACCOUNT_STARTTIME, paca_struct, accounting.starttime);
> > diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
> > index a6710f5..c8674a7 100644
> > --- a/arch/powerpc/mm/fault.c
> > +++ b/arch/powerpc/mm/fault.c
> > @@ -265,6 +265,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
> >  	if (error_code & DSISR_KEYFAULT) {
> >  		code = SEGV_PKUERR;
> >  		get_paca()->paca_amr = read_amr();
> > +		get_paca()->paca_pkey = get_pte_pkey(current->mm, address);
> >  		goto bad_area_nosemaphore;
> >  	}
> >  #endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> > @@ -290,6 +291,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
> >  
> >  	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
> >  
> > +
> 
> Stray empty line addition here.
> 
> >  	/*
> >  	 * We want to do this outside mmap_sem, because reading code around nip
> >  	 * can result in fault, which will cause a deadlock when called with
> > @@ -453,6 +455,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
> >  	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
> >  			is_exec, 0)) {
> >  		get_paca()->paca_amr = read_amr();
> > +		get_paca()->paca_pkey = vma_pkey(vma);
> 
> Why not get_pte_pkey() here as well ? IIUC both these function would
> give us the same pkey, then why is the difference when we process a
> page fault for real protection key violation in HW compared to cross
> checking of VMA protection key in SW for regular page faults.

Unfortunately if we have reached here, it means the pgd-pmd-pdt-...pte
structures have not yet been totally populated for the task. Hence we
cannot walk the tree, to find the pte, to find the key. hence we have to 
depend on vma_pkey() to get the key from the vma.

RP




-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
