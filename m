Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 903346B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 05:25:30 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8E9PRor018822
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Sep 2010 18:25:28 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B0C8B45DE57
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 18:25:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C3A645DE4F
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 18:25:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 382C41DB803B
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 18:25:27 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E2B0FE08001
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 18:25:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 05/17] writeback: quit throttling when signal pending
In-Reply-To: <20100914091720.GA23042@localhost>
References: <20100914174017.C9BB.A69D9226@jp.fujitsu.com> <20100914091720.GA23042@localhost>
Message-Id: <20100914182433.C9C1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Sep 2010 18:25:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Neil Brown <neilb@suse.de>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> > > However, I suspect the process is guaranteed to exit on
> > > fatal_signal_pending, so it won't dirty more pages :)
> > 
> > Process exiting is delayed until syscall exiting. So, we exit write syscall
> > manually if necessary.
> 
> Got it, you mean this fix. It looks good. I didn't add "status =
> -EINTR" in the patch because the bottom line "written ? : status" will
> always select the non-zero written.
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 3d4df44..f6d2740 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2304,7 +2304,8 @@ again:
>  		written += copied;
>  
>  		balance_dirty_pages_ratelimited(mapping);
> -
> +		if (fatal_signal_pending(current))
> +			break;
>  	} while (iov_iter_count(i));

Looks good. however other callers also need to be updated.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
