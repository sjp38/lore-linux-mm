Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE40A28026B
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 19:11:36 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n4so112139753lfb.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 16:11:36 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id x198si9505451lfa.175.2016.09.26.16.11.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 16:11:35 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id y6so163773668lff.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 16:11:34 -0700 (PDT)
Date: Tue, 27 Sep 2016 02:11:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160926231132.GA17069@node.shutemov.name>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <1474925009.17726.61.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474925009.17726.61.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On Mon, Sep 26, 2016 at 05:23:29PM -0400, Rik van Riel wrote:
> On Mon, 2016-09-26 at 13:58 -0700, Linus Torvalds wrote:
> 
> > Is there really any reason for that incredible indirection? Do we
> > really want to make the page_waitqueue() be a per-zone thing at all?
> > Especially since all those wait-queues won't even be *used* unless
> > there is actual IO going on and people are really getting into
> > contention on the page lock.. Why isn't the page_waitqueue() just one
> > statically sized array?
> 
> Why are we touching file pages at all during fork()?

We are not.
Unless the vma has private pages (vma->anon_vma is not NULL).

See first lines for copy_page_range().

We probably can go futher and skip non-private pages within file VMA.
But we would need to touch struct page in this case, so it doesn't make
sense.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
