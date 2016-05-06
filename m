Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3589C6B0253
	for <linux-mm@kvack.org>; Fri,  6 May 2016 13:33:35 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y84so42358197lfc.3
        for <linux-mm@kvack.org>; Fri, 06 May 2016 10:33:35 -0700 (PDT)
Received: from mail-lf0-x236.google.com (mail-lf0-x236.google.com. [2a00:1450:4010:c07::236])
        by mx.google.com with ESMTPS id j3si11677528lbc.107.2016.05.06.10.33.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 10:33:33 -0700 (PDT)
Received: by mail-lf0-x236.google.com with SMTP id j8so138791179lfd.2
        for <linux-mm@kvack.org>; Fri, 06 May 2016 10:33:33 -0700 (PDT)
Date: Fri, 6 May 2016 20:33:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/3] mm: thp: microoptimize compound_mapcount()
Message-ID: <20160506173330.GA9879@node.shutemov.name>
References: <1462547040-1737-1-git-send-email-aarcange@redhat.com>
 <1462547040-1737-3-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462547040-1737-3-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>

On Fri, May 06, 2016 at 05:03:59PM +0200, Andrea Arcangeli wrote:
> compound_mapcount() is only called after PageCompound() has already
> been checked by the caller, so there's no point to check it again. Gcc
> may optimize it away too because it's inline but this will remove the
> runtime check for sure and add it'll add an assert instead.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> ---
>  include/linux/mm.h | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 263f229..726ba80 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -471,8 +471,7 @@ static inline atomic_t *compound_mapcount_ptr(struct page *page)
>  
>  static inline int compound_mapcount(struct page *page)
>  {
> -	if (!PageCompound(page))
> -		return 0;
> +	VM_BUG_ON_PAGE(!PageCompound(page), page);
>  	page = compound_head(page);
>  	return atomic_read(compound_mapcount_ptr(page)) + 1;
>  }

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
