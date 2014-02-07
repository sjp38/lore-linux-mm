Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0726C6B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 16:43:31 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id un15so3767554pbc.18
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 13:43:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ds4si6486105pbb.49.2014.02.07.13.43.30
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 13:43:30 -0800 (PST)
Date: Fri, 7 Feb 2014 13:43:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memory-failure.c: move refcount only in
 !MF_COUNT_INCREASED
Message-Id: <20140207134329.a305b169351a2538ab03785f@linux-foundation.org>
In-Reply-To: <52f54d29.89cfe00a.4277.4d3dSMTPIN_ADDED_BROKEN@mx.google.com>
References: <52f54d29.89cfe00a.4277.4d3dSMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 07 Feb 2014 16:16:04 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> # Resending due to sending failure. Sorry if you received twice.
> ---
> mce-test detected a test failure when injecting error to a thp tail page.
> This is because we take page refcount of the tail page in madvise_hwpoison()
> while the fix in commit a3e0f9e47d5e ("mm/memory-failure.c: transfer page
> count from head page to tail page after split thp") assumes that we always
> take refcount on the head page.
> 
> When a real memory error happens we take refcount on the head page where
> memory_failure() is called without MF_COUNT_INCREASED set, so it seems to me
> that testing memory error on thp tail page using madvise makes little sense.
> 
> This patch cancels moving refcount in !MF_COUNT_INCREASED for valid testing.
> 
> ...
>
> --- v3.14-rc1.orig/mm/memory-failure.c
> +++ v3.14-rc1/mm/memory-failure.c
> @@ -1042,8 +1042,10 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  			 * to it. Similarly, page lock is shifted.
>  			 */
>  			if (hpage != p) {
> -				put_page(hpage);
> -				get_page(p);
> +				if (!(flags && MF_COUNT_INCREASED)) {

s/&&/&/

Please carefully retest this, make sure that both cases are covered?

> +					put_page(hpage);
> +					get_page(p);
> +				}
>  				lock_page(p);
>  				unlock_page(hpage);
>  				*hpagep = p;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
