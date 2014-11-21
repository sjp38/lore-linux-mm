Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 962F16B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 00:29:01 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id ft15so4507031pdb.22
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 21:29:01 -0800 (PST)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id fb1si6443019pab.61.2014.11.20.21.28.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 21:29:00 -0800 (PST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 21 Nov 2014 15:28:54 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 53F433578052
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 16:28:48 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAL5UeNT32506096
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 16:30:42 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAL5SjBc013790
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 16:28:46 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 03/10] mm: Convert p[te|md]_numa users to p[te|md]_protnone_numa
In-Reply-To: <1416478790-27522-4-git-send-email-mgorman@suse.de>
References: <1416478790-27522-1-git-send-email-mgorman@suse.de> <1416478790-27522-4-git-send-email-mgorman@suse.de>
Date: Fri, 21 Nov 2014 10:58:34 +0530
Message-ID: <87lhn56s1p.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

Mel Gorman <mgorman@suse.de> writes:

> Convert existing users of pte_numa and friends to the new helper. Note
> that the kernel is broken after this patch is applied until the other
> page table modifiers are also altered. This patch layout is to make
> review easier.
>

.....

> diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
> index c90e602..b5d58d3 100644
> --- a/arch/powerpc/mm/pgtable.c
> +++ b/arch/powerpc/mm/pgtable.c
> @@ -173,7 +173,13 @@ void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
>  		pte_t pte)
>  {
>  #ifdef CONFIG_DEBUG_VM
> -	WARN_ON(pte_val(*ptep) & _PAGE_PRESENT);
> +	/*
> +	 * When handling numa faults, we already have the pte marked
> +	 * _PAGE_PRESENT, but we can be sure that it is not in hpte.
> +	 * Hence we can use set_pte_at for them.
> +	 */
> +	WARN_ON((pte_val(*ptep) & (_PAGE_PRESENT | _PAGE_USER)) ==
> +		(_PAGE_PRESENT | _PAGE_USER));
>  #endif


This can be VM_WARN_ON with #ifdef removed.

>  	/* Note: mm->context.id might not yet have been assigned as
>  	 * this context might not have been activated yet when this
> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
