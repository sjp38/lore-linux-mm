Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E63E46B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 14:38:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so302253271pfa.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 11:38:10 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id p184si39861707pfb.252.2016.06.14.11.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 11:38:10 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id 62so13397338pfd.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 11:38:10 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
Date: Tue, 14 Jun 2016 11:38:07 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <76F6D5F2-6723-441B-BD63-52628731F1FF@gmail.com>
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com> <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com

Lukasz Anaczkowski <lukasz.anaczkowski@intel.com> wrote:

> From: Andi Kleen <ak@linux.intel.com>

> static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
> 					    unsigned long addr, pte_t *ptep)
> {
> -	return ptep_get_and_clear(mm, addr, ptep);
> +	pte_t pte = ptep_get_and_clear(mm, addr, ptep);
> +
> +	if (boot_cpu_has_bug(X86_BUG_PTE_LEAK))
> +		fix_pte_leak(mm, addr, ptep);
> +	return pte;
> }

I missed it on the previous iteration: ptep_get_and_clear already calls 
fix_pte_leak when needed. So do you need to call it again here?

Thanks,
Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
