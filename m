Message-ID: <462932BE.4020005@redhat.com>
Date: Fri, 20 Apr 2007 17:38:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com> <20070420135715.f6e8e091.akpm@linux-foundation.org>
In-Reply-To: <20070420135715.f6e8e091.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> I've also merged Nick's "mm: madvise avoid exclusive mmap_sem".
> 
> - Nick's patch also will help this problem.  It could be that your patch
>   no longer offers a 2x speedup when combined with Nick's patch.
> 
>   It could well be that the combination of the two is even better, but it
>   would be nice to firm that up a bit.  

I'll test that.

>   I do go on about that.  But we're adding page flags at about one per
>   year, and when we run out we're screwed - we'll need to grow the
>   pageframe.

If you want, I can take a look at folding this into the
->mapping pointer.  I can guarantee you it won't be
pretty, though :)

> - I need to update your patch for Nick's patch.  Please confirm that
>   down_read(mmap_sem) is sufficient for MADV_FREE.

It is.  MADV_FREE needs no more protection than MADV_DONTNEED.

> Stylistic nit:
> 
>> +	if (PageLazyFree(page) && !migration) {
>> +		/* There is new data in the page.  Reinstate it. */
>> +		if (unlikely(pte_dirty(pteval))) {
>> +			set_pte_at(mm, address, pte, pteval);
>> +			ret = SWAP_FAIL;
>> +			goto out_unmap;
>> +		}
> 
> The comment should be inside the second `if' statement.  As it is, It
> looks like we reinstate the page if (PageLazyFree(page) && !migration).

Want me to move it?

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
