Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1480860021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 23:11:25 -0500 (EST)
Received: by pzk27 with SMTP id 27so4820515pzk.12
        for <linux-mm@kvack.org>; Sun, 27 Dec 2009 20:11:24 -0800 (PST)
Date: Mon, 28 Dec 2009 13:09:26 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Prevent churning of zero page
 in LRU list.
Message-Id: <20091228130926.6874d7b2.minchan.kim@barrios-desktop>
In-Reply-To: <4B38246C.3020209@redhat.com>
References: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop>
	<4B38246C.3020209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, Rik. 

On Sun, 27 Dec 2009 22:22:20 -0500
Rik van Riel <riel@redhat.com> wrote:

> On 12/27/2009 09:53 PM, Minchan Kim wrote:
> >
> > VM doesn't add zero page to LRU list.
> > It means zero page's churning in LRU list is pointless.
> >
> > As a matter of fact, zero page can't be promoted by mark_page_accessed
> > since it doesn't have PG_lru.
> >
> > This patch prevent unecessary mark_page_accessed call of zero page
> > alghouth caller want FOLL_TOUCH.
> >
> > Signed-off-by: Minchan Kim<minchan.kim@gmail.com>
> 
> The code looks correct, but I wonder how frequently we run into
> the zero page in this code, vs. how much the added cost is of
> having this extra code in follow_page.
> 
> What kind of problem were you running into that motivated you
> to write this patch?

I didn't have experienced any problem in this case. 
In fact, I found that while trying to make patch smap_pte_change. 

Long time ago when we have a zero page, we regards it to file_rss. 
So while we see the smaps, vm_normal_page returns zero page and we can
calculate it properly with PSS. 

But now we don't acccout zero page to file_rss. 
I am not sure we have to account it with file_rss. 
So I think now smaps_pte_range's resident count routine also is changed. 

Anyway, I think my patch doesn't have much cost since many customers of 
follow_page are already not a fast path.

I tend to agree with your opinion "How frequently we runt into the zero page?"
But my thought GUP is export function which can be used for anything by anyone.

Thanks for the review, Rik. 

> 
> -- 
> All rights reversed.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
