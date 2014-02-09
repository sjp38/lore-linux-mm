Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4538C6B0031
	for <linux-mm@kvack.org>; Sun,  9 Feb 2014 12:35:14 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id q59so3573121wes.37
        for <linux-mm@kvack.org>; Sun, 09 Feb 2014 09:35:13 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id k3si21216214eep.36.2014.02.09.09.35.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 09 Feb 2014 09:35:12 -0800 (PST)
Date: Sun, 9 Feb 2014 12:34:18 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 02/10] fs: cachefiles: use add_to_page_cache_lru()
Message-ID: <20140209173418.GH4407@cmpxchg.org>
References: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
 <1391475222-1169-3-git-send-email-hannes@cmpxchg.org>
 <20140208114334.GA25841@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140208114334.GA25841@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Feb 08, 2014 at 09:43:35AM -0200, Rafael Aquini wrote:
> On Mon, Feb 03, 2014 at 07:53:34PM -0500, Johannes Weiner wrote:
> > This code used to have its own lru cache pagevec up until a0b8cab3
> > ("mm: remove lru parameter from __pagevec_lru_add and remove parts of
> > pagevec API").  Now it's just add_to_page_cache() followed by
> > lru_cache_add(), might as well use add_to_page_cache_lru() directly.
> >
> 
> Just a heads-up, here: take a look at https://lkml.org/lkml/2014/2/7/587

Ah, yes.  That patch replaced a private pagevec, which consumes the
references you pass in, with add_to_page_cache_lru(), which gets its
own references.

My patch changes

    add_to_page_cache()
    lru_cache_add()

to

    add_to_page_cache_lru()
      add_to_page_cache()
      lru_cache_add()

so the refcounting does not change for the caller.

Thanks for pointing it out, though, it never hurts to double check
stuff like that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
