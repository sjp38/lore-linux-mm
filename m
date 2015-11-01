Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0E12A82F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 05:00:25 -0500 (EST)
Received: by wijp11 with SMTP id p11so34870560wij.0
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 02:00:24 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id f62si15321620wmd.43.2015.11.01.02.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Nov 2015 02:00:23 -0800 (PST)
Received: by wmec75 with SMTP id c75so39624679wme.1
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 02:00:23 -0800 (PST)
Message-ID: <5635E2B4.5070308@electrozaur.com>
Date: Sun, 01 Nov 2015 12:00:20 +0200
From: Boaz Harrosh <ooo@electrozaur.com>
MIME-Version: 1.0
Subject: Re: [PATCH] osd fs: __r4w_get_page rely on PageUptodate for uptodate
References: <alpine.LSU.2.11.1510291137430.3369@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1510291137430.3369@eggly.anvils>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benny Halevy <bhalevy@primarydata.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Lameter <cl@linux.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, osd-dev@open-osd.org

On 10/29/2015 08:43 PM, Hugh Dickins wrote:
> Patch "mm: migrate dirty page without clear_page_dirty_for_io etc",
> presently staged in mmotm and linux-next, simplifies the migration of
> a PageDirty pagecache page: one stat needs moving from zone to zone
> and that's about all.
> 
> It's convenient and safest for it to shift the PageDirty bit from old
> page to new, just before updating the zone stats: before copying data
> and marking the new PageUptodate.  This is all done while both pages
> are isolated and locked, just as before; and just as before, there's
> a moment when the new page is visible in the radix_tree, but not yet
> PageUptodate.  What's new is that it may now be briefly visible as
> PageDirty before it is PageUptodate.
> 
> When I scoured the tree to see if this could cause a problem anywhere,
> the only places I found were in two similar functions __r4w_get_page():
> which look up a page with find_get_page() (not using page lock), then
> claim it's uptodate if it's PageDirty or PageWriteback or PageUptodate.
> 
> I'm not sure whether that was right before, but now it might be wrong
> (on rare occasions): only claim the page is uptodate if PageUptodate.
> Or perhaps the page in question could never be migratable anyway?
> 

Hi Sir Hugh

I'm sorry, I admit the code is clear as mud, but your patch below is wrong.

The *uptodate return from __r4w_get_page is not really "up-to-date" at all
actually it means: "do we need to read the page from storage" writable/dirty pages
we do not read from storage but use the newest data in memory.

r4w means read-for-write which is when we need to bring in the full stripe to
re-calculate raid5/6 . (when only the partial stripe is written)

The scenario below of: "briefly visible as PageDirty before it is PageUptodate"
is fine in this case because in both cases we do not need to read the page.

Thanks for looking
Boaz

> Signed-off-by: Hugh Dickins <hughd@google.com>

This patch is not correct!

> ---
> 
>  fs/exofs/inode.c             |    5 +----
>  fs/nfs/objlayout/objio_osd.c |    5 +----
>  2 files changed, 2 insertions(+), 8 deletions(-)
> 
> --- 4.3-next/fs/exofs/inode.c	2015-08-30 11:34:09.000000000 -0700
> +++ linux/fs/exofs/inode.c	2015-10-28 16:55:18.795554294 -0700
> @@ -592,10 +592,7 @@ static struct page *__r4w_get_page(void
>  			}
>  			unlock_page(page);
>  		}
> -		if (PageDirty(page) || PageWriteback(page))
> -			*uptodate = true;
> -		else
> -			*uptodate = PageUptodate(page);
> +		*uptodate = PageUptodate(page);
>  		EXOFS_DBGMSG2("index=0x%lx uptodate=%d\n", index, *uptodate);
>  		return page;
>  	} else {
> --- 4.3-next/fs/nfs/objlayout/objio_osd.c	2015-10-21 18:35:07.620645439 -0700
> +++ linux/fs/nfs/objlayout/objio_osd.c	2015-10-28 16:53:55.083686639 -0700
> @@ -476,10 +476,7 @@ static struct page *__r4w_get_page(void
>  		}
>  		unlock_page(page);
>  	}
> -	if (PageDirty(page) || PageWriteback(page))
> -		*uptodate = true;
> -	else
> -		*uptodate = PageUptodate(page);
> +	*uptodate = PageUptodate(page);
>  	dprintk("%s: index=0x%lx uptodate=%d\n", __func__, index, *uptodate);
>  	return page;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
