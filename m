Date: Mon, 5 May 2008 17:51:42 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [-mm][PATCH 4/5] core of reclaim throttle
Message-ID: <20080505175142.7de3f27b@cuia.bos.redhat.com>
In-Reply-To: <20080504221043.8F64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080504215819.8F5E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080504221043.8F64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 04 May 2008 22:12:12 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> +	throttle_on = 1;
> +	current->flags |= PF_RECLAIMING;
> +	wait_event(zone->reclaim_throttle_waitq,
> +		 atomic_add_unless(&zone->nr_reclaimers, 1, MAX_RECLAIM_TASKS));

This is a problem.  Processes without __GFP_FS or __GFP_IO cannot wait on
processes that have those flags set in their gfp_mask, and tasks that do
not have __GFP_IO set cannot wait for tasks with it.  This is because the
tasks that have those flags set may grab locks that the tasks without the
flag are holding, causing a deadlock.

The easiest fix would be to only make tasks with both __GFP_FS and __GFP_IO
sleep.  Tasks that call try_to_free_pages without those flags are relatively
rare and should hopefully not cause any issues.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
