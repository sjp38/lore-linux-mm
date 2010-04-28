Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8C54B6B01EF
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 14:04:12 -0400 (EDT)
Date: Wed, 28 Apr 2010 20:03:36 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH] take all anon_vma locks in anon_vma_lock
Message-ID: <20100428180336.GC510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <1272403852-10479-3-git-send-email-mel@csn.ul.ie>
 <20100427231007.GA510@random.random>
 <20100428091555.GB15815@csn.ul.ie>
 <20100428153525.GR510@random.random>
 <20100428155558.GI15815@csn.ul.ie>
 <20100428162305.GX510@random.random>
 <20100428134719.32e8011b@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428134719.32e8011b@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 01:47:19PM -0400, Rik van Riel wrote:
>  static inline void anon_vma_unlock(struct vm_area_struct *vma)

never mind as this is RFC, lock is clear enough

> @@ -1762,7 +1760,8 @@ static int expand_downwards(struct vm_area_struct *vma,
>  	if (error)
>  		return error;
>  
> -	anon_vma_lock(vma);
> +	spin_lock(&mm->page_table_lock);
> +	anon_vma_lock(vma, &mm->page_table_lock);

This will cause a lock inversion (page_table_lock can only be taken
after the anon_vma lock). I don't immediately see why the
page_table_lock here though?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
