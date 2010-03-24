Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE436B01F3
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 16:34:52 -0400 (EDT)
Date: Wed, 24 Mar 2010 13:33:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 08/11] Add /proc trigger for memory compaction
Message-Id: <20100324133351.c7730969.akpm@linux-foundation.org>
In-Reply-To: <1269347146-7461-9-git-send-email-mel@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	<1269347146-7461-9-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010 12:25:43 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> This patch adds a proc file /proc/sys/vm/compact_memory. When an arbitrary
> value is written to the file, all zones are compacted. The expected user
> of such a trigger is a job scheduler that prepares the system before the
> target application runs.
> 
>
> ...
>
> +/* This is the entry point for compacting all nodes via /proc/sys/vm */
> +int sysctl_compaction_handler(struct ctl_table *table, int write,
> +			void __user *buffer, size_t *length, loff_t *ppos)
> +{
> +	if (write)
> +		return compact_nodes();
> +
> +	return 0;
> +}

Neato.  When I saw the overall description I was afraid that this stuff
would be fiddling with kernel threads.

The underlying compaction code can at times cause rather large amounts
of memory to be put onto private lists, so it's lost to the rest of the
kernel.  What happens if 10000 processes simultaneously write to this
thing?  It's root-only so I guess the answer is "root becomes unemployed".


I fear that the overall effect of this feature is that people will come
up with ghastly hacks which keep on poking this tunable as a workaround
for some VM shortcoming.  This will lead to more shortcomings, and
longer-lived ones.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
