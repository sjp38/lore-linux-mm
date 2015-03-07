Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id C7A936B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 19:21:12 -0500 (EST)
Received: by wghl18 with SMTP id l18so16016207wgh.5
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 16:21:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l5si23445776wiv.80.2015.03.06.16.21.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Mar 2015 16:21:11 -0800 (PST)
Date: Fri, 6 Mar 2015 19:20:55 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150307002055.GA29679@phnom.home.cmpxchg.org>
References: <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <54F42FEA.1020404@suse.cz>
 <20150302223154.GJ18360@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150302223154.GJ18360@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Tue, Mar 03, 2015 at 09:31:54AM +1100, Dave Chinner wrote:
> What we don't know is how many objects we might need to scan to find
> the objects we will eventually modify.  Here's an (admittedly
> extreme) example to demonstrate a worst case scenario: allocate a
> 64k data extent. Because it is an exact size allocation, we look it
> up in the by-size free space btree. Free space is fragmented, so
> there are about a million 64k free space extents in the tree.
> 
> Once we find the first 64k extent, we search them to find the best
> locality target match.  The btree records are 16 bytes each, so we
> fit roughly 500 to a 4k block. Say we search half the extents to
> find the best match - i.e. we walk a thousand leaf blocks before
> finding the match we want, and modify that leaf block.
> 
> Now, the modification removed an entry from the leaf and tht
> triggers leaf merge thresholds, so a merge with the 1002nd block
> occurs. That block now demand pages in and we then modify and join
> it to the transaction. Now we walk back up the btree to update
> indexes, merging blocks all the way back up to the root.  We have a
> worst case size btree (5 levels) and we merge at every level meaning
> we demand page another 8 btree blocks and modify them.
> 
> In this case, we've demand paged ~1010 btree blocks, but only
> modified 10 of them. i.e. the memory we consumed permanently was
> only 10 4k buffers (approx. 10 slab and 10 page allocations), but
> the allocation demand was 2 orders of magnitude more than the
> unreclaimable memory consumption of the btree modification.
> 
> I hope you start to see the scope of the problem now...

Isn't this bounded one way or another?  Sure, the inaccuracy itself is
high, but when you put the absolute numbers in perspective it really
doesn't seem to matter: with your extreme case of 3MB per transaction,
you can still run 5k+ of them in parallel on a small 16G machine.
Occupy a generous 75% of RAM with anonymous pages, and you can STILL
run over a thousand transactions concurrently.  That would seem like a
decent pipeline to keep the storage device occupied.

The level of precision that you are asking for comes with complexity
and fragility that I'm not convinced is necessary, or justified.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
