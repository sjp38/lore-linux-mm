Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4DFEB6B006E
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 16:54:20 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so188754428wgd.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 13:54:20 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id fo8si1833334wib.48.2015.03.30.13.54.18
        for <linux-mm@kvack.org>;
        Mon, 30 Mar 2015 13:54:18 -0700 (PDT)
Date: Mon, 30 Mar 2015 23:54:13 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/mmap.c: use while instead of if+goto
Message-ID: <20150330205413.GA4458@node.dhcp.inet.fi>
References: <1427744435-6304-1-git-send-email-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427744435-6304-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Roman Gushchin <klamm@yandex-team.ru>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 30, 2015 at 09:40:35PM +0200, Rasmus Villemoes wrote:
> The creators of the C language gave us the while keyword. Let's use
> that instead of synthesizing it from if+goto.
> 
> Made possible by 6597d783397a ("mm/mmap.c: replace find_vma_prepare()
> with clearer find_vma_links()").
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>


Looks good, except both your plus-lines are over 80-characters long for no
reason.

> ---
>  mm/mmap.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index da9990acc08b..e1ae629b1e9c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1553,11 +1553,9 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  
>  	/* Clear old maps */
>  	error = -ENOMEM;
> -munmap_back:
> -	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
> +	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
>  		if (do_munmap(mm, addr, len))
>  			return -ENOMEM;
> -		goto munmap_back;
>  	}
>  
>  	/*
> @@ -2741,11 +2739,9 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
>  	/*
>  	 * Clear old maps.  this also does some error checking for us
>  	 */
> - munmap_back:
> -	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
> +	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
>  		if (do_munmap(mm, addr, len))
>  			return -ENOMEM;
> -		goto munmap_back;
>  	}
>  
>  	/* Check against address space limits *after* clearing old maps... */
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
