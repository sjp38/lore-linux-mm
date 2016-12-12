Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9606B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 17:20:09 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so139072894pfb.6
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 14:20:09 -0800 (PST)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id v21si45091553pgh.212.2016.12.12.14.20.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 14:20:08 -0800 (PST)
Received: by mail-pg0-x229.google.com with SMTP id 3so39813069pgd.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 14:20:08 -0800 (PST)
Date: Mon, 12 Dec 2016 14:20:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: add vmstats for kcompactd work
In-Reply-To: <f25f8fb9-47a9-ebd9-5a7a-95ca6dc324c9@suse.cz>
Message-ID: <alpine.DEB.2.10.1612121414390.59730@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1612071749390.69852@chino.kir.corp.google.com> <f25f8fb9-47a9-ebd9-5a7a-95ca6dc324c9@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 8 Dec 2016, Vlastimil Babka wrote:

> > A "compact_daemon_wake" vmstat exists that represents the number of times
> > kcompactd has woken up.  This doesn't represent how much work it actually
> > did, though.
> > 
> > It's useful to understand how much compaction work is being done by
> > kcompactd versus other methods such as direct compaction and explicitly
> > triggered per-node (or system) compaction.
> > 
> > This adds two new vmstats: "compact_daemon_migrate_scanned" and
> > "compact_daemon_free_scanned" to represent the number of pages kcompactd
> > has scanned as part of its migration scanner and freeing scanner,
> > respectively.
> > 
> > These values are still accounted for in the general
> > "compact_migrate_scanned" and "compact_free_scanned" for compatibility.
> > 
> > It could be argued that explicitly triggered compaction could also be
> > tracked separately, and that could be added if others find it useful.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> A bit of downside is that stats are only updated when compaction finishes, but
> I guess it's acceptable. Also I don't think the compact_control variables need
> the "total_" prefix, but no strong feelings. The explicit zero init should be
> also unnecessary.
> 

I actually prefer to have stats updated when compaction is finished for a 
single cycle, otherwise you get partially updated results: you have to 
make an inference of when a single compact_stall begins and ends.  If you 
need detailed data for a single invocation of compaction, tracepoints 
would be much better.

> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
