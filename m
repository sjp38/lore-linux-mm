Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 105D86B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 16:16:34 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ao6so1934839pac.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 13:16:34 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id z8si21686958pff.143.2016.06.14.13.16.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 13:16:32 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id t190so56569pfb.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 13:16:32 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] Linux VM workaround for Knights Landing A/D leak
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <57603C61.5000408@linux.intel.com>
Date: Tue, 14 Jun 2016 13:16:29 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <2471A3E8-FF69-4720-A3BF-BDC6094A6A70@gmail.com>
References: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com> <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com> <57603C61.5000408@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com

Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 06/14/2016 09:47 AM, Nadav Amit wrote:
>> Lukasz Anaczkowski <lukasz.anaczkowski@intel.com> wrote:
>>=20
>>>> From: Andi Kleen <ak@linux.intel.com>
>>>> +void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t =
*ptep)
>>>> +{
>> Here there should be a call to smp_mb__after_atomic() to synchronize =
with
>> switch_mm. I submitted a similar patch, which is still pending =
(hint).
>>=20
>>>> +	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < =
nr_cpu_ids) {
>>>> +		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
>>>> +		flush_tlb_others(mm_cpumask(mm), mm, addr,
>>>> +				 addr + PAGE_SIZE);
>>>> +		mb();
>>>> +		set_pte(ptep, __pte(0));
>>>> +	}
>>>> +}
>=20
> Shouldn't that barrier be incorporated in the TLB flush code itself =
and
> not every single caller (like this code is)?
>=20
> It is insane to require individual TLB flushers to be concerned with =
the
> barriers.

IMHO it is best to use existing flushing interfaces instead of creating
new ones.=20

In theory, fix_pte_leak could have used flush_tlb_page. But the problem
is that flush_tlb_page requires the vm_area_struct as an argument, which
ptep_get_and_clear (and others) do not have.

I don=92t know which architecture needs the vm_area_struct, since x86 =
and
some others I looked at (e.g., ARM) only need the mm_struct.

Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
