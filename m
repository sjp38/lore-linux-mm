Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB146B0005
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 07:46:56 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so61048488wme.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 04:46:56 -0800 (PST)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id gh6si18953391wjb.245.2016.02.12.04.46.54
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 04:46:55 -0800 (PST)
Date: Fri, 12 Feb 2016 13:46:53 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Re: Unhelpful caching decisions, possibly related to active/inactive
 sizing
Message-ID: <20160212124653.35zwmy3p2pat5trv@alap3.anarazel.de>
References: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
 <20160209224256.GA29872@cmpxchg.org>
 <20160211153404.42055b27@cuia.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160211153404.42055b27@cuia.usersys.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Hi,

On 2016-02-11 15:34:04 -0500, Rik van Riel wrote:
> Andres, does this patch work for you?

TL;DR: The patch helps, there might be some additional, largely
independent, further improvements.


So, I tested this. And under the right set of cirumstances the results
are pretty good:

----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
before (4.5.0-rc3-andres-00010-g765bdb4):
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 550
query mode: prepared
number of clients: 32
number of threads: 32
duration: 300 s
number of transactions actually processed: 3539535
latency average = 2.710 ms
latency stddev = 7.738 ms
tps = 11797.755387 (including connections establishing)
tps = 11798.515737 (excluding connections establishing)

Active:          6890844 kB
Inactive:        6409868 kB
Active(anon):     684804 kB
Inactive(anon):   202960 kB
Active(file):    6206040 kB
Inactive(file):  6206908 kB


~20MB reads/s

----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

after (4.5.0-rc3-andres-00011-g2b9abf6-dirty):
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 550
query mode: prepared
number of clients: 32
number of threads: 32
duration: 300 s
number of transactions actually processed: 4372722
latency average = 2.192 ms
latency stddev = 6.095 ms
tps = 14575.395438 (including connections establishing)
tps = 14576.212433 (excluding connections establishing)


Active:          9460392 kB
Inactive:        3813748 kB
Active(anon):     444724 kB
Inactive(anon):   329368 kB
Active(file):    9015668 kB
Inactive(file):  3484380 kB

0MB reads/s

----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

And that's on a system with a relatively fast SSD. I suspect the
difference would be massively bigger on systems with rotational media,
given the reads in the "before" state are almost entirely random.


Unfortunately the above "right set of circumstances" aren't entirely
trivial to match. Postgres writes its journal/WAL to pre-allocated WAL
files, which are then recycled after a while. The journal writes are
currently intentionally not marked with DONTNEED or O_DIRECT because for
e.g. replication and such internal and external processes may read the
WAL again.

Without additional changes in postgres, the recycling often appears to
lead to the WAL files to be promoted onto the active list, even if they
are only ever written to in a streaming manner, never read. That's easy
enough to defeat, by doing a posix_fadvise(DONTNEED) during recycling;
after all there's never a need to read the previous contents before
that.  But if the window till recycling is large enough, it appears to
often "defeat" other inactive pages to be promoted to active. Partially
that's probably hard to fix.

I'm wondering why pages that are repeatedly written to, in units above
the page size, are promoted to the active list? I mean if there never
are any reads or re-dirtying an already-dirty page, what's the benefit
of moving that page onto the active list?

I imagine that high volumne streaming writes are generally pretty common
(non durability log-files!), and streaming over-writing sounds also
something a number of applications are doing.

Greetings,

Andres Freund

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
