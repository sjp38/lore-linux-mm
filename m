Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 70B566B007E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 12:43:06 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fg1so90756388pad.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:43:06 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id w6si11190203pac.26.2016.06.16.09.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 09:43:03 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id c74so4380155pfb.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:43:02 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3] Linux VM workaround for Knights Landing A/D leak
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <1466090042-30908-1-git-send-email-lukasz.anaczkowski@intel.com>
Date: Thu, 16 Jun 2016 09:43:01 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <6128C99E-3FAA-4925-B68C-16B36178E00B@gmail.com>
References: <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com> <1466090042-30908-1-git-send-email-lukasz.anaczkowski@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com


Lukasz Anaczkowski <lukasz.anaczkowski@intel.com> wrote:

> From: Andi Kleen <ak@linux.intel.com>
>=20
> +void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t =
*ptep)
> +{
> +	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < =
nr_cpu_ids) {
> +		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
This tracing seems incorrect since you don=E2=80=99t perform a local =
flush.
I don=E2=80=99t think you need any tracing - native_flush_tlb_others =
will do it for you.

> +		flush_tlb_others(mm_cpumask(mm), mm, addr,
> +				 addr + PAGE_SIZE);
> +		mb();
Why do you need the memory barrier?

Regards,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
