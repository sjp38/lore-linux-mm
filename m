Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D99546B0256
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 04:39:26 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so17869781wic.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 01:39:26 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bd6si22752112wib.116.2015.09.15.01.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 01:39:25 -0700 (PDT)
Date: Tue, 15 Sep 2015 10:39:19 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bug 99471] System locks with kswapd0 and kworker taking full IO
 and mem
Message-ID: <20150915083919.GG2858@cmpxchg.org>
References: <bug-99471-27@https.bugzilla.kernel.org/>
 <bug-99471-27-hjYeBz7jw2@https.bugzilla.kernel.org/>
 <20150910140418.73b33d3542bab739f8fd1826@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150910140418.73b33d3542bab739f8fd1826@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, gaguilar@aguilardelgado.com, sgh@sgh.dk, Rik van Riel <riel@redhat.com>

On Thu, Sep 10, 2015 at 02:04:18PM -0700, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 01 Sep 2015 12:32:10 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=99471
> 
> Guys, could you take a look please?
> 
> The machine went oom when there's heaps of unused swap and most memory
> is being used on active_anon and inactive_anon.  We should have just
> swapped that stuff out and kept going.

I think we need to re-evaluate the way we balance file and anon scan
pressure. It's not just the "not swapping" aspect that bugs me, it's
also the fact that the machine has been thrashing page cache at full
load for *minutes* before signalling the OOM.

SSDs can flush and reload pages quick enough that on memory pressure
there are always reclaimable cache pages and the scanner never goes
after anonymous memory. If anonymous memory does not leave enough room
for page cache to hold the libraries and executables, userspace goes
into a state where it's mostly waiting for cache to become uptodate.

It's a very frustrating problem because it's hard to even detect.

One idea I had to address the LRU balance problem in the past was to
always reclaim the pages in the following order: inactive file, active
file, anon*. As one set becomes empty, go after the next one. If the
workingset code detects cache thrashing, it depends on the refault
distances what to do: if they are smaller than the active file size,
deactivate; if they are bigger than that, but smaller than active file
+ anon, we need to start swapping to alleviate the cache thrashing.

Now, if the refault distances are bigger than active file + anon, no
amount of deactivating and swapping are going to stop the thrashing
and we have to think about triggering OOM. But OOM is drastic and the
refaults might happen at a very slow pace (or, with sparse files, not
require any IO at all) and the system might be completely fine. So in
addition this would require a measure of overall time spent on
thrashing IO, comparable to what Tejun proposed in "[RFD] memory
pressure and sizing problem", where we say if thrashing IO takes up X
percent of all execution time spent, we trigger the OOM killer--not to
free memory, but to reduce the tasks that contribute to the thrashing
and let the remaining tasks make progress, similar to the swap token
or a BSD style memory scheduler.

* we can ignore the difference between inactive and active anon here
  as anon is not aged the same way as the file LRU is aged

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
