Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CE6FF6B026C
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 13:51:09 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id u206so14309559wme.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 10:51:09 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w19si13602197wjr.196.2016.04.05.10.51.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 10:51:08 -0700 (PDT)
Date: Tue, 5 Apr 2016 13:50:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] mm: filemap: only do access activations on reads
Message-ID: <20160405175059.GA16935@cmpxchg.org>
References: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
 <1459790018-6630-3-git-send-email-hannes@cmpxchg.org>
 <20160404142233.cfdea284b8107768fb359efd@linux-foundation.org>
 <1459805987.6219.32.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459805987.6219.32.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andres Freund <andres@anarazel.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Apr 04, 2016 at 05:39:47PM -0400, Rik van Riel wrote:
> As for hinting, I suspect it may make sense to differentiate
> between whole page and partial page writes, where partial
> page writes use FGP_ACCESSED, and whole page writes do not,
> under the assumption that if we write a partial page, there
> may be a higher chance that other parts of the page get
> accessed again for other writes (or reads).

The writeback cache should handle at least the multiple subpage writes
case.

What I find a little weird about counting accesses from partial writes
only is when a write covers a full page and then parts of the next. We
would cache only a small piece of what's likely one coherent chunk.

Or when a user writes out several pages in a loop of subpage chunks.

This will get even worse to program against when we start having page
cache transparently backed by pages of different sizes.

Because of that I think it'd be better to apply LRU aging decisions
based on type of access rather based on specific request sizes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
