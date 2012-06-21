Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 0FE946B00AF
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 06:16:39 -0400 (EDT)
Received: by dakp5 with SMTP id p5so863806dak.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 03:16:39 -0700 (PDT)
Date: Thu, 21 Jun 2012 03:16:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: abort compaction if migration page cannot be
 charged to memcg
In-Reply-To: <4FE2F1DA.8030608@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1206210310030.15747@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com> <4FE2D73C.3060001@kernel.org> <alpine.DEB.2.00.1206210124380.6635@chino.kir.corp.google.com> <alpine.DEB.2.00.1206210158360.10975@chino.kir.corp.google.com>
 <4FE2F1DA.8030608@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 21 Jun 2012, Kamezawa Hiroyuki wrote:

> I guess the best way will be never calling charge/uncharge at migration.
> ....but it has been a battle with many race conditions..
> 
> Here is an alternative way, remove -ENOMEM in mem_cgroup_prepare_migration()
> by using res_counter_charge_nofail().
> 
> Could you try this ?

I would love to be able to remove the -ENOMEM as the result of charging 
the temporary page, but what happens if all cpus are calling into 
migrate_pages() that are unmapping pages from the same memcg?  This need 
not only be happening from compaction, either.  It feels like this 
wouldn't scale appropriately and you risk going significantly over the 
limit even for a brief enough period of time.  I'd hate to be 128K over my 
limit on a machine with 32 cores.

Comments from the memcg folks on if this is acceptable?

In the interim, do you have an objection to merging this patch as bandaid 
for stable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
