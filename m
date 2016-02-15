Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6017A6B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 00:10:05 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id fl4so67761044pad.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:10:05 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id 5si40757773pfq.204.2016.02.14.21.10.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 21:10:04 -0800 (PST)
Received: by mail-pa0-x241.google.com with SMTP id zv9so940116pab.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:10:04 -0800 (PST)
Message-ID: <1455512997.16012.24.camel@gmail.com>
Subject: Re: [PATCH V3] powerpc/mm: Fix Multi hit ERAT cause by recent THP
 update
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 15 Feb 2016 16:09:57 +1100
In-Reply-To: <87lh6mfv2j.fsf@linux.vnet.ibm.com>
References: 
	<1454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1455504278.16012.18.camel@gmail.com> <87lh6mfv2j.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> Now we can't depend for mm_cpumask, a parallel find_linux_pte_hugepte
> can happen outside that. Now i had a variant for kick_all_cpus_sync that
> ignored idle cpus. But then that needs more verification.
> 
> http://article.gmane.org/gmane.linux.ports.ppc.embedded/81105
Can be racy as a CPU moves from non-idle to idle

In

> +A A A A A pmd_hugepage_update(vma->vm_mm, address, pmdp, ~0UL, 0);
> +A A A A A /*
> +A A A A A A * This ensures that generic code that rely on IRQ disabling
> +A A A A A A * to prevent a parallel THP split work as expected.
> +A A A A A A */
> +A A A A A kick_all_cpus_sync();

pmdp_invalidate()->pmd_hugepage_update() can still run in parallel withA 
find_linux_pte_or_hugepte() and race.. Am I missing something?

Balbir Singh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
