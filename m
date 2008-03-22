Date: Sat, 22 Mar 2008 10:55:31 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [for -mm][PATCH][1/2] page reclaim throttle take3
Message-ID: <20080322105531.23f2bfdf@bree.surriel.com>
In-Reply-To: <20080322192928.B30B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080322192928.B30B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Sat, 22 Mar 2008 19:45:54 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> +	wait_event(zone->reclaim_throttle_waitq,
> +		   atomic_add_unless(&zone->nr_reclaimers, 1,
> +				     CONFIG_NR_MAX_RECLAIM_TASKS_PER_ZONE));

I like your patch, but can see one potential problem.   Sometimes
tasks that go into page reclaim with GFP_HIGHUSER end up recursing
back into page reclaim without __GFP_FS and/or __GFP_IO.

In that scenario, a task could end up waiting on itself and
deadlocking.

Maybe we should only let tasks with __GFP_FS, __GFP_IO and other
"I can do everything" flags wait on this waitqueue, letting the
tasks that cannot do IO (and are just here to reclaim clean pages)
bypass this waitqueue.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
