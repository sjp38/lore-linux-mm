Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 401536B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 18:19:13 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id i50so2219404qgf.20
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 15:19:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k3si7197842qae.48.2014.07.23.15.19.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jul 2014 15:19:12 -0700 (PDT)
Date: Wed, 23 Jul 2014 17:45:54 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mm] mm: refactor page index/offset getters
Message-ID: <20140723214554.GA2263@nhori.bos.redhat.com>
References: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140701180739.GA4985@node.dhcp.inet.fi>
 <20140701185021.GA10356@nhori.bos.redhat.com>
 <20140701201540.GA5953@node.dhcp.inet.fi>
 <20140702043057.GA19813@nhori.redhat.com>
 <20140707123923.5e42983d6123ebfd79c8cf4c@linux-foundation.org>
 <20140715164112.GA6055@nhori.bos.redhat.com>
 <20140723143918.8334558ccac8c29047c0058b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140723143918.8334558ccac8c29047c0058b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jul 23, 2014 at 02:39:18PM -0700, Andrew Morton wrote:
> On Tue, 15 Jul 2014 12:41:12 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > There is a complaint about duplication around the fundamental routines
> > of page index/offset getters.
> > 
> > page_(index|offset) and page_file_(index|offset) provide the same
> > functionality, so we can merge them as page_(index|offset), respectively.
> > 
> > And this patch gives the clear meaning to the getters:
> >  - page_index(): get page cache index (offset in relevant page size)
> >  - page_pgoff(): get 4kB page offset
> >  - page_offset(): get byte offset
> > All these functions are aware of regular pages, swapcaches, and hugepages.
> > 
> > The definition of PageHuge is relocated to include/linux/mm.h, because
> > some users of page_pgoff() doesn't include include/linux/hugetlb.h.
> > 
> > __page_file_index() is not well named, because it's only for swap cache.
> > So let's rename it with __page_swap_index().
> 
> Thanks, I guess that's better.  Could others please have a look-n-think?
> 
> I did this:
> 
> --- a/include/linux/pagemap.h~mm-refactor-page-index-offset-getters-fix
> +++ a/include/linux/pagemap.h
> @@ -412,7 +412,7 @@ static inline pgoff_t page_pgoff(struct
>  }
>  
>  /*
> - * Return the byte offset of the given page.
> + * Return the file offset of the given pagecache page, in bytes.

Thanks, it's clearer.

>  static inline loff_t page_offset(struct page *page)
>  {
> 
> 
> 
> You had a random xfs_aops.c whitespace fix which I'll pretend I didn't
> notice ;)

I just couldn't resist fixing it ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
