Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 253826B00AB
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 09:05:38 -0500 (EST)
Message-ID: <4CFB9BE1.3030902@redhat.com>
Date: Sun, 05 Dec 2010 09:04:17 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] writeback: enabling-gate for light dirtied bdi
References: <20101205064430.GA15027@localhost>
In-Reply-To: <20101205064430.GA15027@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 12/05/2010 01:44 AM, Wu Fengguang wrote:
> I noticed that my NFSROOT test system goes slow responding when there
> is heavy dd to a local disk. Traces show that the NFSROOT's bdi_limit
> is near 0 and many tasks in the system are repeatedly stuck in
> balance_dirty_pages().
>
> There are two related problems:
>
> - light dirtiers at one device (more often than not the rootfs) get
>    heavily impacted by heavy dirtiers on another independent device
>
> - the light dirtied device does heavy throttling because bdi_limit=0,
>    and the heavy throttling may in turn withhold its bdi_limit in 0 as
>    it cannot dirty fast enough to grow up the bdi's proportional weight.
>
> Fix it by introducing some "low pass" gate, which is a small (<=8MB)
> value reserved by others and can be safely "stole" from the current
> global dirty margin.  It does not need to be big to help the bdi gain
> its initial weight.

Makes a lot of sense to me.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
