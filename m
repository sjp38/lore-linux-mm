Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E41416B0038
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 20:04:33 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so15058286pac.8
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 17:04:33 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id b6si11241635pdk.59.2015.01.08.17.04.30
        for <linux-mm@kvack.org>;
        Thu, 08 Jan 2015 17:04:32 -0800 (PST)
Date: Fri, 9 Jan 2015 10:04:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] mm/compaction: enhance trace output to know more
 about compaction internals
Message-ID: <20150109010441.GA27760@js1304-P5Q-DELUXE>
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
 <54ABA563.1040103@suse.cz>
 <20150108081835.GC25453@js1304-P5Q-DELUXE>
 <54AE43E3.60209@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54AE43E3.60209@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 08, 2015 at 09:46:27AM +0100, Vlastimil Babka wrote:
> On 01/08/2015 09:18 AM, Joonsoo Kim wrote:
> > On Tue, Jan 06, 2015 at 10:05:39AM +0100, Vlastimil Babka wrote:
> >> On 12/03/2014 08:52 AM, Joonsoo Kim wrote:
> >> > It'd be useful to know where the both scanner is start. And, it also be
> >> > useful to know current range where compaction work. It will help to find
> >> > odd behaviour or problem on compaction.
> >> 
> >> Overall it looks good, just two questions:
> >> 1) Why change the pfn output to hexadecimal with different printf layout and
> >> change the variable names and? Is it that better to warrant people having to
> >> potentially modify their scripts parsing the old output?
> > 
> > Deciaml output has really bad readability since we manage all pages by order
> > of 2 which is well represented by hexadecimal. With hex output, we can
> > easily notice whether we move out from one pageblock to another one.
> 
> OK. I don't have any strong objection, maybe Mel should comment on this as the
> author of most of the tracepoints? But if it happens, I think converting the old
> tracepoints to new hexadecimal format should be a separate patch from adding the
> new ones.

Okay.

> 
> >> 2) Would it be useful to also print in the mm_compaction_isolate_template based
> >> tracepoints, pfn of where the particular scanner left off a block prematurely?
> >> It doesn't always match start_pfn + nr_scanned.
> > 
> > With start_pfn and end_pfn, detailed analysis is possible. We can know pageblock
> > where we actually scan and isolate and how much pages we try in that
> > pageblock and can guess why it doesn't become freepage with pageblock
> > order roughly.
> > 
> > nr_scanned is just different metric. end_pfn don't need to match with
> > start_pfn + nr_scanned.
> 
> Well that's part of my point. end_pfn is the end of the pageblock. nr_scanned
> might be lower than end_pfn - start_pfn, because we terminate in the middle of
> the pageblock. But it might be also lower, because we e.g. skip higher-order
> free pages. So we don't recognize where we terminated early.

Ah... now I see your point and found my mistake. My intention is also to
print terminated pfn rather than end_pfn of pageblock. :/
I will change it to print pfn where we terminate scanning.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
