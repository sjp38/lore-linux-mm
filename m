Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51E366B000C
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 10:13:59 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v138-v6so3554593pgb.7
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 07:13:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x1-v6si23374268pgc.304.2018.10.10.07.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Oct 2018 07:13:58 -0700 (PDT)
Date: Wed, 10 Oct 2018 07:13:55 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: remove a redundant check in do_munmap()
Message-ID: <20181010141355.GA22625@bombadil.infradead.org>
References: <20181010125327.68803-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010125327.68803-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Wed, Oct 10, 2018 at 08:53:27PM +0800, Wei Yang wrote:
> A non-NULL vma returned from find_vma() implies:
> 
>    vma->vm_start <= start
> 
> Since len != 0, the following condition always hods:
> 
>    vma->vm_start < start + len = end
> 
> This means the if check would never be true.

This is true because earlier in the function, start + len is checked to
be sure that it does not wrap.

> This patch removes this redundant check and fix two typo in comment.

> @@ -2705,12 +2705,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
> -	/* we have  start < vma->vm_end  */
> -
> -	/* if it doesn't overlap, we have nothing.. */
> +	/* we have vma->vm_start <= start < vma->vm_end */
>  	end = start + len;
> -	if (vma->vm_start >= end)
> -		return 0;

I agree that it's not currently a useful check, but it's also not going
to have much effect on anything to delete it.  I think there are probably
more worthwhile places to look for inefficiencies.
