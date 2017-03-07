Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3311A6B038B
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 09:26:48 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g8so1803246wmg.7
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:26:48 -0800 (PST)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id y63si219037wrb.176.2017.03.07.06.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 06:26:47 -0800 (PST)
Received: by mail-wr0-x243.google.com with SMTP id l37so441830wrc.3
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:26:46 -0800 (PST)
Date: Tue, 7 Mar 2017 17:26:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 04/11] mm: remove SWAP_MLOCK check for SWAP_SUCCESS in ttu
Message-ID: <20170307142643.GD2779@node.shutemov.name>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-5-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488436765-32350-5-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On Thu, Mar 02, 2017 at 03:39:18PM +0900, Minchan Kim wrote:
> If the page is mapped and rescue in ttuo, page_mapcount(page) == 0 cannot
> be true so page_mapcount check in ttu is enough to return SWAP_SUCCESS.
> IOW, SWAP_MLOCK check is redundant so remove it.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/rmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 3a14013..0a48958 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1523,7 +1523,7 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
>  	else
>  		ret = rmap_walk(page, &rwc);
>  
> -	if (ret != SWAP_MLOCK && !page_mapcount(page))
> +	if (!page_mapcount(page))

Hm. I think there's bug in current code.
It should be !total_mapcount(page) otherwise it can be false-positive if
there's THP mapped with PTEs.

And in this case ret != SWAP_MLOCK is helpful to cut down some cost.
Althouth it should be fine to remove it, I guess.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
