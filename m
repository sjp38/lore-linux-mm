Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC1A6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 16:28:18 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so5095197pab.5
        for <linux-mm@kvack.org>; Mon, 12 May 2014 13:28:17 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id gd2si6877733pbd.33.2014.05.12.13.28.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 13:28:17 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so9282206pab.7
        for <linux-mm@kvack.org>; Mon, 12 May 2014 13:28:17 -0700 (PDT)
Date: Mon, 12 May 2014 13:28:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, compaction: properly signal and act upon lock and
 need_sched() contention
In-Reply-To: <1399904111-23520-1-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.02.1405121326080.961@chino.kir.corp.google.com>
References: <20140508051747.GA9161@js1304-P5Q-DELUXE> <1399904111-23520-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Mon, 12 May 2014, Vlastimil Babka wrote:

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 83ca6f9..b34ab7c 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -222,6 +222,27 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>  	return true;
>  }
>  
> +/*
> + * Similar to compact_checklock_irqsave() (see its comment) for places where
> + * a zone lock is not concerned.
> + *
> + * Returns false when compaction should abort.
> + */

I think we should have some sufficient commentary in the code that 
describes why we do this.

> +static inline bool compact_check_resched(struct compact_control *cc)
> +{

I'm not sure that compact_check_resched() is the appropriate name.  Sure, 
it specifies what the current implementation is, but what it's really 
actually doing is determining when compaction should abort prematurely.

Something like compact_should_abort()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
