Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 2AC9F6B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 10:17:26 -0400 (EDT)
Date: Wed, 24 Apr 2013 10:17:19 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1366813039-3zmj9x71-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <517795E2.6070404@huawei.com>
References: <bug-56881-27@https.bugzilla.kernel.org/>
 <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
 <1366755995-no3omuhl-mutt-n-horiguchi@ah.jp.nec.com>
 <517795E2.6070404@huawei.com>
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com

On Wed, Apr 24, 2013 at 04:20:50PM +0800, Jianguo Wu wrote:
...
> Hi Naoya,
> 
> I think the -EINVAL is returned from hugetlb_get_unmapped_area(),
> for the two testcases:
> 1) $ ./mmappu $((5 * 2 * 1024 * 1024 - 4096))	//len1 = 0x9ff000
> 2) $ ./mmappu $((5 * 2 * 1024 * 1024 - 4095))	//len2 = 0x9ff001
> 
> In do_mmap_pgoff(), after "len = PAGE_ALIGN(len);", len1 = 0x9ff000,
> len2 = 0xa00000, so len2 will pass "if (len & ~huge_page_mask(h))" check in
> hugetlb_get_unmapped_area(), and len1 will return -EINVAL. As follow:
> 
> do_mmap_pgoff()
> {
> 	...
> 	/* Careful about overflows.. */
> 	len = PAGE_ALIGN(len);
> 	...
> 	get_unmapped_area()
> 		-->hugetlb_get_unmapped_area()
> 		   {
> 			...
> 			if (len & ~huge_page_mask(h))
> 				return -EINVAL;
> 			...
> 		   }
> }

You are right, Jianguo. Thanks you.
I totally missed the point.

> 
> do we need to align len to hugepage size if it's hugetlbfs mmap? something like below:
> 
> ---
>  mm/mmap.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 0db0de1..bd42be24 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1188,7 +1188,10 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>  		addr = round_hint_to_min(addr);
>  
>  	/* Careful about overflows.. */
> -	len = PAGE_ALIGN(len);
> +	if (file && is_file_hugepages(file))
> +		len = ALIGN(len, huge_page_size(hstate_file(file)));
> +	else
> +		len = PAGE_ALIGN(len);
>  	if (!len)
>  		return -ENOMEM;
>  
> -- 

I like putting this alignment code in if (flags & MAP_HUGETLB) branch in
SYSCALL_DEFINE6(mmap_pgoff) as Johannes pointed out in another subthread,
because it adds no impact on mmap calls with !MAP_HUGETLB.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
