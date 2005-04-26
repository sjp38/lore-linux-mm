Date: Mon, 25 Apr 2005 20:43:27 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 3/8 PG_skipped
Message-Id: <20050425204327.4436cd77.akpm@osdl.org>
In-Reply-To: <16994.40579.617974.423522@gargle.gargle.HOWL>
References: <16994.40579.617974.423522@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org, AKPM@osdl.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
>  Don't call ->writepage from VM scanner when page is met for the first time
>  during scan.
> 
>  New page flag PG_skipped is used for this. This flag is TestSet-ed just
>  before calling ->writepage and is cleaned when page enters inactive
>  list.
> 
>  One can see this as "second chance" algorithm for the dirty pages on the
>  inactive list.
> 
>  BSD does the same: src/sys/vm/vm_pageout.c:vm_pageout_scan(),
>  PG_WINATCFLS flag.
> 
>  Reason behind this is that ->writepages() will perform more efficient writeout
>  than ->writepage(). Skipping of page can be conditioned on zone->pressure.
> 
>  On the other hand, avoiding ->writepage() increases amount of scanning
>  performed by kswapd.

I worry that this will cause boxes to go oom all over the place, due to the
longer scans which are encountered prior to pages being reclaimed.

We could of course increase the "oh crap, we've scanned too much"
threshold.  We probably need to do that anyway - I shrunk it by heaps early
in 2.5 just as a "let's see who complains" experiment.

Writeout off the LRU should be a rare case.  We should have instrumentation
for that, but we don't.

My gut feel with this patch is to run away in terror, frankly.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
