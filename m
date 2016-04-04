Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 14E04828E5
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 17:55:59 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id c20so43843940pfc.1
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 14:55:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id di9si2929530pad.129.2016.04.04.14.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 14:55:58 -0700 (PDT)
Date: Mon, 4 Apr 2016 14:55:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm: filemap: only do access activations on reads
Message-Id: <20160404145557.5b6be2ca695044e400275620@linux-foundation.org>
In-Reply-To: <1459805987.6219.32.camel@redhat.com>
References: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
	<1459790018-6630-3-git-send-email-hannes@cmpxchg.org>
	<20160404142233.cfdea284b8107768fb359efd@linux-foundation.org>
	<1459805987.6219.32.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andres Freund <andres@anarazel.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, 04 Apr 2016 17:39:47 -0400 Rik van Riel <riel@redhat.com> wrote:

> On Mon, 2016-04-04 at 14:22 -0700, Andrew Morton wrote:
> > On Mon,____4 Apr 2016 13:13:37 -0400 Johannes Weiner <hannes@cmpxchg.or
> > g> wrote:
> > 
> > > 
> > > Andres Freund observed that his database workload is struggling
> > > with
> > > the transaction journal creating pressure on frequently read pages.
> > > 
> > > Access patterns like transaction journals frequently write the same
> > > pages over and over, but in the majority of cases those pages are
> > > never read back. There are no caching benefits to be had for those
> > > pages, so activating them and having them put pressure on pages
> > > that
> > > do benefit from caching is a bad choice.
> > Read-after-write is a pretty common pattern: temporary files for
> > example.____What are the opportunities for regressions here?
> > 
> > Did you consider providing userspace with a way to hint "this file is
> > probably write-then-not-read"?
> 
> I suspect the opportunity for regressions is fairly small,
> considering that temporary files usually have a very short
> life span, and will likely be read-after-written before they
> get evicted from the inactive list.

The opportunity for regressions in the current code is fairly small,
but Andres found one :( If there's any possibility at all, someone will
hit it.

One possible way to move forward is to write testcases to deliberately
hit the predicted problem, gain an understanding of how hard it is to
hit, how bad the effects are.

> As for hinting, I suspect it may make sense to differentiate
> between whole page and partial page writes, where partial
> page writes use FGP_ACCESSED, and whole page writes do not,
> under the assumption that if we write a partial page, there
> may be a higher chance that other parts of the page get
> accessed again for other writes (or reads).

hm, the FGP_foo documentation is a mess.  There's some placed randomly
at pagecache_get_page() and FGP_WRITE got missed altogether.

The ext4 journal would be a decent (but not very significant) candidate
for a "this is never read from" interface.  I guess the fs could
manually deactivate (or even free?) the pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
