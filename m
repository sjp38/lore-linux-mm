Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id A60176B01F7
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 18:12:17 -0500 (EST)
Date: Mon, 12 Dec 2011 15:12:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: vmscan: try to free orphaned page
Message-Id: <20111212151215.2363f5cd.akpm@linux-foundation.org>
In-Reply-To: <CAJd=RBAN7cK_6OstO=5gszW8cJ_d4-8iQC3gWG6HUtabiMN9Yg@mail.gmail.com>
References: <CAJd=RBAN7cK_6OstO=5gszW8cJ_d4-8iQC3gWG6HUtabiMN9Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 12 Dec 2011 20:24:39 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> If the orphaned page has no buffer attached at the moment, we clean it up by
> hand, then it has the chance to progress the freeing trip.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/vmscan.c	Sun Dec  4 13:10:08 2011
> +++ b/mm/vmscan.c	Mon Dec 12 20:12:44 2011
> @@ -487,12 +487,10 @@ static pageout_t pageout(struct page *pa
>  		 * Some data journaling orphaned pages can have
>  		 * page->mapping == NULL while being dirty with clean buffers.
>  		 */
> -		if (page_has_private(page)) {
> -			if (try_to_free_buffers(page)) {
> -				ClearPageDirty(page);
> -				printk("%s: orphaned page\n", __func__);
> -				return PAGE_CLEAN;
> -			}
> +		if (!page_has_private(page) || try_to_free_buffers(page)) {
> +			ClearPageDirty(page);
> +			printk(KERN_INFO "%s: orphaned page\n", __func__);
> +			return PAGE_CLEAN;
>  		}
>  		return PAGE_KEEP;
>  	}

So if we find a dirty pagecache page with nothing at ->private, you're
suggesting that we simply mark it clean and free it.

afacit it would be a bug for a page to be in that state.

What prompted this patch?  I assume you've not encountered pages in
this state in your testing because if you had, that printk wouldn't
still be in there!

A brief bit of googling indicates that nobody has seen the "pageout:
orphaned page" warning for five years.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
