Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f173.google.com (mail-gg0-f173.google.com [209.85.161.173])
	by kanga.kvack.org (Postfix) with ESMTP id 568106B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 22:33:10 -0500 (EST)
Received: by mail-gg0-f173.google.com with SMTP id q4so487352ggn.32
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 19:33:10 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l26si17275519yhg.237.2013.12.17.19.33.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 19:33:09 -0800 (PST)
Message-ID: <52B11765.8030005@oracle.com>
Date: Tue, 17 Dec 2013 22:32:53 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com> <52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com> <20131218032329.GA6044@hacker.(null)>
In-Reply-To: <20131218032329.GA6044@hacker.(null)>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, Bob Liu <bob.liu@oracle.com>, npiggin@suse.de, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/17/2013 10:23 PM, Wanpeng Li wrote:
> -			mlock_vma_page(page);   /* no-op if already mlocked */
> -			if (page == check_page)
> +			if (page != check_page && trylock_page(page)) {
> +				mlock_vma_page(page);   /* no-op if already mlocked */
> +				unlock_page(page);
> +			} else if (page == check_page) {
> +				mlock_vma_page(page);  /* no-op if already mlocked */
>   				ret = SWAP_MLOCK;
> +			}

Previously, if page != check_page and the page was locked, we'd call mlock_vma_page()
anyways. With this change, we don't. In fact, we'll just skip that entire block not doing
anything.

If that's something that's never supposed to happen, can we add a

	VM_BUG_ON(page != check_page && PageLocked(page))

Just to cover this new code path?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
