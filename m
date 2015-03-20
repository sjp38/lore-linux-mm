Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id E730A6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:49:37 -0400 (EDT)
Received: by wixw10 with SMTP id w10so27035350wix.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 06:49:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ua5si7067909wjc.197.2015.03.20.06.49.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 06:49:36 -0700 (PDT)
Message-ID: <550C256E.70507@suse.cz>
Date: Fri, 20 Mar 2015 14:49:34 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH][RFCv2] mm/compaction: reset compaction scanner positions
References: <1426743031-30096-1-git-send-email-gioh.kim@lge.com> <550A8BA9.9040005@suse.cz> <550A8E31.4040304@lge.com> <550A9086.3080508@suse.cz> <550B5CD1.5010306@lge.com> <550C19F6.9080408@lge.com>
In-Reply-To: <550C19F6.9080408@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, akpm@linux-foundation.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com

On 03/20/2015 02:00 PM, Gioh Kim wrote:
> I'm attaching the patch for discussion.
> According to Vlastimil's advice, I move the reseting before compact_zone(),
> and write more description.
>
> Vlastimil, can I have your name at Acked-by or Signed-off-by?

Yes. But note below that whitespace seems broken in the patch.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Which one do you prefer?

Acked-by, as Signed-off-by is for maintainers who resend the patches 
towards Linus.

> ------------------------- 8< ----------------------
>
>   From 575983c887e6478ca7cbba49a892dbc4cd69986b Mon Sep 17 00:00:00 2001
> From: Gioh Kim <gioh.kim@lge.com>
> Date: Fri, 20 Mar 2015 21:09:13 +0900
> Subject: [PATCH] [RFCv2] mm/compaction: reset compaction scanner positions
>
> When the compaction is activated via /proc/sys/vm/compact_memory
> it would better scan the whole zone.
> And some platform, for instance ARM, has the start_pfn of a zone as zero.
> Therefore the first try to compaction via /proc doesn't work.
> It needs to force to reset compaction scanner position at first.
>
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> ---
>    mm/compaction.c |    8 ++++++++
>    1 file changed, 8 insertions(+)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8c0d945..ccf48ce 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1587,6 +1587,14 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>                   INIT_LIST_HEAD(&cc->freepages);
>                   INIT_LIST_HEAD(&cc->migratepages);
>
> +               /*
> +                * When called via /proc/sys/vm/compact_memory
> +                * this makes sure we compact the whole zone regardless of
> +                * cached scanner positions.
> +                */
> +               if (cc->order == -1)
> +                       __reset_isolation_suitable(zone);

Indentation seems off, some tabs vs spaces issue?

> +
>                   if (cc->order == -1 || !compaction_deferred(zone, cc->order))
>                           compact_zone(zone, cc);
>
> --
> 1.7.9.5
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
