Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id B063C6B0032
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 03:32:02 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id k11so28471905wes.2
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 00:32:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4si11484047wix.40.2015.01.31.00.32.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 31 Jan 2015 00:32:01 -0800 (PST)
Message-ID: <54CC92FD.5000601@suse.cz>
Date: Sat, 31 Jan 2015 09:31:57 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/4] mm/compaction: stop the isolation when we isolate
 enough freepage
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com> <1422621252-29859-3-git-send-email-iamjoonsoo.kim@lge.com> <BLU436-SMTP105DFBF63EAF672F3272FFA833E0@phx.gbl>
In-Reply-To: <BLU436-SMTP105DFBF63EAF672F3272FFA833E0@phx.gbl>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.ok@hotmail.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/31/2015 08:49 AM, Zhang Yanfei wrote:
> Hello,
> 
> At 2015/1/30 20:34, Joonsoo Kim wrote:
>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> 
> IMHO, the patch making the free scanner move slower makes both scanners
> meet further. Before this patch, if we isolate too many free pages and even 
> after we release the unneeded free pages later the free scanner still already
> be there and will be moved forward again next time -- the free scanner just
> cannot be moved back to grab the free pages we released before no matter where
> the free pages in, pcp or buddy. 

It can be actually moved back. If we are releasing free pages, it means the
current compaction is terminating, and it will set zone->compact_cached_free_pfn
back to the position of the released free page that was furthest back. The next
compaction will start from the cached free pfn.

It is however possible that another compaction runs in parallel and has
progressed further and overwrites the cached free pfn.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
