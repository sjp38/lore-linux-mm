Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 944AC6B0032
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:38:57 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so6878022pde.37
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 03:38:57 -0700 (PDT)
Message-ID: <5239829F.4080601@t-online.de>
Date: Wed, 18 Sep 2013 12:38:23 +0200
From: Knut Petersen <Knut_Petersen@t-online.de>
MIME-Version: 1.0
Subject: Re: [Intel-gfx] [PATCH] [RFC] mm/shrinker: Add a shrinker flag to
 always shrink a bit
References: <1379495401-18279-1-git-send-email-daniel.vetter@ffwll.ch>
In-Reply-To: <1379495401-18279-1-git-send-email-daniel.vetter@ffwll.ch>
Content-Type: multipart/mixed;
 boundary="------------090302000909020209030900"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

This is a multi-part message in MIME format.
--------------090302000909020209030900
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

On 18.09.2013 11:10, Daniel Vetter wrote:

Just now I prepared a patch changing the same function in vmscan.c
> Also, this needs to be rebased to the new shrinker api in 3.12, I
> simply haven't rolled my trees forward yet.

Well, you should. Since commit 81e49f  shrinker->count_objects might be
set to SHRINK_STOP, causing shrink_slab_node() to complain loud and often:

[ 1908.234595] shrink_slab: i915_gem_inactive_scan+0x0/0x9c negative objects to delete nr=-xxxxxxxxx

The kernel emitted a few thousand log lines like the one quoted above during the
last few days on my system.

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2cff0d4..d81f6e0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -254,6 +254,10 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>   			total_scan = max_pass;
>   		}
>   
> +		/* Always try to shrink a bit to make forward progress. */
> +		if (shrinker->evicts_to_page_lru)
> +			total_scan = max_t(long, total_scan, batch_size);
> +
At that place the error message is already emitted.
>   		/*
>   		 * We need to avoid excessive windup on filesystem shrinkers
>   		 * due to large numbers of GFP_NOFS allocations causing the

Have a look at the attached patch. It fixes my problem with the erroneous/misleading
error messages, and I think it's right to just bail out early if SHRINK_STOP is found.

Do you agree ?

cu,
  Knut


--------------090302000909020209030900
Content-Type: text/x-patch;
 name="0001-mm-respect-SHRINK_STOP-in-shrink_slab_node.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-mm-respect-SHRINK_STOP-in-shrink_slab_node.patch"


--------------090302000909020209030900--
