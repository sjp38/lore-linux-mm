Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id EDB5E6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 13:18:33 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e5so1212113ith.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 10:18:33 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id c2si19195488pfb.198.2016.06.14.10.18.33
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 10:18:33 -0700 (PDT)
Subject: Re: [PATCH] Linux VM workaround for Knights Landing A/D leak
References: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com>
 <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57603C61.5000408@linux.intel.com>
Date: Tue, 14 Jun 2016 10:18:25 -0700
MIME-Version: 1.0
In-Reply-To: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>, Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com

On 06/14/2016 09:47 AM, Nadav Amit wrote:
> Lukasz Anaczkowski <lukasz.anaczkowski@intel.com> wrote:
> 
>> > From: Andi Kleen <ak@linux.intel.com>
>> > +void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
>> > +{
> Here there should be a call to smp_mb__after_atomic() to synchronize with
> switch_mm. I submitted a similar patch, which is still pending (hint).
> 
>> > +	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids) {
>> > +		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
>> > +		flush_tlb_others(mm_cpumask(mm), mm, addr,
>> > +				 addr + PAGE_SIZE);
>> > +		mb();
>> > +		set_pte(ptep, __pte(0));
>> > +	}
>> > +}

Shouldn't that barrier be incorporated in the TLB flush code itself and
not every single caller (like this code is)?

It is insane to require individual TLB flushers to be concerned with the
barriers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
