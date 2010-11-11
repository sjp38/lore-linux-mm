Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C835B6B0098
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 02:51:03 -0500 (EST)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id oAB7p0Ax000830
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 23:51:00 -0800
Received: from pxi16 (pxi16.prod.google.com [10.243.27.16])
	by hpaq5.eem.corp.google.com with ESMTP id oAB7oqaJ009096
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 23:50:59 -0800
Received: by pxi16 with SMTP id 16so372699pxi.32
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 23:50:57 -0800 (PST)
Date: Wed, 10 Nov 2010 23:50:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] fix __set_page_dirty_no_writeback() return value
In-Reply-To: <1289445963-29664-1-git-send-email-lliubbo@gmail.com>
Message-ID: <alpine.DEB.2.00.1011102340450.7571@chino.kir.corp.google.com>
References: <1289445963-29664-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, Ken Chen <kenchen@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Nov 2010, Bob Liu wrote:

> __set_page_dirty_no_writeback() should return true if it actually transitioned
> the page from a clean to dirty state although it seems nobody used its return
> value now.
> 
> Change from v2:
> 	* use TestSet to avoid racing
> 
> Change from v1:
> 	* preserving cacheline optimisation as Andrew pointed out
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/page-writeback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index bf85062..1ebfb86 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1158,7 +1158,7 @@ EXPORT_SYMBOL(write_one_page);
>  int __set_page_dirty_no_writeback(struct page *page)
>  {
>  	if (!PageDirty(page))
> -		SetPageDirty(page);
> +		return !TestSetPageDirty(page);
>  	return 0;
>  }

No need for a conditional, just return !TestSetPageDirty(page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
