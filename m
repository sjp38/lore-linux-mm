Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 4C1FC6B025A
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 20:32:03 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9010583pbb.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 17:32:02 -0700 (PDT)
Date: Mon, 25 Jun 2012 17:32:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: abort compaction if migration page cannot be
 charged to memcg
In-Reply-To: <4FE8CCCD.7080503@redhat.com>
Message-ID: <alpine.DEB.2.00.1206251726040.1895@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com> <4FE8CCCD.7080503@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 25 Jun 2012, Rik van Riel wrote:

> The patch makes sense, however I wonder if it would make
> more sense in the long run to allow migrate/compaction to
> temporarily exceed the memcg memory limit for a cgroup,
> because the original page will get freed again soon anyway.
> 
> That has the potential to improve compaction success, and
> reduce compaction related CPU use.
> 

Yeah, Kame brought up the same point with a sample patch by allowing the 
temporary charge for the new page.  It would certainly solve this problem 
in a way that we don't have to even touch compaction, it's disappointing 
that we have to charge memory to do a page migration.  I'm not so sure 
about the approach of temporarily allowing the excess charge, however, 
since it would scale with the number of cpus doing compaction or 
migration, which could end up with PAGE_SIZE * nr_cpu_ids.

I haven't looked at it (yet), but I'm hoping that there's a way to avoid 
charging the temporary page at all until after move_to_new_page() 
succeeds, i.e. find a way to uncharge page before charging newpage.  We 
currently don't charge things like vmalloc() memory to things that call 
alloc_pages() directly so it seems like it's plausible without causing 
usage > limit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
