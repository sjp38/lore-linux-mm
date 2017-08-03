Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86EEE6B0671
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 04:10:02 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v102so980706wrb.2
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 01:10:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9si1111300wrc.19.2017.08.03.01.10.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 01:10:01 -0700 (PDT)
Subject: Re: [PATCH] mm/vmstat: fix divide error at __fragmentation_index
References: <1501747181-30322-1-git-send-email-wen.yang99@zte.com.cn>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1f3450b4-a48c-bac6-19ee-c0f5b4d4ce86@suse.cz>
Date: Thu, 3 Aug 2017 10:09:59 +0200
MIME-Version: 1.0
In-Reply-To: <1501747181-30322-1-git-send-email-wen.yang99@zte.com.cn>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Yang <wen.yang99@zte.com.cn>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, jiang.biao2@zte.com.cn

Hi,

On 08/03/2017 09:59 AM, Wen Yang wrote:
> From: Jiang Biao <jiang.biao2@zte.com.cn>
> 
> When order is -1 or too big, *1UL << order* will be 0, which will
> cause divide error like this,
> 
>     divide error: 0000 [#1] SMP
>     Call Trace:
>      [<ffffffff81168423>] compaction_suitable+0x63/0xc0
>      [<ffffffff81168a75>] compact_zone+0x35/0x950
>      [<ffffffff811745b5>] ? free_percpu+0xb5/0x140
>      [<ffffffff81092b23>] ? schedule_on_each_cpu+0x133/0x160
>      [<ffffffff8116949c>] compact_node+0x10c/0x120
>      [<ffffffff8116953c>] sysctl_compaction_handler+0x5c/0x90
>      [<ffffffff811fa517>] proc_sys_call_handler+0x97/0xd0
>      [<ffffffff811fa564>] proc_sys_write+0x14/0x20
>      [<ffffffff81187368>] vfs_write+0xb8/0x1a0
>      [<ffffffff81187c61>] sys_write+0x51/0x90
>      [<ffffffff8100b052>] system_call_fastpath+0x16/0x1b

The trace seems to be from an old and non-mainline kernel, as it's the
same as you reported here:

https://bugzilla.kernel.org/show_bug.cgi?id=196555

In current mainline it seems to me that all callers of
__fragmentation_index() will only do so with a valid order.

I wouldn't mind making a non-hotpath code more robust, but probably in a
more obvious and self-reporting/documented way e.g. something like

if (WARN_ON_ONCE(order >= MAX_ORDER))
	return 0;

> Signed-off-by: Wen Yang <wen.yang99@zte.com.cn>
> Reviewed-by: Jiang Biao <jiang.biao2@zte.com.cn>
> ---
>  mm/vmstat.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 76f7367..2f9d012 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -870,6 +870,9 @@ static int __fragmentation_index(unsigned int order, struct contig_page_info *in
>  {
>  	unsigned long requested = 1UL << order;
>  
> +        if (!requested)
> +                return 0;

Seems the indentation is broken here (spaces vs tabs).

Thanks,
Vlastimil

> +
>  	if (!info->free_blocks_total)
>  		return 0;
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
