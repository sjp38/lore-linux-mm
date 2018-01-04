Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 614C56B04D7
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 05:05:58 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id q12so622534wrg.13
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 02:05:58 -0800 (PST)
Received: from outbound-smtp23.blacknight.com (outbound-smtp23.blacknight.com. [81.17.249.191])
        by mx.google.com with ESMTPS id j1si227428ede.363.2018.01.04.02.05.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Jan 2018 02:05:56 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp23.blacknight.com (Postfix) with ESMTPS id 99B7AB8A45
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 10:05:56 +0000 (GMT)
Date: Thu, 4 Jan 2018 10:05:53 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm/fadvise: discard partial pages iff endbyte is also eof
Message-ID: <20180104094513.46dhslsphmh2a462@techsingularity.net>
References: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
 <8DAEE48B-AD5D-4702-AB4B-7102DD837071@alibaba-inc.com>
 <20180103104800.xgqe32hv63xsmsjh@techsingularity.net>
 <20180103161753.8b22d32d640f6e0be4119081@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180103161753.8b22d32d640f6e0be4119081@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "??????(Caspar)" <jinli.zjl@alibaba-inc.com>, green@linuxhacker.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "??????(??????)" <zhiche.yy@alibaba-inc.com>, ?????? <shidao.ytt@alibaba-inc.com>

On Wed, Jan 03, 2018 at 04:17:53PM -0800, Andrew Morton wrote:
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
> 

We could, it just means that any application that accidentally discards
hot data due to an unaligned fadvise will incur more IO. We've no idea
how many, if any applications, do this.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
