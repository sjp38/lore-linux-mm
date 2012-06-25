Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id A3E626B038A
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 16:41:52 -0400 (EDT)
Message-ID: <4FE8CCCD.7080503@redhat.com>
Date: Mon, 25 Jun 2012 16:40:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, thp: abort compaction if migration page cannot be
 charged to memcg
References: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/21/2012 02:52 AM, David Rientjes wrote:
> If page migration cannot charge the new page to the memcg,
> migrate_pages() will return -ENOMEM.  This isn't considered in memory
> compaction however, and the loop continues to iterate over all pageblocks
> trying in a futile attempt to continue migrations which are only bound to
> fail.
>
> This will short circuit and fail memory compaction if migrate_pages()
> returns -ENOMEM.  COMPACT_PARTIAL is returned in case some migrations
> were successful so that the page allocator will retry.

The patch makes sense, however I wonder if it would make
more sense in the long run to allow migrate/compaction to
temporarily exceed the memcg memory limit for a cgroup,
because the original page will get freed again soon anyway.

That has the potential to improve compaction success, and
reduce compaction related CPU use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
