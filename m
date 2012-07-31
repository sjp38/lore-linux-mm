Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 60C2A6B005A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 22:35:00 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so6555167ghr.14
        for <linux-mm@kvack.org>; Mon, 30 Jul 2012 19:34:59 -0700 (PDT)
Date: Mon, 30 Jul 2012 19:34:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC patch] vm: clear swap entry before copying pte
In-Reply-To: <CAJd=RBDQ1J9UTWOK1x6XNYunFz36RsMnr1Om9HsQQ_Kp8P7RKQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1207301907010.3953@eggly.anvils>
References: <CAJd=RBDQ1J9UTWOK1x6XNYunFz36RsMnr1Om9HsQQ_Kp8P7RKQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, 27 Jul 2012, Hillf Danton wrote:
> 
> If swap entry is cleared, we can see the reason that copying pte is
> interrupted. If due to page table lock held long enough, no need to
> increase swap count.

I can't see a bug to be fixed here.

How would it break out of the loop above without freshly setting entry
(given that mmap_sem is held with down_write, so the entries cannot be
munmap'ped by another thread)?  How would it matter if it could (given
that add_swap_count_continuation already allows for races; and if there
were a problem, the call just made could be equally at fault)?

Nor do I understand your description.

But I can see that the lack of reinitialization of entry.val here
does raise doubt and confusion.  A better tidyup would be to remove
the initialization of swp_entry_t entry from its onstack declaration,
and do it at the again label instead.

If you send a patch to do that instead, I could probably ack it -
but expect I shall want to change your description.

Hugh

> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/memory.c	Fri Jul 27 21:33:32 2012
> +++ b/mm/memory.c	Fri Jul 27 21:35:24 2012
> @@ -971,6 +971,7 @@ again:
>  		if (add_swap_count_continuation(entry, GFP_KERNEL) < 0)
>  			return -ENOMEM;
>  		progress = 0;
> +		entry.val = 0;
>  	}
>  	if (addr != end)
>  		goto again;
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
