Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F313F6B0394
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 21:28:57 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e5so64779001pgk.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 18:28:57 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w187si3637515pgb.130.2017.03.15.18.28.55
        for <linux-mm@kvack.org>;
        Wed, 15 Mar 2017 18:28:56 -0700 (PDT)
Date: Thu, 16 Mar 2017 10:30:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 2/8] mm, compaction: remove redundant watermark check
 in compact_finished()
Message-ID: <20170316013018.GA14063@js1304-P5Q-DELUXE>
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170307131545.28577-3-vbabka@suse.cz>
MIME-Version: 1.0
In-Reply-To: <20170307131545.28577-3-vbabka@suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, kernel-team@lge.com

Hello,

On Tue, Mar 07, 2017 at 02:15:39PM +0100, Vlastimil Babka wrote:
> When detecting whether compaction has succeeded in forming a high-order page,
> __compact_finished() employs a watermark check, followed by an own search for
> a suitable page in the freelists. This is not ideal for two reasons:
> 
> - The watermark check also searches high-order freelists, but has a less strict
>   criteria wrt fallback. It's therefore redundant and waste of cycles. This was
>   different in the past when high-order watermark check attempted to apply
>   reserves to high-order pages.

Although it looks redundant now, I don't like removal of the watermark
check here. Criteria in watermark check would be changed to more strict
later and we would easily miss to apply it on compaction side if the
watermark check is removed.

> 
> - The watermark check might actually fail due to lack of order-0 pages.
>   Compaction can't help with that, so there's no point in continuing because of
>   that. It's possible that high-order page still exists and it terminates.

If lack of order-0 pages is the reason for stopping compaction, we
need to insert the watermark check for order-0 to break the compaction
instead of removing it. Am I missing something?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
