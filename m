Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D339E6B007E
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 01:44:22 -0400 (EDT)
Received: by mail-qw0-f41.google.com with SMTP id 26so3394345qwa.14
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 22:44:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1311059367.15392.299.camel@sli10-conroe>
References: <1311059367.15392.299.camel@sli10-conroe>
Date: Wed, 20 Jul 2011 14:44:21 +0900
Message-ID: <CAEwNFnD2FcvSgPcEkQxVQ3X=Vhh4MTCXJzJ9Y8e78HkQuxbSjw@mail.gmail.com>
Subject: Re: [PATCH]vmscan: fix a livelock in kswapd
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Tue, Jul 19, 2011 at 4:09 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> I'm running a workload which triggers a lot of swap in a machine with 4 nodes.
> After I kill the workload, I found a kswapd livelock. Sometimes kswapd3 or
> kswapd2 are keeping running and I can't access filesystem, but most memory is
> free. This looks like a regression since commit 08951e545918c159.
> Node 2 and 3 have only ZONE_NORMAL, but balance_pgdat() will return 0 for
> classzone_idx. The reason is end_zone in balance_pgdat() is 0 by default, if
> all zones have watermark ok, end_zone will keep 0.
> Later sleeping_prematurely() always returns true. Because this is an order 3
> wakeup, and if classzone_idx is 0, both balanced_pages and present_pages
> in pgdat_balanced() are 0.
> We add a special case here. If a zone has no page, we think it's balanced. This
> fixes the livelock.
>
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
