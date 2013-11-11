Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4A08D6B00BE
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 02:25:41 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kq14so4974451pab.21
        for <linux-mm@kvack.org>; Sun, 10 Nov 2013 23:25:40 -0800 (PST)
Received: from psmtp.com ([74.125.245.182])
        by mx.google.com with SMTP id j10si5164408pae.68.2013.11.10.23.25.38
        for <linux-mm@kvack.org>;
        Sun, 10 Nov 2013 23:25:39 -0800 (PST)
Date: Mon, 11 Nov 2013 07:25:06 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: converting unicore32 to gate_vma as done for arm (was Re:??
 [PATCH] mm: cache largest vma)
Message-ID: <20131111072506.GW13318@ZenIV.linux.org.uk>
References: <20131104044844.GN13318@ZenIV.linux.org.uk>
 <289468516.24288.1383619755331.JavaMail.root@bj-mail03.pku.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <289468516.24288.1383619755331.JavaMail.root@bj-mail03.pku.edu.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ????????? <gxt@pku.edu.cn>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Nov 05, 2013 at 10:49:15AM +0800, ????????? wrote:
> The patch is ok for unicore32. Thanks Al.
> 
> While testing this patch, a bug is found in arch/unicore32/include/asm/pgtable.h:
> 
> @@ -96,7 +96,7 @@ extern pgprot_t pgprot_kernel;
>                                                                 | PTE_EXEC)
>  #define PAGE_READONLY          __pgprot(pgprot_val(pgprot_user | PTE_READ)
>  #define PAGE_READONLY_EXEC     __pgprot(pgprot_val(pgprot_user | PTE_READ \
> -                                                               | PTE_EXEC)
> +                                                               | PTE_EXEC))
> 
> In fact, all similar macros are wrong. I'll post an bug-fix patch for this obvious error.

BTW, another missing thing is an analog of commit 9b61a4 (ARM: prevent
VM_GROWSDOWN mmaps extending below FIRST_USER_ADDRESS); I'm not sure why
does unicore32 have FIRST_USER_ADDRESS set to PAGE_SIZE (some no-MMU
arm variants really need that, what with the vectors page living at
address 0 on those), but since you have it set that way, you'd probably
better not allow a mapping to grow down there...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
