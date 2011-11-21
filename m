Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BA7756B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 16:57:55 -0500 (EST)
Message-ID: <4ECAC963.8020906@redhat.com>
Date: Mon, 21 Nov 2011 16:57:55 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/8] Revert "vmscan: limit direct reclaim for higher order
 allocations"
References: <1321635524-8586-1-git-send-email-mgorman@suse.de> <1321732460-14155-9-git-send-email-aarcange@redhat.com>
In-Reply-To: <1321732460-14155-9-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

On 11/19/2011 02:54 PM, Andrea Arcangeli wrote:
> This reverts commit e0887c19b2daa140f20ca8104bdc5740f39dbb86.
>
> If reclaim runs with an high order allocation, it means compaction
> failed. That means something went wrong with compaction so we can't
> stop reclaim too. We can't assume it failed and was deferred only
> because of the too low watermarks in compaction_suitable, it may have
> failed for other reasons.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

NACK

Reverting this can lead to the situation where every time
we have an attempted THP allocation, we free 4MB more
memory.

This has led to systems with 1/4 to 1/3 of all memory free
and pushed to swap, while the system continues with swapout
activity.

The thrashing this causes can be a factor 10 or worse
performance penalty.  Failing a THP allocation is merely
a 10-20% performance penalty, which is not as much of an
issue.

We can move the threshold at which we skip pageout to be a
little higher (to give compaction more space to work with),
and even call shrink_slab when we skip other reclaiming
(because slab cannot be moved by compaction), but whatever
we do we do need to ensure that we never reclaim an unreasonable
amount of memory and end up pushing the working set into swap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
