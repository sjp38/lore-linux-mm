Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 269416B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 20:04:33 -0500 (EST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 5 Jan 2013 06:33:17 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id BD99FE004D
	for <linux-mm@kvack.org>; Sat,  5 Jan 2013 06:34:31 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0514Kix46465152
	for <linux-mm@kvack.org>; Sat, 5 Jan 2013 06:34:20 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0514LRa029427
	for <linux-mm@kvack.org>; Sat, 5 Jan 2013 12:04:22 +1100
Date: Sat, 5 Jan 2013 09:04:20 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] mm: memblock: fix wrong memmove size in
 memblock_merge_regions()
Message-ID: <20130105010420.GA26319@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1357290650-25544-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357290650-25544-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, tj@kernel.org, mingo@kernel.org, yinghai@kernel.org, benh@kernel.crashing.org, tangchen@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 04, 2013 at 05:10:50PM +0800, Lin Feng wrote:
>The memmove span covers from (next+1) to the end of the array, and the index
>of next is (i+1), so the index of (next+1) is (i+2). So the size of remaining
>array elements is (type->cnt - (i + 2)).
>

Make sense.

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>PS. It seems that memblock_merge_regions() could be made some improvement:
>we need't memmove the remaining array elements until we find a none-mergable
>element, but now we memmove everytime we find a neighboring compatible region.
>I'm not sure if the trial is worth though.
>
>Cc: Tejun Heo <tj@kernel.org>
>Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
>---
> mm/memblock.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/mm/memblock.c b/mm/memblock.c
>index 6259055..85ce056 100644
>--- a/mm/memblock.c
>+++ b/mm/memblock.c
>@@ -314,7 +314,7 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
> 		}
>
> 		this->size += next->size;
>-		memmove(next, next + 1, (type->cnt - (i + 1)) * sizeof(*next));
>+		memmove(next, next + 1, (type->cnt - (i + 2)) * sizeof(*next));
> 		type->cnt--;
> 	}
> }
>-- 
>1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
