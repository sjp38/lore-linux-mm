Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 08E8D6B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 17:12:57 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 1-v6so11320294plv.6
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 14:12:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a59-v6si1454966pla.497.2018.04.03.14.12.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Apr 2018 14:12:55 -0700 (PDT)
Date: Tue, 3 Apr 2018 14:12:53 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 1/1] vmscan: Support multiple kswapd threads per node
Message-ID: <20180403211253.GC30145@bombadil.infradead.org>
References: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
 <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
 <20180403133115.GA5501@dhcp22.suse.cz>
 <20180403190759.GB6779@bombadil.infradead.org>
 <A1EF8129-7F59-49CB-BEEC-E615FB878CE2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <A1EF8129-7F59-49CB-BEEC-E615FB878CE2@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Buddy Lumpkin <buddy.lumpkin@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, akpm@linux-foundation.org

On Tue, Apr 03, 2018 at 01:49:25PM -0700, Buddy Lumpkin wrote:
> > Yes, very much this.  If you have a single-threaded workload which is
> > using the entirety of memory and would like to use even more, then it
> > makes sense to use as many CPUs as necessary getting memory out of its
> > way.  If you have N CPUs and N-1 threads happily occupying themselves in
> > their own reasonably-sized working sets with one monster process trying
> > to use as much RAM as possible, then I'd be pretty unimpressed to see
> > the N-1 well-behaved threads preempted by kswapd.
> 
> The default value provides one kswapd thread per NUMA node, the same
> it was without the patch. Also, I would point out that just because you devote
> more threads to kswapd, doesna??t mean they are busy. If multiple kswapd threads
> are busy, they are almost certainly doing work that would have resulted in
> direct reclaims, which are often substantially more expensive than a couple
> extra context switches due to preemption.

[...]

> In my previous response to Michal Hocko, I described
> how I think we could scale watermarks in response to direct reclaims, and
> launch more kswapd threads when kswapd peaks at 100% CPU usage.

I think you're missing my point about the workload ... kswapd isn't
"nice", so it will compete with the N-1 threads which are chugging along
at 100% CPU inside their working sets.  In this scenario, we _don't_
want to kick off kswapd at all; we want the monster thread to clean up
its own mess.  If we have idle CPUs, then yes, absolutely, lets have
them clean up for the monster, but otherwise, I want my N-1 threads
doing their own thing.

Maybe we should renice kswapd anyway ... thoughts?  We don't seem to have
had a nice'd kswapd since 2.6.12, but maybe we played with that earlier
and discovered it was a bad idea?
