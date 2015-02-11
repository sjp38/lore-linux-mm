Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D39476B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 16:09:07 -0500 (EST)
Received: by pdjg10 with SMTP id g10so6858836pdj.1
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 13:09:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bz1si2194619pbb.244.2015.02.11.13.09.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 13:09:06 -0800 (PST)
Date: Wed, 11 Feb 2015 13:09:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix negative nr_isolated counts
Message-Id: <20150211130905.4b0d1809b0689ffd6e83d851@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1502102303040.13607@eggly.anvils>
References: <alpine.LSU.2.11.1502102303040.13607@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, 10 Feb 2015 23:06:09 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:

> The vmstat interfaces are good at hiding negative counts (at least
> when CONFIG_SMP); but if you peer behind the curtain, you find that
> nr_isolated_anon and nr_isolated_file soon go negative, and grow ever
> more negative: so they can absorb larger and larger numbers of isolated
> pages, yet still appear to be zero.
> 
> I'm happy to avoid a congestion_wait() when too_many_isolated() myself;
> but I guess it's there for a good reason, in which case we ought to get
> too_many_isolated() working again.
> 
> The imbalance comes from isolate_migratepages()'s ISOLATE_ABORT case:
> putback_movable_pages() decrements the NR_ISOLATED counts, but we forgot
> to call acct_isolated() to increment them.

So if I'm understanding this correctly, shrink_inactive_list()'s call
to congestion_wait() basically never happens?

If so I'm pretty reluctant to merge this up until it has had plenty of
careful testing - there's a decent chance that it will make the kernel
behave worse.

> Fixes: edc2ca612496 ("mm, compaction: move pageblock checks up from isolate_migratepages_range()")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org # v3.18+

And why -stable?  What user-visible problem is the bug causing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
