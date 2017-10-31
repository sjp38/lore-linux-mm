Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 33F856B0033
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 04:35:01 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l24so16184763pgu.17
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 01:35:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b35si1024521plh.46.2017.10.31.01.34.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 01:34:59 -0700 (PDT)
Subject: Re: [PATCH RFC v2 1/4] mm/mempolicy: Fix get_nodes() mask
 miscalculation
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
 <1509099265-30868-2-git-send-email-xieyisheng1@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <922a4767-9eed-40aa-c437-6f6fcdcab150@suse.cz>
Date: Tue, 31 Oct 2017 09:34:54 +0100
MIME-Version: 1.0
In-Reply-To: <1509099265-30868-2-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On 10/27/2017 12:14 PM, Yisheng Xie wrote:
> It appears there is a nodemask miscalculation in the get_nodes()
> function in mm/mempolicy.c.  This bug has two effects:
> 
> 1. It is impossible to specify a length 1 nodemask.
> 2. It is impossible to specify a nodemask containing the last node.

This should be more specific, which syscalls are you talking about?
I assume it's set_mempolicy() and mbind() and it's the same issue that
was discussed at https://marc.info/?l=linux-mm&m=150732591909576&w=2 ?

> Brent have submmit a patch before v2.6.12, however, Andi revert his
> changed for ABI problem. I just resent this patch as RFC, for do not
> clear about what's the problem Andi have met.

You should have CC'd Andi. As was discussed in the other thread, this
would make existing programs potentially unsafe, so we can't change it.
Instead it should be documented.

> As manpage of set_mempolicy, If the value of maxnode is zero, the
> nodemask argument is ignored. but we should not ignore the nodemask
> when maxnode is 1.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> ---
>  mm/mempolicy.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index a2af6d5..613e9d0 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1265,7 +1265,6 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
>  	unsigned long nlongs;
>  	unsigned long endmask;
>  
> -	--maxnode;
>  	nodes_clear(*nodes);
>  	if (maxnode == 0 || !nmask)
>  		return 0;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
