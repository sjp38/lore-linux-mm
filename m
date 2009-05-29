Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 17ED66B004D
	for <linux-mm@kvack.org>; Fri, 29 May 2009 00:15:46 -0400 (EDT)
Received: from mlsv4.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id 3B85037AC4
	for <linux-mm@kvack.org>; Fri, 29 May 2009 13:15:59 +0900 (JST)
Message-ID: <4A1F6166.4020006@hitachi.com>
Date: Fri, 29 May 2009 13:15:34 +0900
From: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [6/16] HWPOISON: Add basic support for poisoned pages in
    fault handler v2
References: <200905271012.668777061@firstfloor.org>
    <20090527201232.555281D0290@basil.firstfloor.org>
In-Reply-To: <20090527201232.555281D0290@basil.firstfloor.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> - Add a new VM_FAULT_HWPOISON error code to handle_mm_fault. Right now
> architectures have to explicitely enable poison page support, so
> this is forward compatible to all architectures. They only need
> to add it when they enable poison page support.
> - Add poison page handling in swap in fault code
> 
> v2: Add missing delayacct_clear_flag (Hidehiro Kawai)

[snip]

>  		goto out;
>  	}
>  	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> @@ -2484,6 +2492,10 @@
>  		/* Had to read the page from swap area: Major fault */
>  		ret = VM_FAULT_MAJOR;
>  		count_vm_event(PGMAJFAULT);
> +	} else if (PageHWPoison(page)) {
> +		ret = VM_FAULT_HWPOISON;
> +		delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> +		goto out;

Is this delayacct_clear_flag()? :-p

Regards,
-- 
Hidehiro Kawai
Hitachi, Systems Development Laboratory
Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
