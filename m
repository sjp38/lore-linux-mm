Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 518236B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 12:46:51 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id o11so561650202qge.2
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 09:46:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e132si31899187qhc.70.2016.01.18.09.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 09:46:50 -0800 (PST)
Date: Mon, 18 Jan 2016 18:46:46 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20160118174646.GA3181@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1601141356080.13199@eggly.anvils>
 <20160116174953.GU31137@redhat.com>
 <alpine.LSU.2.11.1601180014320.1538@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1601180014320.1538@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>

On Mon, Jan 18, 2016 at 01:10:42AM -0800, Hugh Dickins wrote:
> Puhleese.  Of course we have a bug with respect to KSM pages in
> migrate_pages(): I already said as much, though I used the example
> of mbind(), that being the one you had mentioned.  Just do something
> like mremap() does, a temporary ksm_madvise(,,,MADV_UNMERGEABLE,).
> 
> Or are you suggesting that when MPOL_MF_MOVE_ALL meets a KSM page,
> it is actually correct to move every page that shares the same data
> to the node of this process's choice?

So you think it's wrong that the migrate_pages() syscall can move KSM
pages too? If yes, why don't you simply add a check for PageKSM in
migrate_pages? Forbidding all KSM pages to be migrated would be a
simple and black and white fix for it.

I mean either we allow all KSM pages to be migrated, or none. I don't
like that we allow some to be migrated if it looks like it will take
less than 60seconds to do so... rmap_walks always were intended to be
atomic.

Even assuming migrate_pages should be fixed to prevent KSM pages to be
migrated, for me that was not a bug but a feature. It allowed me to
code the simplest reproducer to show how long it takes to do a
rmap_walk with a KSM page with high sharing.

Before I wrote this testcase it wasn't trivial at all to measure or
even reproduce the hang no matter what you throw it at it. In fact the
hang takes normally days or weeks to reproduce, but when they hit
systems go down. The testcase I posted simplifies the reproduction
of the VM badness tremendously.

Page migration ultimately was my concern. Just as things stands today
even the migrate_pages hammer didn't look entirely safe (no matter if
the user is an artificial test like mine that calls migrate_pages for
whatever reason, or simply a benchmark) but that's certainly not the
primary concern.

> MPOL_MF_MOVE_ALL was introduced some while before KSM: it makes sense
> for anon pages, and for file pages, but it was mere oversight that we
> did not stop it from behaving this way on KSM pages.
> 
> Even sillier now that we have Petr's merge_across_nodes settable to 0.

The merge_across_nodes set to 0 must not break either when
migrate_pages moves a KSM page to a different node. Nothing wrong with
that, in fact it's a good stress test.

> Forget that above program, it's easily fixed (or rather, the kernel
> is easily fixed for it): please argue with a better example.

I don't think I can write a simpler or smaller testcase that shows
exactly how bad things can get with the rmap walks. If I abused a
"feature" in migrate_pages to achieve it, that still made my life
easier at reproducing the VM badness that has to be fixed somehow.

> Fair enough.  I'm not saying it's a big worry, just that the design
> would have been more elegant and appealing without this side to it.
> I wonder who's going to tune stable_node_chains_prune_millisecs :)

stable_node_chains_prune_millisecs can be set to any value and it
won't make much difference actually, it's a tradeoff between KSM CPU
usage and a slight delay in freeing the KSM metadata, but it's not
like it has a big impact on anything. This isn't metadata that amounts
to significant amounts of memory nor that it will grow fast. But that
being a fixed number, I made it sysfs configurable.

I've a much easier time to set the max sharing limit and a deep
garbage collection event every couple of millisecs, than dynamically
deciding what's the magic breakpoint page_mapcount number where
page_migration, try_to_unmap and page_referenced should bail out or
system hangs... but if they happen to bail out too soon the VM will be
in a DoS.

> The VM gets slower and more complicated: the CPUs get faster and smarter.

Eheh, luckily it's not that bad ;), your page_migration TLB flush
batching should provide a significant boost that may allow to increase
the max sharing limit already compared to the current value I set in
the patch.

Complexity increases yes, but VM gets faster as your patch shows.

The testcase I posted is precisely the program that you should run to
test the effectiveness of your page_migration improvement. Perhaps you
can add a bit of printf so you won't have to use strace -tt :).

> I'll think about it more.

Back this being an HW issue, as far as the VM is concerned, all
rmap_walks were intended to simulate having the accessed or dirty bit
in the page structure (kind of s390?) not in the plenty of pagetables
that maps the page. We collapse all pagetable bits in a single
per-physical page bit. This is why they're atomic and we don't break
the loop, and my patch just allows this model to be retained. If we
start breaking the loop and in turn break the atomicity of the
rmap_walks, we just increase false positive OOM risk in some
unpredictable way.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
