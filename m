Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id AF8606B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 17:19:52 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id c200so95715907wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 14:19:52 -0800 (PST)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id c21si15605550wmd.111.2016.02.19.14.19.51
        for <linux-mm@kvack.org>;
        Fri, 19 Feb 2016 14:19:51 -0800 (PST)
Date: Fri, 19 Feb 2016 14:19:39 -0800
From: Andres Freund <andres@anarazel.de>
Subject: Re: Unhelpful caching decisions, possibly related to active/inactive
 sizing
Message-ID: <20160219221939.ywgfdeeaitlgnw44@alap3.anarazel.de>
References: <20160209165240.th5bx4adkyewnrf3@alap3.anarazel.de>
 <20160209224256.GA29872@cmpxchg.org>
 <20160211153404.42055b27@cuia.usersys.redhat.com>
 <20160212124653.35zwmy3p2pat5trv@alap3.anarazel.de>
 <20160212193553.6pugckvamgtk4x5q@alap3.anarazel.de>
 <20160217161744.6ce0b1e5@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160217161744.6ce0b1e5@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On 2016-02-17 16:17:44 -0500, Rik van Riel wrote:
> On Fri, 12 Feb 2016 20:35:53 +0100
> Andres Freund <andres@anarazel.de> wrote:
> 
> > On 2016-02-12 13:46:53 +0100, Andres Freund wrote:
> > > I'm wondering why pages that are repeatedly written to, in units above
> > > the page size, are promoted to the active list? I mean if there never
> > > are any reads or re-dirtying an already-dirty page, what's the benefit
> > > of moving that page onto the active list?
> > 
> > We chatted about this on IRC and you proposed testing this by removing
> > FGP_ACCESSED in grab_cache_page_write_begin.  I ran tests with that,
> > after removing the aforementioned code to issue posix_fadvise(DONTNEED)
> > in postgres.
> 
> That looks promising.

Indeed.


> > Here the active/inactive lists didn't change as much as I hoped. A bit
> > of reading made it apparent that the workingset logic in
> > add_to_page_cache_lru() defated that attempt,
> 
> The patch below should help with that.
> 
> Does the GFP_ACCESSED change still help with the patch
> below applied?

I've not yet run any tests, but I'd earlier used perf probes to see
where pages got activated, and I saw activations from both places. So
presumably there'd be a difference; i.e. ISTM we need to change both
places.


Regards,

Andres

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
