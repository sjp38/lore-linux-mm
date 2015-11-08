Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B63006B0253
	for <linux-mm@kvack.org>; Sun,  8 Nov 2015 16:17:49 -0500 (EST)
Received: by pasz6 with SMTP id z6so181523903pas.2
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 13:17:49 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ff7si17539215pac.213.2015.11.08.13.17.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 13:17:48 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so176703399pab.0
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 13:17:48 -0800 (PST)
Date: Sun, 8 Nov 2015 13:17:39 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/12] mm: page migration use the put_new_page whenever
 necessary
In-Reply-To: <563BA087.1090402@suse.cz>
Message-ID: <alpine.LSU.2.11.1511081231120.12914@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils> <alpine.LSU.2.11.1510182156010.2481@eggly.anvils> <563BA087.1090402@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Thu, 5 Nov 2015, Vlastimil Babka wrote:
> On 10/19/2015 06:57 AM, Hugh Dickins wrote:
> > I don't know of any problem from the way it's used in our current tree,
> > but there is one defect in page migration's custom put_new_page feature.
> > 
> > An unused newpage is expected to be released with the put_new_page(),
> > but there was one MIGRATEPAGE_SUCCESS (0) path which released it with
> > putback_lru_page(): which can be very wrong for a custom pool.
> 
> I'm a bit confused. So there's no immediate bug to be fixed but there was one in
> the mainline in the past? Or elsewhere?

"elsewhere": I came across it (and several of the other issues addressed
in this patchset) when using migrate_pages() in my huge tmpfs work.

I admit that, until I came to reply to you, I had thought this oversight
resulted in a (minor) unintended inefficiency in compaction - still the
sole user of the put_new_page feature in current mainline.  I thought it
was permitting a waste of effort of the kind that put_new_page was added
to stop.

But that's not so: because it's limited to (the page_count 1 case of)
MIGRATEPAGE_SUCCESS, migrate_pages() will not retry on the old page, so
it does not matter that its migration target is diverted to the public
pool, instead of back to the private pool.

At least, I think it barely matters; but using putback_lru_page does
miss out on the "pfn > high_pfn" check in release_freepages().

> 
> > Fixed more easily by resetting put_new_page once it won't be needed,
> > than by adding a further flag to modify the rc test.
> 
> What is "fixed" if there is no bug? :) Maybe "Further bugs would be
> prevented..." or something?

I never claimed a "critical bug" there, nor asked for this to go to
stable.  I think it's fair to describe something as a "bug", where a
design is not quite working as it had intended; though "defect" is the
word I actually used.  It's reasonable to "fix" a "defect", isn't it?

> 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> I agree it's less error-prone after you patch, so:
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks, and for your other scrutiny and Acks too.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
