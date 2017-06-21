Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 540456B03C0
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:35:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p64so3619484wrc.8
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:35:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q22si16674957wrb.377.2017.06.21.02.35.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 02:35:51 -0700 (PDT)
Date: Wed, 21 Jun 2017 11:35:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix new crash in unmapped_area_topdown()
Message-ID: <20170621093548.GB22051@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1706200206210.10925@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1706200206210.10925@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 20-06-17 02:10:44, Hugh Dickins wrote:
> Trinity gets kernel BUG at mm/mmap.c:1963! in about 3 minutes of
> mmap testing.  That's the VM_BUG_ON(gap_end < gap_start) at the
> end of unmapped_area_topdown().  Linus points out how MAP_FIXED
> (which does not have to respect our stack guard gap intentions)
> could result in gap_end below gap_start there.  Fix that, and
> the similar case in its alternative, unmapped_area().

I finally found some more time to look at this and the fix looks good to
me. I have checked and it seems to be complete. I was even wondering
wheter we should warn when MAP_FIXED is too close to a stack area. Maybe
somebody does that intentionally, though (I can certainly imagine
PROT_NONE mapping under the stack to protect from {over,under}flows).

> Cc: stable@vger.kernel.org
> Fixes: 1be7107fbe18 ("mm: larger stack guard gap, between vmas")
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Debugged-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Anyway feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
>  mm/mmap.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> --- 4.12-rc6/mm/mmap.c	2017-06-19 09:06:10.035407505 -0700
> +++ linux/mm/mmap.c	2017-06-19 21:09:28.616707311 -0700
> @@ -1817,7 +1817,8 @@ unsigned long unmapped_area(struct vm_un
>  		/* Check if current node has a suitable gap */
>  		if (gap_start > high_limit)
>  			return -ENOMEM;
> -		if (gap_end >= low_limit && gap_end - gap_start >= length)
> +		if (gap_end >= low_limit &&
> +		    gap_end > gap_start && gap_end - gap_start >= length)
>  			goto found;
>  
>  		/* Visit right subtree if it looks promising */
> @@ -1920,7 +1921,8 @@ unsigned long unmapped_area_topdown(stru
>  		gap_end = vm_start_gap(vma);
>  		if (gap_end < low_limit)
>  			return -ENOMEM;
> -		if (gap_start <= high_limit && gap_end - gap_start >= length)
> +		if (gap_start <= high_limit &&
> +		    gap_end > gap_start && gap_end - gap_start >= length)
>  			goto found;
>  
>  		/* Visit left subtree if it looks promising */

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
