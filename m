Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5EEB06B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 04:24:01 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8E8NwUi025372
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Sep 2010 17:23:58 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 030F745DE51
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 17:23:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D770C45DE4F
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 17:23:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BA28D1DB8052
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 17:23:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 703111DB804C
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 17:23:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 05/17] writeback: quit throttling when signal pending
In-Reply-To: <20100913034808.GA9196@localhost>
References: <20100913132116.3917e5d5@notabene> <20100913034808.GA9196@localhost>
Message-Id: <20100914172028.C9B2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Sep 2010 17:23:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Neil Brown <neilb@suse.de>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> Subject: writeback: quit throttling when fatal signal pending
> From: Wu Fengguang <fengguang.wu@intel.com>
> Date: Wed Sep 08 17:40:22 CST 2010
> 
> This allows quick response to Ctrl-C etc. for impatient users.
> 
> It mainly helps the rare bdi/global dirty exceeded cases.
> In the normal case of not exceeded, it will quit the loop anyway. 
> 
> CC: Neil Brown <neilb@suse.de>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/page-writeback.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> --- linux-next.orig/mm/page-writeback.c	2010-09-12 13:25:23.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2010-09-13 11:39:33.000000000 +0800
> @@ -552,6 +552,9 @@ static void balance_dirty_pages(struct a
>  		__set_current_state(TASK_INTERRUPTIBLE);
>  		io_schedule_timeout(pause);
>  
> +		if (fatal_signal_pending(current))
> +			break;
> +
>  check_exceeded:
>  		/*
>  		 * The bdi thresh is somehow "soft" limit derived from the

I think we need to change callers (e.g. generic_perform_write) too.
Otherwise, plenty write + SIGKILL combination easily exceed dirty limit.
It mean we can see strange OOM.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
