Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3E70A6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 02:03:53 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id xa7so896093pbc.24
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 23:03:52 -0800 (PST)
Received: from psmtp.com ([74.125.245.135])
        by mx.google.com with SMTP id ra5si6781783pbc.134.2013.11.03.23.03.51
        for <linux-mm@kvack.org>;
        Sun, 03 Nov 2013 23:03:52 -0800 (PST)
Date: Sun, 3 Nov 2013 23:03:28 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131104070328.GA17995@infradead.org>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <CA+55aFwrtOaFtwGc6xyZH6-1j3f--AG1JS-iZM8-pZPnwRHBow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwrtOaFtwGc6xyZH6-1j3f--AG1JS-iZM8-pZPnwRHBow@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Chinner <dchinner@redhat.com>

On Sun, Nov 03, 2013 at 10:51:27AM -0800, Linus Torvalds wrote:
> Ugh. This patch makes me angry. It looks way too ad-hoc.
> 
> I can well imagine that our current one-entry cache is crap and could
> be improved, but this looks too random. Different code for the
> CONFIG_MMU case? Same name, but for non-MMU it's a single entry, for
> MMU it's an array? And the whole "largest" just looks odd. Plus why do
> you set LAST_USED if you also set LARGEST?
> 
> Did you try just a two- or four-entry pseudo-LRU instead, with a
> per-thread index for "last hit"? Or even possibly a small fixed-size
> hash table (say "idx = (add >> 10) & 3" or something)?

Btw, Dave Chiner has recently implemented a simple look aside cache for
the buffer cache, which also uses a rbtree.  Might beworth into making
that into a generic library and use it here:

	http://thread.gmane.org/gmane.comp.file-systems.xfs.general/56220

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
