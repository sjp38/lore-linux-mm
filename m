Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8846B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 14:23:19 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o7-v6so3520444pgc.23
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 11:23:19 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 99-v6si54025867plc.362.2018.06.07.11.23.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 11:23:18 -0700 (PDT)
Subject: Re: [PATCH 6/9] x86/mm: Introduce ptep_set_wrprotect_flush and
 related functions
References: <20180607143705.3531-1-yu-cheng.yu@intel.com>
 <20180607143705.3531-7-yu-cheng.yu@intel.com>
 <CALCETrVa8MtxP9iqYkZLnetaQiN4UaWb=jGz1+rLsCuETHKydg@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <d9939c23-bb8b-1fbc-ac65-8bf1d7cbf650@linux.intel.com>
Date: Thu, 7 Jun 2018 11:21:56 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrVa8MtxP9iqYkZLnetaQiN4UaWb=jGz1+rLsCuETHKydg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On 06/07/2018 09:24 AM, Andy Lutomirski wrote:
>> +static inline void ptep_set_wrprotect_flush(struct vm_area_struct *vma,
>> +                                           unsigned long addr, pte_t *ptep)
>> +{
>> +       bool rw;
>> +
>> +       rw = test_and_clear_bit(_PAGE_BIT_RW, (unsigned long *)&ptep->pte);
>> +       if (IS_ENABLED(CONFIG_X86_INTEL_SHADOW_STACK_USER)) {
>> +               struct mm_struct *mm = vma->vm_mm;
>> +               pte_t pte;
>> +
>> +               if (rw && (atomic_read(&mm->mm_users) > 1))
>> +                       pte = ptep_clear_flush(vma, addr, ptep);
> Why are you clearing the pte?

I think I insisted on this being in there.

First of all, we need to flush the TLB eventually because we need the
shadowstack PTE permissions to be in effect.

But, generally, we can't clear a dirty bit in a "live" PTE without
flushing.  The processor can keep writing until we flush, and even keep
setting it whenever _it_ allows a write, which it can do based on stale
TLB contents.  Practically, I think a walk to set the dirty bit is
mostly the same as a TLB miss, but that's certainly not guaranteed forever.

That's even ignoring all the fun errata we have.
