Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 54B7782F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 12:58:03 -0400 (EDT)
Received: by qkas79 with SMTP id s79so56959479qka.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 09:58:03 -0700 (PDT)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id l9si18687713qhl.13.2015.10.16.09.58.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 09:58:02 -0700 (PDT)
Received: by qkfm62 with SMTP id m62so54971865qkf.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 09:58:02 -0700 (PDT)
Message-ID: <56212c99.e615370a.1815a.7944@mx.google.com>
Date: Fri, 16 Oct 2015 09:58:01 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH] mm: skip if required_kernelcore is larger than
 totalpages
In-Reply-To: <561B0ECD.5000507@huawei.com>
References: <5615D311.5030908@huawei.com>
	<5617e00e.0c5b8c0a.2d0dd.3faa@mx.google.com>
	<561B0ECD.5000507@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, zhongjiang@huawei.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


On Mon, 12 Oct 2015 09:37:17 +0800
Xishi Qiu <qiuxishi@huawei.com> wrote:

> On 2015/10/9 23:41, Yasuaki Ishimatsu wrote:
> 
> > 
> > On Thu, 8 Oct 2015 10:21:05 +0800
> > Xishi Qiu <qiuxishi@huawei.com> wrote:
> > 
> >> If kernelcore was not specified, or the kernelcore size is zero
> >> (required_movablecore >= totalpages), or the kernelcore size is larger
> > 
> > Why does required_movablecore become larger than totalpages, when the
> > kernelcore size is zero? I read the code but I could not find that you
> > mention.
> > 
> 
> If user only set boot option movablecore, and the value is larger than
> totalpages, the calculation of kernelcore is zero, but we can't fill
> the zone only with kernelcore, so skip it.

Thank you for the explantion. Your patch looks good to me.

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

> 
> I have send a patch before this patch.
> "fix overflow in find_zone_movable_pfns_for_nodes()"
> 		...
>  		required_movablecore =
>  			roundup(required_movablecore, MAX_ORDER_NR_PAGES);
> +		required_movablecore = min(totalpages, required_movablecore);
>  		corepages = totalpages - required_movablecore;
> 		...
> 
> Thanks,
> Xishi Qiu
> 
> > Thanks,
> > Yasuaki Ishimatsu
> > 
> >> than totalpages, there is no ZONE_MOVABLE. We should fill the zone
> >> with both kernel memory and movable memory.
> >>
> >> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> >> ---
> >>  mm/page_alloc.c | 7 +++++--
> >>  1 file changed, 5 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index af3c9bd..6a6da0d 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -5674,8 +5674,11 @@ static void __init find_zone_movable_pfns_for_nodes(void)
> >>  		required_kernelcore = max(required_kernelcore, corepages);
> >>  	}
> >>  
> >> -	/* If kernelcore was not specified, there is no ZONE_MOVABLE */
> >> -	if (!required_kernelcore)
> >> +	/*
> >> +	 * If kernelcore was not specified or kernelcore size is larger
> >> +	 * than totalpages, there is no ZONE_MOVABLE.
> >> +	 */
> >> +	if (!required_kernelcore || required_kernelcore >= totalpages)
> >>  		goto out;
> >>  
> >>  	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
> >> -- 
> >> 2.0.0
> >>
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> > .
> > 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
