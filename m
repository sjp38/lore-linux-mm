Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45D846B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:39:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j25-v6so3920052pfi.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:39:14 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q4-v6si53514170plb.312.2018.06.07.13.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 13:39:13 -0700 (PDT)
Message-ID: <1528403761.5265.37.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 6/9] x86/mm: Introduce ptep_set_wrprotect_flush and
 related functions
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 13:36:01 -0700
In-Reply-To: <5c39caf1-2198-3c2b-b590-8c38a525747f@linux.intel.com>
References: <20180607143705.3531-1-yu-cheng.yu@intel.com>
	 <20180607143705.3531-7-yu-cheng.yu@intel.com>
	 <CALCETrVa8MtxP9iqYkZLnetaQiN4UaWb=jGz1+rLsCuETHKydg@mail.gmail.com>
	 <5c39caf1-2198-3c2b-b590-8c38a525747f@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, 2018-06-07 at 13:29 -0700, Dave Hansen wrote:
> On 06/07/2018 09:24 AM, Andy Lutomirski wrote:
> 
> >> +static inline void ptep_set_wrprotect_flush(struct vm_area_struct *vma,
> >> +                                           unsigned long addr, pte_t *ptep)
> >> +{
> >> +       bool rw;
> >> +
> >> +       rw = test_and_clear_bit(_PAGE_BIT_RW, (unsigned long *)&ptep->pte);
> >> +       if (IS_ENABLED(CONFIG_X86_INTEL_SHADOW_STACK_USER)) {
> >> +               struct mm_struct *mm = vma->vm_mm;
> >> +               pte_t pte;
> >> +
> >> +               if (rw && (atomic_read(&mm->mm_users) > 1))
> >> +                       pte = ptep_clear_flush(vma, addr, ptep);
> > Why are you clearing the pte?
> 
> I found my notes on the subject. :)
> 
> Here's the sequence that causes the problem.  This could happen any time
> we try to take a PTE from read-write to read-only.  P==Present, W=Write,
> D=Dirty:
> 
> CPU0 does a write, sees PTE with P=1,W=1,D=0
> CPU0 decides to set D=1
> CPU1 comes in and sets W=0
> CPU0 does locked operation to set D=1
> 	CPU0 sees P=1,W=0,D=0
> 	CPU0 sets back P=1,W=0,D=1
> CPU0 loads P=1,W=0,D=1 into the TLB
> CPU0 attempts to continue the write, but sees W=0 in the TLB and a #PF
> is generated because of the write fault.
> 
> The problem with this is that we end up with a shadowstack-PTE
> (Write=0,Dirty=1) where we didn't want one.  This, unfortunately,
> imposes extra TLB flushing overhead on the R/W->R/O transitions that
> does not exist before shadowstack enabling.
> 
> Yu-cheng, could you please add this to the patch description?

I will add that.
