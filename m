Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id D6BF36B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 06:05:14 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 29 Feb 2012 11:55:58 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1TAxUn73579924
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 21:59:32 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1TB4vBX006665
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 22:04:57 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] hugetlbfs: Add new rw_semaphore to fix truncate/read race
In-Reply-To: <CAJd=RBA05LqrUohAfO43ywZR_xwi4KygpzZP2zun=taKTLCvnQ@mail.gmail.com>
References: <1330280398-27956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120227151135.7d4076c6.akpm@linux-foundation.org> <87ipirclhe.fsf@linux.vnet.ibm.com> <CAJd=RBA05LqrUohAfO43ywZR_xwi4KygpzZP2zun=taKTLCvnQ@mail.gmail.com>
Date: Wed, 29 Feb 2012 16:34:46 +0530
Message-ID: <87ty29ew8h.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, hughd@google.com, linux-kernel@vger.kernel.org

On Tue, 28 Feb 2012 20:17:28 +0800, Hillf Danton <dhillf@gmail.com> wrote:
> On Tue, Feb 28, 2012 at 6:15 PM, Aneesh Kumar K.V
> <aneesh.kumar@linux.vnet.ibm.com> wrote:
> >
> > Will update the patch with these details
> >
> 
> A scratch is cooked, based on the -next tree, for accelerating your redelivery,
> if you like it, in which i_mutex is eliminated directly and page lock is used.
> 
> -hd


This looks much better than what I had. 

> 
> 
> --- a/fs/hugetlbfs/inode.c	Tue Feb 28 19:43:32 2012
> +++ b/fs/hugetlbfs/inode.c	Tue Feb 28 19:56:50 2012
> @@ -245,17 +245,10 @@ static ssize_t hugetlbfs_read(struct fil
>  	loff_t isize;
>  	ssize_t retval = 0;
> 
> -	mutex_lock(&inode->i_mutex);
> -
>  	/* validate length */
>  	if (len == 0)
>  		goto out;
> 
> -	isize = i_size_read(inode);
> -	if (!isize)
> -		goto out;
> -
> -	end_index = (isize - 1) >> huge_page_shift(h);
>  	for (;;) {
>  		struct page *page;
>  		unsigned long nr, ret;
> @@ -263,6 +256,8 @@ static ssize_t hugetlbfs_read(struct fil
> 
>  		/* nr is the maximum number of bytes to copy from this page */
>  		nr = huge_page_size(h);
> +		isize = i_size_read(inode);
> +		end_index = isize >> huge_page_shift(h);


Should that be (isize - 1) >> huget_page_shift(h) ?


>  		if (index >= end_index) {
>  			if (index > end_index)
>  				goto out;
> @@ -274,7 +269,7 @@ static ssize_t hugetlbfs_read(struct fil
>  		nr = nr - offset;
> 
>  		/* Find the page */
> -		page = find_get_page(mapping, index);
> +		page = find_lock_page(mapping, index);
>  		if (unlikely(page == NULL)) {
>  			/*
>  			 * We have a HOLE, zero out the user-buffer for the
> @@ -286,17 +281,30 @@ static ssize_t hugetlbfs_read(struct fil
>  			else
>  				ra = 0;
>  		} else {
> +			unlock_page(page);
> +
> +			/* Without i_mutex held, check isize again */
> +			nr = huge_page_size(h);
> +			isize = i_size_read(inode);
> +			end_index = isize >> huge_page_shift(h);

same here (isize - 1) ?

> +			if (index == end_index) {
> +				nr = isize & ~huge_page_mask(h);


Is that correct ?  We calculate nr differently in the earlier part of the function

> +				if (nr <= offset) {
> +					page_cache_release(page);
> +					goto out;
> +				}
> +			}
> +			nr -= offset;
>  			/*
>  			 * We have the page, copy it to user space buffer.
>  			 */
>  			ra = hugetlbfs_read_actor(page, offset, buf, len, nr);
>  			ret = ra;
> +			page_cache_release(page);
>  		}
>  		if (ra < 0) {
>  			if (retval == 0)
>  				retval = ra;
> -			if (page)
> -				page_cache_release(page);
>  			goto out;
>  		}
> 
> @@ -306,16 +314,12 @@ static ssize_t hugetlbfs_read(struct fil
>  		index += offset >> huge_page_shift(h);
>  		offset &= ~huge_page_mask(h);
> 
> -		if (page)
> -			page_cache_release(page);
> -
>  		/* short read or no more work */
>  		if ((ret != nr) || (len == 0))
>  			break;
>  	}
>  out:
>  	*ppos = ((loff_t)index << huge_page_shift(h)) + offset;
> -	mutex_unlock(&inode->i_mutex);
>  	return retval;
>  }
> 

I guess we need to closely look at the patch with respect to end-of-file
condition. I will also try to get some testing with the patch.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
