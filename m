Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD0D831F5
	for <linux-mm@kvack.org>; Thu, 18 May 2017 11:28:25 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 139so9691442wmf.5
        for <linux-mm@kvack.org>; Thu, 18 May 2017 08:28:25 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id w7si5665247wra.281.2017.05.18.08.28.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 08:28:23 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id 70so50783446wmq.1
        for <linux-mm@kvack.org>; Thu, 18 May 2017 08:28:23 -0700 (PDT)
Date: Thu, 18 May 2017 18:28:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Strange condition in invalidate_mapping_pages()
Message-ID: <20170518152820.4afcctrzzngcdxdz@node.shutemov.name>
References: <20170518132818.GA16430@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518132818.GA16430@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

On Thu, May 18, 2017 at 03:28:18PM +0200, Jan Kara wrote:
> Hi Kirill,
> 
> in commit fc127da085c26 "truncate: handle file thp" you've added the
> following to invalidate_mapping_pages():
> 
>           /* Middle of THP: skip */
>           if (PageTransTail(page)) {
>                   unlock_page(page);
>                   continue;
>           } else if (PageTransHuge(page)) {
>                   index += HPAGE_PMD_NR - 1;
>                   i += HPAGE_PMD_NR - 1;
>                   /* 'end' is in the middle of THP */
>                   if (index ==  round_down(end, HPAGE_PMD_NR))
>                           continue;
>           }
> 
> Now how can ever condition "if (index ==  round_down(end,
> HPAGE_PMD_NR))" be true? We have just added HPAGE_PMD_NR - 1 to 'index'
> so it will not be a multiple of HPAGE_PMD_NR. Presumably you wanted to
> check whether the current THP is the one containing 'end' here which would
> be something like 'round_down(index, HPAGE_PMD_NR) == round_down(end,
> HPAGE_PMD_NR)'.

You're right, it's a bug. 'page->index' instead of 'index' should do the
trick.

Would you like to prepare the patch? (I'm deep in 5-level paging at the
moment.)

> but then I still miss why you'd like to avoid invalidating the partial
> THP at the end of file... Can you please enlighten me? Thanks!

My logic was that the data in the non-invalidated part of the page can be
still useful and it's better to leave it in page cache.

I don't have performance numbers to validate my intuition.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
