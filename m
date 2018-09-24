Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 22F088E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 14:27:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b4-v6so9802143ede.4
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:27:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g45-v6si2314191edg.399.2018.09.24.11.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 11:27:54 -0700 (PDT)
Subject: Re: [patch] mm, thp: always specify ineligible vmas as nh in smaps
References: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz>
Date: Mon, 24 Sep 2018 20:25:15 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, Linux-MM layout <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

+CC linux-mm linux-api

On 9/24/18 7:55 PM, David Rientjes wrote:
> Commit 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
> introduced a regression in that userspace cannot always determine the set
> of vmas where thp is ineligible.
> 
> Userspace relies on the "nh" flag being emitted as part of /proc/pid/smaps
> to determine if a vma is eligible to be backed by hugepages.
> 
> Previous to this commit, prctl(PR_SET_THP_DISABLE, 1) would cause thp to
> be disabled and emit "nh" as a flag for the corresponding vmas as part of
> /proc/pid/smaps.  After the commit, thp is disabled by means of an mm
> flag and "nh" is not emitted.
> 
> This causes smaps parsing libraries to assume a vma is eligible for thp
> and ends up puzzling the user on why its memory is not backed by thp.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Fixes: 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")

Not worth for stable IMO, but makes sense otherwise.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

A question below:

> ---
>  fs/proc/task_mmu.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -653,13 +653,23 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
>  #endif
>  #endif /* CONFIG_ARCH_HAS_PKEYS */
>  	};
> +	unsigned long flags = vma->vm_flags;
>  	size_t i;
>  
> +	/*
> +	 * Disabling thp is possible through both MADV_NOHUGEPAGE and
> +	 * PR_SET_THP_DISABLE.  Both historically used VM_NOHUGEPAGE.  Since
> +	 * the introduction of MMF_DISABLE_THP, however, userspace needs the
> +	 * ability to detect vmas where thp is not eligible in the same manner.
> +	 */
> +	if (vma->vm_mm && test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
> +		flags |= VM_NOHUGEPAGE;

Should it also clear VM_HUGEPAGE? In case MMF_DISABLE_THP overrides a
madvise(MADV_HUGEPAGE)'d vma? (I expect it does?)

> +
>  	seq_puts(m, "VmFlags: ");
>  	for (i = 0; i < BITS_PER_LONG; i++) {
>  		if (!mnemonics[i][0])
>  			continue;
> -		if (vma->vm_flags & (1UL << i)) {
> +		if (flags & (1UL << i)) {
>  			seq_putc(m, mnemonics[i][0]);
>  			seq_putc(m, mnemonics[i][1]);
>  			seq_putc(m, ' ');
> 
