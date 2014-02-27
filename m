Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1658B6B0072
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:03:26 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so3008476pab.18
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 13:03:25 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id pg1si504185pac.96.2014.02.27.13.03.24
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 13:03:25 -0800 (PST)
Date: Thu, 27 Feb 2014 13:03:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm/pagewalk.c: fix end address calculation in
 walk_page_range()
Message-Id: <20140227130323.0d4f0a27b4327100805bab02@linux-foundation.org>
In-Reply-To: <1393475977-3381-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1393475977-3381-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 26 Feb 2014 23:39:35 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> When we try to walk over inside a vma, walk_page_range() tries to walk
> until vma->vm_end even if a given end is before that point.
> So this patch takes the smaller one as an end address.
> 
> ...
>
> --- next-20140220.orig/mm/pagewalk.c
> +++ next-20140220/mm/pagewalk.c
> @@ -321,8 +321,9 @@ int walk_page_range(unsigned long start, unsigned long end,
>  			next = vma->vm_start;
>  		} else { /* inside the found vma */
>  			walk->vma = vma;
> -			next = vma->vm_end;
> -			err = walk_page_test(start, end, walk);
> +			next = min_t(unsigned long, end, vma->vm_end);

min_t is unneeded, isn't it?  Everything here has type unsigned long.

> +			err = walk_page_test(start, next, walk);
>  			if (skip_lower_level_walking(walk))
>  				continue;
>  			if (err)

I'm assuming this is a fix against
pagewalk-update-page-table-walker-core.patch and shall eventually be
folded into that patch.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
