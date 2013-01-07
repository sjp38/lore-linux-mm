Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 8EB276B0070
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 10:14:57 -0500 (EST)
Message-ID: <50EAE66B.1020804@redhat.com>
Date: Mon, 07 Jan 2013 10:14:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC]x86: clearing access bit don't flush tlb
References: <20130107081213.GA21779@kernel.org>
In-Reply-To: <20130107081213.GA21779@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mingo@redhat.com, hpa@zytor.com

On 01/07/2013 03:12 AM, Shaohua Li wrote:
>
> We use access bit to age a page at page reclaim. When clearing pte access bit,
> we could skip tlb flush for the virtual address. The side effect is if the pte
> is in tlb and pte access bit is unset, when cpu access the page again, cpu will
> not set pte's access bit. So next time page reclaim can reclaim hot pages
> wrongly, but this doesn't corrupt anything. And according to intel manual, tlb
> has less than 1k entries, which coverers < 4M memory. In today's system,
> several giga byte memory is normal. After page reclaim clears pte access bit
> and before cpu access the page again, it's quite unlikely this page's pte is
> still in TLB. Skiping the tlb flush for this case sounds ok to me.

Agreed. In current systems, it can take a minute to write
all of memory to disk, while context switch (natural TLB
flush) times are in the dozens-of-millisecond timeframes.

> And in some workloads, TLB flush overhead is very heavy. In my simple
> multithread app with a lot of swap to several pcie SSD, removing the tlb flush
> gives about 20% ~ 30% swapout speedup.
>
> Signed-off-by: Shaohua Li <shli@fusionio.com>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
