Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 782646B004D
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 10:25:26 -0500 (EST)
Received: by pxi5 with SMTP id 5so4556840pxi.12
        for <linux-mm@kvack.org>; Mon, 01 Feb 2010 07:25:25 -0800 (PST)
Subject: Re: [PATCH -mm] rmap: move exclusively owned pages to own anon_vma
 in do_wp_page
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100128014357.54428c8a@annuminas.surriel.com>
References: <20100128002000.2bf5e365@annuminas.surriel.com>
	 <20100128014357.54428c8a@annuminas.surriel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Feb 2010 00:25:18 +0900
Message-ID: <1265037918.20322.32.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, akpm@linux-foundation.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Hi, Rik. 
It's time too late to review. :)
But I remain my comments for record in future. 

On Thu, 2010-01-28 at 01:43 -0500, Rik van Riel wrote:
> When the parent process breaks the COW on a page, both the original
> and the new page end up in that same anon_vma.  Generally this won't
> be a problem, but for some workloads it could preserve the O(N) rmap
> scanning complexity.
> A simple fix is to ensure that, when a page gets reused in do_wp_page,
> because we already are the exclusive owner, the page gets moved to our
> own exclusive anon_vma.

I want to modify this description following as for clarity

When the parent process breaks the COW on a page, both the original which
is mapped at child and the new page which is mapped parent end up in that
same anon_vma. Generally this won't be a problem, but for some workloads it
could preserve the O(N) rmap scanning complexity.

A simple fix is to ensure that, when a page which is mapped child gets
reused in do_wp_page, because we already are the exclusive owner, the
page gets moved to our own exclusive child's anon_vma. 


> Signed-off-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Let me have a question for my understanding.

Still, don't we have a probability of O(N) in case of parent's page 
at worst case?

What I say is following as.

P : parent's VMA, C : child's VMA
L : live ( target page is linked into parent's anon_vma)
D : dead ( new page was linked into child's anon_vma with this patch
           so this vma doesn't have our target page)

             P      C      C      C      C
anon_vma -> vma -> vma -> vma -> vma -> vma 
             L      D      D      D      L

Such above case, for reclaiming the page, we have to traverse whole list. 

If I miss something, pz correct me. :)

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
