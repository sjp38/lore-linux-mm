Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E81C280245
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 03:18:06 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y62so655992pfd.3
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 00:18:06 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTPS id r39si1972939pld.128.2018.01.04.00.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 00:18:05 -0800 (PST)
Subject: Re: [PATCH] mm/fadvise: discard partial pages iff endbyte is also eof
References: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
 <8DAEE48B-AD5D-4702-AB4B-7102DD837071@alibaba-inc.com>
 <20180103104800.xgqe32hv63xsmsjh@techsingularity.net>
 <20180103161753.8b22d32d640f6e0be4119081@linux-foundation.org>
From: "=?UTF-8?B?5aS35YiZKENhc3Bhcik=?=" <jinli.zjl@alibaba-inc.com>
Message-ID: <be7778b9-58de-3717-0da5-e88fc5ec5542@alibaba-inc.com>
Date: Thu, 04 Jan 2018 16:17:50 +0800
MIME-Version: 1.0
In-Reply-To: <20180103161753.8b22d32d640f6e0be4119081@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: green@linuxhacker.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?B?5p2o5YuHKOaZuuW9uyk=?= <zhiche.yy@alibaba-inc.com>, =?UTF-8?B?5Y2B5YiA?= <shidao.ytt@alibaba-inc.com>



On 2018/1/4 08:17, Andrew Morton wrote:
> On Wed, 3 Jan 2018 10:48:00 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
>> On Wed, Jan 03, 2018 at 02:53:43PM +0800, ??????(Caspar) wrote:
>>>
>>>
>>>> ?? 2017??12??23????12:16?????? <shidao.ytt@alibaba-inc.com> ??????
>>>>
>>>> From: "shidao.ytt" <shidao.ytt@alibaba-inc.com>
>>>>
>>>> in commit 441c228f817f7 ("mm: fadvise: document the
>>>> fadvise(FADV_DONTNEED) behaviour for partial pages") Mel Gorman
>>>> explained why partial pages should be preserved instead of discarded
>>>> when using fadvise(FADV_DONTNEED), however the actual codes to calcuate
>>>> end_index was unexpectedly wrong, the code behavior didn't match to the
>>>> statement in comments; Luckily in another commit 18aba41cbf
>>>> ("mm/fadvise.c: do not discard partial pages with POSIX_FADV_DONTNEED")
>>>> Oleg Drokin fixed this behavior
>>>>
>>>> Here I come up with a new idea that actually we can still discard the
>>>> last parital page iff the page-unaligned endbyte is also the end of
>>>> file, since no one else will use the rest of the page and it should be
>>>> safe enough to discard.
>>>
>>> +akpm...
>>>
>>> Hi Mel, Andrew:
>>>
>>> Would you please take a look at this patch, to see if this proposal
>>> is reasonable enough, thanks in advance!
>>>
>>
>> I'm backlogged after being out for the Christmas. Superficially the patch
>> looks ok but I wondered how often it happened in practice as we already
>> would discard files smaller than a page on DONTNEED. It also requires
>> that the system call get the exact size of the file correct and would not
>> discard if the off + len was past the end of the file for whatever reason
>> (e.g. a stat to read the size, a truncate in parallel and fadvise using
>> stale data from stat) and that's why the patch looked like it might have
>> no impact in practice. Is the patch known to help a real workload or is
>> it motivated by a code inspection?
> 
> The current whole-pages-only logic was introduced (accidentally, I
> think) by yours truly when fixing a bug in the initial fadvise()
> commit in 2003.
> 
> https://kernel.opensuse.org/cgit/kernel/commit/?h=v2.6.0-test4&id=7161ee20fea6e25a32feb91503ca2b7c7333c886
> 
> Namely:
> 
> : invalidate_mapping_pages() takes start/end, but fadvise is currently passing
> : it start/len.
> :
> :
> :
> :  mm/fadvise.c |    8 ++++++--
> :  1 files changed, 6 insertions(+), 2 deletions(-)
> :
> : diff -puN mm/fadvise.c~fadvise-fix mm/fadvise.c
> : --- 25/mm/fadvise.c~fadvise-fix	2003-08-14 18:16:12.000000000 -0700
> : +++ 25-akpm/mm/fadvise.c	2003-08-14 18:16:12.000000000 -0700
> : @@ -26,6 +26,8 @@ long sys_fadvise64(int fd, loff_t offset
> :  	struct inode *inode;
> :  	struct address_space *mapping;
> :  	struct backing_dev_info *bdi;
> : +	pgoff_t start_index;
> : +	pgoff_t end_index;
> :  	int ret = 0;
> :
> :  	if (!file)
> : @@ -65,8 +67,10 @@ long sys_fadvise64(int fd, loff_t offset
> :  	case POSIX_FADV_DONTNEED:
> :  		if (!bdi_write_congested(mapping->backing_dev_info))
> :  			filemap_flush(mapping);
> : -		invalidate_mapping_pages(mapping, offset >> PAGE_CACHE_SHIFT,
> : -				(len >> PAGE_CACHE_SHIFT) + 1);
> : +		start_index = offset >> PAGE_CACHE_SHIFT;
> : +		end_index = (offset + len + PAGE_CACHE_SIZE - 1) >>
> : +						PAGE_CACHE_SHIFT;
> : +		invalidate_mapping_pages(mapping, start_index, end_index);
> :  		break;
> :  	default:
> :  		ret = -EINVAL;
> :
> 
> So I'm not sure that the whole "don't discard partial pages" thing is
> well-founded and I see no reason why we cannot alter it.
> 
> So, thinking caps on: why not just discard them?  After all, that's
> what userspace asked us to do.

Hi Andrew, I doubt if "just discard them" is a proper action to match 
the userspace's expectation. Maybe we will never meet the userspace's 
expectation since we are doing pages in kernel while userspace is 
passing bytes offset/length to the kernel. Note that Mel Gorman has 
already documented page-unaligned behaviors in posix_fadvise() man 
page[1] but obviously not all people (including /me) are able to read 
the _latest_ version, so someone might still uses the syscall with page 
unaligned offset/length. The userspace might only ask for discarding 
certain *bytes*, instead of *pages*.

And I think we need to look back first why we thought "preserved is 
better than discard". If we throw the whole page, the rest part of the 
page might still be required (consider the offset and length is in the 
middle of a file) because it's untagged:

   ...|------------ PAGE --------------|...
   ...| DONTNEED |------ UNTAGGED -----|...

but the page has gone, page fault occurs and we need to reload it from 
the disk -- performance degradation happens.

Maybe that's why we would rather preserv the whole page before.

But if we don't throw the partial page at all, and if the tail partial 
page is _exactly the end of the file_, a page that advised to be NONEED 
would be left in memory. And we all know that it is safe to throw it.

So we come up with this patch -- to keep the partial page not been 
throwing away, and add a special case when the partial page is the end 
of the file, we can throw it safely. I guess it might be a better solution.

One thing I'm worrying about is that, this patch might lead to a new 
undocumented behavior, so maybe we need to document this special case in 
posix_fadvise() man page too? hmmm...

Thanks,
Caspar


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
