Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC886B025E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 08:55:18 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so13588117wme.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 05:55:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si3044989wmc.19.2016.05.10.05.55.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 05:55:16 -0700 (PDT)
Subject: Re: [RFC 12/13] mm, compaction: more reliably increase direct
 compaction priority
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-13-git-send-email-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5731DA32.7090707@suse.cz>
Date: Tue, 10 May 2016 14:55:14 +0200
MIME-Version: 1.0
In-Reply-To: <1462865763-22084-13-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/10/2016 09:36 AM, Vlastimil Babka wrote:
>   	/*
> -	 * compaction considers all the zone as desperately out of memory
> -	 * so it doesn't really make much sense to retry except when the
> -	 * failure could be caused by insufficient priority
> +	 * Compaction backed off due to watermark checks for order-0
> +	 * so the regular reclaim has to try harder and reclaim something
> +	 * Retry only if it looks like reclaim might have a chance.
>   	 */
> -	if (compaction_failed(compact_result)) {
> -		if (*compact_priority > 0) {
> -			(*compact_priority)--;
> -			return true;
> -		}
> -		return false;
> -	}

Oops, looks like my editing resulted in compaction_failed() check to be
removed completely, which wasn't intentional and can lead to infinite
loops. This should be added on top.

----8<----
