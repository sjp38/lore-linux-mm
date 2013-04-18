Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id A10EB6B00CC
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 20:13:33 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id lj1so1167646pab.7
        for <linux-mm@kvack.org>; Wed, 17 Apr 2013 17:13:32 -0700 (PDT)
Message-ID: <516F3AA7.1000908@gmail.com>
Date: Thu, 18 Apr 2013 08:13:27 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] swap: redirty page if page write fails on swap file
References: <516E918B.3050309@redhat.com>
In-Reply-To: <516E918B.3050309@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Hi Jerome,
On 04/17/2013 08:11 PM, Jerome Marchand wrote:
> Since commit 62c230b, swap_writepage() calls direct_IO on swap files.
> However, in that case page isn't redirtied if I/O fails, and is therefore
> handled afterwards as if it has been successfully written to the swap
> file, leading to memory corruption when the page is eventually swapped
> back in.
> This patch sets the page dirty when direct_IO() fails. It fixes a memory

If swapfile has related page cache which cached swapfile in memory? It 
is not necessary, correct?

> corruption that happened while using swap-over-NFS.
>
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> ---
>   mm/page_io.c |    2 ++
>   1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 78eee32..04ca00d 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -222,6 +222,8 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
>   		if (ret == PAGE_SIZE) {
>   			count_vm_event(PSWPOUT);
>   			ret = 0;
> +		} else {
> +			set_page_dirty(page);
>   		}
>   		return ret;
>   	}
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
