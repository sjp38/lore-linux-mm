Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4CF935F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 02:55:30 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH v3 6/6] fix wrong get_user_pages usage in iovlock.c
Date: Tue, 14 Apr 2009 16:56:11 +1000
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <20090414152151.C659.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090414152151.C659.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904141656.14191.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Maciej Sosnowski <maciej.sosnowski@intel.com>, "David S. Miller" <davem@davemloft.net>, Chris Leech <christopher.leech@intel.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 14 April 2009 16:23:13 KOSAKI Motohiro wrote:
> I don't have NET-DMA usable device. I hope to get expert review.
> 
> =========================
> Subject: [Untested][RFC][PATCH] fix wrong get_user_pages usage in iovlock.c
> 
> 	down_read(mmap_sem)
> 	get_user_pages()
> 	up_read(mmap_sem)
> 
> is fork unsafe.
> fix it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Maciej Sosnowski <maciej.sosnowski@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Chris Leech <christopher.leech@intel.com>
> Cc: netdev@vger.kernel.org
> ---
>  drivers/dma/iovlock.c |   18 ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
> 
> Index: b/drivers/dma/iovlock.c
> ===================================================================
> --- a/drivers/dma/iovlock.c	2009-02-21 16:53:23.000000000 +0900
> +++ b/drivers/dma/iovlock.c	2009-04-13 04:46:02.000000000 +0900
> @@ -94,18 +94,10 @@ struct dma_pinned_list *dma_pin_iovec_pa
>  		pages += page_list->nr_pages;
>  
>  		/* pin pages down */
> -		down_read(&current->mm->mmap_sem);
> -		ret = get_user_pages(
> -			current,
> -			current->mm,
> -			(unsigned long) iov[i].iov_base,
> -			page_list->nr_pages,
> -			1,	/* write */
> -			0,	/* force */
> -			page_list->pages,
> -			NULL);
> -		up_read(&current->mm->mmap_sem);
> -
> +		down_read(&current->mm->mm_pinned_sem);
> +		ret = get_user_pages_fast((unsigned long) iov[i].iov_base,
> +					  page_list->nr_pages, 1,
> +					  page_list->pages);

I would perhaps not fold gup_fast conversions into the same patch as
the fix.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
