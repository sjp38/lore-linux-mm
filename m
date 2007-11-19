Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAJLH51p005216
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 16:17:05 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAJLH5Ax459516
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 16:17:05 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJLH53D014951
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 16:17:05 -0500
Subject: Re: [Patch] mm/sparse.c: Check the return value of
	sparse_index_alloc().
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071115135428.GE2489@hacking>
References: <20071115135428.GE2489@hacking>
Content-Type: text/plain
Date: Mon, 19 Nov 2007 13:17:02 -0800
Message-Id: <1195507022.27759.146.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: WANG Cong <xiyou.wangcong@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-11-15 at 21:54 +0800, WANG Cong wrote:
> Since sparse_index_alloc() can return NULL on memory allocation failure,
> we must deal with the failure condition when calling it.
> 
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
> Cc: Christoph Lameter <clameter@sgi.com>
> Cc: Rik van Riel <riel@redhat.com>
> 
> ---
> 
> diff --git a/Makefile b/Makefile
> diff --git a/mm/sparse.c b/mm/sparse.c
> index e06f514..d245e59 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -83,6 +83,8 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  		return -EEXIST;
> 
>  	section = sparse_index_alloc(nid);
> +	if (!section)
> +		return -ENOMEM;
>  	/*
>  	 * This lock keeps two different sections from
>  	 * reallocating for the same index

Oddly enough, sparse_add_one_section() doesn't seem to like to check
its allocations.  The usemap is checked, but not freed on error.  If you
want to fix this up, I think it needs a little more love than just two
lines.  

Do you want to try to add some actual error handling to
sparse_add_one_section()?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
