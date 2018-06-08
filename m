Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7A66B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 20:59:53 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g6-v6so6356558plq.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 17:59:53 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p14-v6si44867340pgc.216.2018.06.07.17.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 17:59:51 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 482862089E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 00:59:51 +0000 (UTC)
Received: by mail-wm0-f53.google.com with SMTP id v131-v6so473563wma.1
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 17:59:51 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143705.3531-1-yu-cheng.yu@intel.com> <20180607143705.3531-7-yu-cheng.yu@intel.com>
 <CALCETrVa8MtxP9iqYkZLnetaQiN4UaWb=jGz1+rLsCuETHKydg@mail.gmail.com> <5c39caf1-2198-3c2b-b590-8c38a525747f@linux.intel.com>
In-Reply-To: <5c39caf1-2198-3c2b-b590-8c38a525747f@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 17:59:37 -0700
Message-ID: <CALCETrU7uNpSp8DWKnpH28wHE3JOeXkmp-H97n2nWHJEu4pDEA@mail.gmail.com>
Subject: Re: [PATCH 6/9] x86/mm: Introduce ptep_set_wrprotect_flush and
 related functions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 1:30 PM Dave Hansen <dave.hansen@linux.intel.com> wrote:
>
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
>         CPU0 sees P=1,W=0,D=0
>         CPU0 sets back P=1,W=0,D=1
> CPU0 loads P=1,W=0,D=1 into the TLB
> CPU0 attempts to continue the write, but sees W=0 in the TLB and a #PF
> is generated because of the write fault.
>
> The problem with this is that we end up with a shadowstack-PTE
> (Write=0,Dirty=1) where we didn't want one.  This, unfortunately,
> imposes extra TLB flushing overhead on the R/W->R/O transitions that
> does not exist before shadowstack enabling.
>

So what exactly do the architects want the OS to do?  AFAICS the only
valid ways to clear the dirty bit are:

--- Choice 1 ---
a) Set P=0.
b) Flush using an IPI
c) Read D (so we know if the page was actually dirty)
d) Set P=1,W=0,D=0

and we need to handle spurious faults that happen between steps (a)
and (c).  This isn't so easy because the straightforward "is the fault
spurious" check is going to think it's *not* spurious.

--- Choice 2 ---
a) Set W=0
b) flush
c) Test and clear D

and we need to handle the spurious fault between b and c.  At least
this particular spurious fault is easier to handle since we can check
the error code.

But surely the right solution is to get the architecture team to see
if they can fix the dirty-bit-setting algorithm or, even better, to
look and see if the dirty-bit-setting algorithm is *already* better
and just document it.  If the cpu does a locked set-bit on D in your
example, the CPU is just being silly.  The CPU should make the whole
operation fully atomic: when trying to write to a page that's D=0 in
the TLB, it should re-walk the page tables and, atomically, load the
PTE and, if it's W=1,D=0, set D=1.  I'd honestly be a bit surprised if
modern CPUs don't already do this.

(Hmm.  If the CPUs were that smart, then we wouldn't need a flush at
all in some cases.  If we lock cmpxchg to change W=1,D=0 to W=0,D=0,
then we know that no other CPU can subsequently write the page without
re-walking, and we don't need to flush.)

Can you ask the architecture folks to clarify the situation?  And, if
your notes are indeed correct, don't we need code to handle spurious
faults?

--Andy
