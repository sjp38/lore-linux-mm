Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6A05E6B0031
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 01:47:41 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so406525pdi.41
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 22:47:41 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so408881pdj.18
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 22:47:38 -0700 (PDT)
Date: Tue, 1 Oct 2013 22:47:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: pagevec: cleanup: drop pvec->cold argument in all
 places
In-Reply-To: <20130930150207.3661b5c146b6ecea84194547@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1310012243220.5682@chino.kir.corp.google.com>
References: <1380357239-30102-1-git-send-email-bob.liu@oracle.com> <20130930150207.3661b5c146b6ecea84194547@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, minchan@kernel.org, Bob Liu <bob.liu@oracle.com>

On Mon, 30 Sep 2013, Andrew Morton wrote:

> > Nobody uses the pvec->cold argument of pagevec and it's also unreasonable for
> > pages in pagevec released as cold page, so drop the cold argument from pagevec.
> 
> Is it unreasonable?  I'd say it's unreasonable to assume that all pages
> in all cases are likely to be cache-hot.  Example: what if the pages
> are being truncated and were found to be on the inactive LRU,
> unreferenced?
> 
> A useful exercise would be to go through all those pagevec_init() sites
> and convince ourselves that the decision at each place was the correct
> one.
> 

Agreed, and the "cold" argument to release_pages() becomes a no-op if this 
patch is merged meaning that anything released through it will 
automatically go to the start of the pcp lists.  If the pages aren't hot 
then this is exactly the opposite of what we wanted to do; the fact that 
the pvec length doesn't take into account the size of cpu cache can almost 
guarantee that everything isn't cache hot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
