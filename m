Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id CFCDD6B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 16:37:48 -0400 (EDT)
Date: Mon, 22 Apr 2013 13:37:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] swap: redirty page if page write fails on swap file
Message-Id: <20130422133746.ffbbb70c0394fdbf1096c7ee@linux-foundation.org>
In-Reply-To: <516E918B.3050309@redhat.com>
References: <516E918B.3050309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On Wed, 17 Apr 2013 14:11:55 +0200 Jerome Marchand <jmarchan@redhat.com> wrote:

> 
> Since commit 62c230b, swap_writepage() calls direct_IO on swap files.
> However, in that case page isn't redirtied if I/O fails, and is therefore
> handled afterwards as if it has been successfully written to the swap
> file, leading to memory corruption when the page is eventually swapped
> back in.
> This patch sets the page dirty when direct_IO() fails. It fixes a memory
> corruption that happened while using swap-over-NFS.
> 
> ...
>
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -222,6 +222,8 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
>  		if (ret == PAGE_SIZE) {
>  			count_vm_event(PSWPOUT);
>  			ret = 0;
> +		} else {
> +			set_page_dirty(page);
>  		}
>  		return ret;
>  	}

So what happens to the page now?  It remains dirty and the kernel later
tries to write it again?  And if that write also fails, the page is
effectively leaked until process exit?


Aside: Mel, __swap_writepage() is fairly hair-raising.  It unlocks the
page before doing the IO and doesn't set PageWriteback().  Why such an
exception from normal handling?

Also, what is protecting the page from concurrent reclaim or exit()
during the above swap_writepage()?

Seems that the code needs a bunch of fixes or a bunch of comments
explaining why it is safe and why it has to be this way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
