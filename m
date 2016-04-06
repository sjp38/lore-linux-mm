Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 199316B026E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:02:09 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id f52so48136585qga.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:02:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f81si3659535qkb.82.2016.04.06.15.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 15:02:08 -0700 (PDT)
Date: Wed, 6 Apr 2016 18:02:02 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20160406220202.GA2998@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
 <1459974829.28435.6.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459974829.28435.6.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>

Hello Rik,

On Wed, Apr 06, 2016 at 04:33:49PM -0400, Rik van Riel wrote:
> On Tue, 2015-11-10 at 19:44 +0100, Andrea Arcangeli wrote:
> > Without a max deduplication limit for each KSM page, the list of the
> > rmap_items associated to each stable_node can grow infinitely
> > large.
> > 
> > During the rmap walk each entry can take up to ~10usec to process
> > because of IPIs for the TLB flushing (both for the primary MMU and
> > the
> > secondary MMUs with the MMU notifier). With only 16GB of address
> > space
> > shared in the same KSM page, that would amount to dozens of seconds
> > of
> > kernel runtime.
> 
> Silly question, but could we fix this problem
> by building up a bitmask of all CPUs that have
> a page-with-high-mapcount mapped, and simply
> send out a global TLB flush to those CPUs once
> we have changed the page tables, instead of
> sending out IPIs at every page table change?

That's great idea indeed, but it's an orthogonal optimization. Hugh
already posted a patch adding TTU_BATCH_FLUSH to try_to_unmap in
migrate and then call try_to_unmap_flush() at the end which is on the
same lines of you're suggesting. Problem is we still got millions of
entries potentially present in those lists with the current code, even
a list walk without IPI is prohibitive.

The only alternative is to make rmap_walk non atomic, i.e. break it in
the middle, because it's not just the cost of IPIs that is
excessive. However doing that breaks all sort of assumptions in the VM
and overall it will make it weaker, as when we're OOM we're not sure
anymore if we have been aggressive enough in clearing referenced bits
if tons of KSM pages are slightly above the atomic-walk-limit. Even
ignoring the VM behavior, page migration and in turn compaction and
memory offlining require scanning all entries in the list before we
can return to userland and remove the DIMM or succeed the increase of
echo > nr_hugepages, so all those features would become unreliable and
they could incur in enormous latencies.

Like Arjan mentioned, there's no significant downside in limiting the
"compression ratio" to x256 or x1024 or x2048 (depending on the sysctl
value) because the higher the limit the more we're hitting diminishing
returns.

On the design side I believe there's no other black and white possible
solution than this one that solves all problems with no downside at
all for the VM fast paths we care about the most.

On the implementation side if somebody can implement it better than I
did while still as optimal, so that the memory footprint of the KSM
metadata is unchanged (on 64bit), that would be welcome.

One thing that could be improved is adding proper defrag to increase
the average density to nearly match the sysctl value at all times, but
the heuristic I added (that tries to achieve the same objective by
picking the busiest stable_node_dup and putting it in the head of the
chain for the next merges) is working well too. There will be at least
2 entries for each stable_node_dup so the worst case density is still
x2. Real defrag that modifies pagetables would be as costly as page
migration, while this costs almost nothing as it's run once in a
while.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
