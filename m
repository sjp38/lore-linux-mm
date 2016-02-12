Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 63F206B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 14:35:56 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id c200so35067261wme.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 11:35:56 -0800 (PST)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id a63si5872424wmd.11.2016.02.12.11.35.55
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 11:35:55 -0800 (PST)
Date: Fri, 12 Feb 2016 20:35:53 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Re: Unhelpful caching decisions, possibly related to active/inactive
 sizing
Message-ID: <20160212193553.6pugckvamgtk4x5q@alap3.anarazel.de>
References: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
 <20160209224256.GA29872@cmpxchg.org>
 <20160211153404.42055b27@cuia.usersys.redhat.com>
 <20160212124653.35zwmy3p2pat5trv@alap3.anarazel.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160212124653.35zwmy3p2pat5trv@alap3.anarazel.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On 2016-02-12 13:46:53 +0100, Andres Freund wrote:
> I'm wondering why pages that are repeatedly written to, in units above
> the page size, are promoted to the active list? I mean if there never
> are any reads or re-dirtying an already-dirty page, what's the benefit
> of moving that page onto the active list?

We chatted about this on IRC and you proposed testing this by removing
FGP_ACCESSED in grab_cache_page_write_begin.  I ran tests with that,
after removing the aforementioned code to issue posix_fadvise(DONTNEED)
in postgres.

base (4.5-rc2+10)
        latency average = 3.079 ms
        latency stddev = 8.269 ms
        tps = 10384.545914 (including connections establishing)
        tps = 10384.866341 (excluding connections establishing)


inactive/active patch:
        latency average = 2.931 ms
        latency stddev = 7.683 ms
        tps = 10908.905039 (including connections establishing)
        tps = 10909.256946 (excluding connections establishing)


inactive/active patch + no FGP_ACCESSED in grab_cache_page_write_begin:
        latency average = 2.806 ms
        latency stddev = 7.871 ms
        tps = 11392.893213 (including connections establishing)
        tps = 11393.839826 (excluding connections establishing)


Here the active/inactive lists didn't change as much as I hoped. A bit
of reading made it apparent that the workingset logic in
add_to_page_cache_lru() defated that attempt, by moving an previously
discarded page directly into the active list. I added a variant of
add_to_page_cache_lru() that accepts fgp_flags and only does the
workingset check if FGP_ACCESSED is set. That results in:

inactive/active patch + no FGP_ACCESSED in grab_cache_page_write_begin * add_to_page_cache_lru:
        latency average: 2.292 ms
        latency stddev: 6.487 ms
        tps = 13940.530898 (including connections establishing)
        tps = 13941.774874 (excluding connections establishing)

that's only slightly worse than doing explicit posix_fadvise(DONTNEED)
calls... Pretty good.

To make an actually usable patch out of this it seems we'd have to add a
'partial' argument to grab_cache_page_write_begin(), so writes to parts
of a page still cause the pages to be marked active.  Is it preferrable
to change all callers of grab_cache_page_write_begin and
add_to_page_cache_lru or make them into wrapper functions, and call the
real deal when it matters?

I do think that that's a reasonable algorithmic change, but nonetheless
its obviously possible that such changes regress some workloads. What's
the policy around testing such things?

Greetings,

Andres Freund

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
