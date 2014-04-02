Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id 404F96B00A5
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 09:01:49 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id d7so36754bkh.0
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 06:01:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ti7si921185bkb.287.2014.04.02.06.01.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 06:01:47 -0700 (PDT)
Date: Wed, 2 Apr 2014 14:01:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch]x86: clearing access bit don't flush tlb
Message-ID: <20140402130143.GA1869@suse.de>
References: <20140326223034.GA31713@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140326223034.GA31713@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, mel@csn.ul.ie

On Thu, Mar 27, 2014 at 06:30:34AM +0800, Shaohua Li wrote:
> 
> I posted this patch a year ago or so, but it gets lost. Repost it here to check
> if we can make progress this time.
> 
> We use access bit to age a page at page reclaim. When clearing pte access bit,
> we could skip tlb flush in X86. The side effect is if the pte is in tlb and pte
> access bit is unset in page table, when cpu access the page again, cpu will not
> set page table pte's access bit. Next time page reclaim will think this hot
> page is old and reclaim it wrongly, but this doesn't corrupt data.
> 
> And according to intel manual, tlb has less than 1k entries, which covers < 4M
> memory. In today's system, several giga byte memory is normal. After page
> reclaim clears pte access bit and before cpu access the page again, it's quite
> unlikely this page's pte is still in TLB. And context swich will flush tlb too.
> The chance skiping tlb flush to impact page reclaim should be very rare.
> 
> Originally (in 2.5 kernel maybe), we didn't do tlb flush after clear access bit.
> Hugh added it to fix some ARM and sparc issues. Since I only change this for
> x86, there should be no risk.
> 
> And in some workloads, TLB flush overhead is very heavy. In my simple
> multithread app with a lot of swap to several pcie SSD, removing the tlb flush
> gives about 20% ~ 30% swapout speedup.
> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>

I'm aware of the discussion on the more complex version and the outcome
of that. While I think the corner case is real, I think it's also very
unlikely and as this is an x86-only thing which will be safe from
corruption at least;

Acked-by: Mel Gorman <mgorman@suse.de>

Shaohua, you almost certainly should resend this to Andrew with the
ack's you collected so that he does not have to dig into the history
trying to figure out what the exact story is.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
