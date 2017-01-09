Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A18F6B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 18:16:42 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y143so103419626pfb.6
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 15:16:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q82si15360522pfa.288.2017.01.09.15.16.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 15:16:41 -0800 (PST)
Date: Mon, 9 Jan 2017 15:18:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/4] mm: add new mmget() helper
Message-Id: <20170109151808.f2ea647c1cf3d2cc9734a88c@linux-foundation.org>
In-Reply-To: <20161218123229.22952-2-vegard.nossum@oracle.com>
References: <20161218123229.22952-1-vegard.nossum@oracle.com>
	<20161218123229.22952-2-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On Sun, 18 Dec 2016 13:32:27 +0100 Vegard Nossum <vegard.nossum@oracle.com> wrote:

> Apart from adding the helper function itself, the rest of the kernel is
> converted mechanically using:
> 
>   git grep -l 'atomic_inc.*mm_users' | xargs sed -i 's/atomic_inc(&\(.*\)->mm_users);/mmget\(\1\);/'
>   git grep -l 'atomic_inc.*mm_users' | xargs sed -i 's/atomic_inc(&\(.*\)\.mm_users);/mmget\(\&\1\);/'
> 
> This is needed for a later patch that hooks into the helper, but might be
> a worthwhile cleanup on its own.
>
> ...
>

mmgrap() and mmget() naming is really quite confusing.

> --- a/arch/arc/kernel/smp.c
> +++ b/arch/arc/kernel/smp.c
> @@ -124,7 +124,7 @@ void start_kernel_secondary(void)
>  	/* MMU, Caches, Vector Table, Interrupts etc */
>  	setup_processor();
>  
> -	atomic_inc(&mm->mm_users);
> +	mmget(mm);

I wonder if mmuse() would be a bit clearer than mmget().  Although that
sounds like use_mm().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
