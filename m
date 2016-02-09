Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 049D76B0253
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 11:52:43 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p63so167023566wmp.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 08:52:42 -0800 (PST)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id i195si14732467wmf.5.2016.02.09.08.52.41
        for <linux-mm@kvack.org>;
        Tue, 09 Feb 2016 08:52:41 -0800 (PST)
Date: Tue, 9 Feb 2016 17:52:40 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Unhelpful caching decisions, possibly related to active/inactive
 sizing
Message-ID: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Hi,

I'm working on fixing long IO stalls with postgres. After some
architectural changes fixing the worst issues, I noticed that indivdiual
processes/backends/connections still spend more time waiting than I'd
expect.

In an workload with the hot data set fitting into memory (2GB of
mmap(HUGE|ANNON) shared memory for postgres buffer cache, ~6GB of
dataset, 16GB total memory) I found that there's more reads hitting disk
that I'd expect.  That's after I've led Vlastimil on IRC down a wrong
rabbithole, sorry for that.

Some tinkering and question later, the issue appears to be postgres'
journal/WAL. Which in the test-setup is write-only, and only touched
again when individual segments of the WAL are reused. Which, in the
configuration I'm using, only happens after ~20min and 30GB later or so.
Drastically reducing the volume of WAL through some (unsafe)
configuration options, or forcing the WAL to be written using O_DIRECT,
changes the workload to be fully cached.

Rik asked me about active/inactive sizing in /proc/meminfo:
Active:          7860556 kB
Inactive:        5395644 kB
Active(anon):    2874936 kB
Inactive(anon):   432308 kB
Active(file):    4985620 kB
Inactive(file):  4963336 kB

and then said:

riel   | the workingset stuff does not appear to be taken into account for active/inactive list sizing, in vmscan.c
riel   | I suspect we will want to expand the vmscan.c code, to take the workingset stats into account
riel   | when we re-fault a page that was on the active list before, we want to grow the size of the active list (and
       | shrink from inactive)
riel   | when we re-fault a page that was never active, we need to grow the size of the inactive list (and shrink
       | active)
riel   | but I don't think we have any bits free in page flags for that, we may need to improvise something :)

andres | Ok, at this point I'm kinda out of my depth here ;)

riel   | andres: basically active & inactive file LRUs are kept at the same size currently
riel   | andres: which means anything that overflows half of memory will get flushed out of the cache by large write
       | volumes (to the write-only log)
riel   | andres: what we should do is dynamically size the active & inactive file lists, depending on which of the two
       | needs more caching
riel   | andres: if we never re-use the inactive pages that get flushed out, there's no sense in caching more of them
       | (and we could dedicate more memory to the active list, instead)

andres | Sounds sensible. I guess things get really tricky if there's a portion of the inactive list that does get
       | reused (say if the hot data set is larger than memory), and another doesn't get reused at all.

I promised to send an email about the issue...

I provide you with a branch of postgres + instructions to reproduce the
issue, or I can test patches, whatever you prefer.

This test was run using 4.5.0-rc2, but I doubt this is a recent
regression or such.

Any other information I can provide you with?

Regards,

Andres

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
