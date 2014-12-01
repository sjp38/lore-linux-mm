Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8006B006E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 18:48:17 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id r2so15414908igi.3
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 15:48:16 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id cy14si13477200igc.10.2014.12.01.15.48.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 01 Dec 2014 15:48:14 -0800 (PST)
Message-ID: <1417473849.7182.9.camel@kernel.crashing.org>
Subject: Re: [PATCH 03/10] mm: Convert p[te|md]_numa users to
 p[te|md]_protnone_numa
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 02 Dec 2014 09:44:09 +1100
In-Reply-To: <1416578268-19597-4-git-send-email-mgorman@suse.de>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de>
	 <1416578268-19597-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, 2014-11-21 at 13:57 +0000, Mel Gorman wrote:
> void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
>                 pte_t pte)
>  {
> -#ifdef CONFIG_DEBUG_VM
> -       WARN_ON(pte_val(*ptep) & _PAGE_PRESENT);
> -#endif
> +       /*
> +        * When handling numa faults, we already have the pte marked
> +        * _PAGE_PRESENT, but we can be sure that it is not in hpte.
> +        * Hence we can use set_pte_at for them.
> +        */
> +       VM_WARN_ON((pte_val(*ptep) & (_PAGE_PRESENT | _PAGE_USER)) ==
> +               (_PAGE_PRESENT | _PAGE_USER));
> +

His is that going to fare with set_pte_at() called for kernel pages ?

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
