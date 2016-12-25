Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 336166B0038
	for <linux-mm@kvack.org>; Sat, 24 Dec 2016 20:01:07 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j128so444441503pfg.4
        for <linux-mm@kvack.org>; Sat, 24 Dec 2016 17:01:07 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id r85si38702275pfr.254.2016.12.24.17.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Dec 2016 17:01:06 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id b1so5059585pgc.1
        for <linux-mm@kvack.org>; Sat, 24 Dec 2016 17:01:06 -0800 (PST)
Date: Sun, 25 Dec 2016 11:00:49 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 1/2] mm: Use owner_priv bit for PageSwapCache, valid
 when PageSwapBacked
Message-ID: <20161225110049.09dc48fc@roar.ozlabs.ibm.com>
In-Reply-To: <alpine.LSU.2.11.1612221130520.4215@eggly.anvils>
References: <20161221151951.16396-1-npiggin@gmail.com>
	<20161221151951.16396-2-npiggin@gmail.com>
	<alpine.LSU.2.11.1612221130520.4215@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, swhiteho@redhat.com, luto@kernel.org, agruenba@redhat.com, peterz@infradead.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>

On Thu, 22 Dec 2016 11:55:28 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Thu, 22 Dec 2016, Nicholas Piggin wrote:
> 
> I agree with every word of that changelog ;)
> 
> And I'll stamp this with
> Acked-by: Hugh Dickins <hughd@google.com>

Thanks Hugh.
 
> The thing that Peter remembers I commented on (which 0day caught too),
> was to remove PG_swapcache from PAGE_FLAGS_CHECK_AT_FREE: you've done
> that now, so this is good.  (Note in passing: wouldn't it be good to
> add PG_waiters to PAGE_FLAGS_CHECK_AT_FREE in the 2/2?)
> 
> Though I did yesterday notice a few more problematic uses of
> PG_swapcache, which you'll probably need to refine to exclude
> other uses of PG_owner_priv_1; though no great hurry for those,
> so not necessarily in this same patch.  Do your own grep, but
> 
> fs/proc/page.c derives its KPF_SWAPCACHE from PG_swapcache,
> needs refining.
> 
> kernel/kexec_core.c says VMCOREINFO_NUMBER(PG_swapcache):
> I haven't looked into what that's about, it will probably just
> have to be commented as now including other uses of the same bit.
> 
> mm/memory-failure.c has an error_states[] table that involves
> testing PG_swapcache as "sc", but looks as if it can be changed
> to factor in "swapbacked" too.

I've added the swapbacked check to mm/memory-failure.c, the others look
like they're just dealing with bit number, so not much to do about it
really. I also just made the migration case more explicit, seeing as the
others are.

Hopefully that doesn't negate your ack because I'm adding that too.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
