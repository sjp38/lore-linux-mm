Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E925C6B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:50:16 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id z2-v6so10045053plk.3
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 10:50:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o81si2540771pfa.64.2018.04.10.10.50.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 10:50:16 -0700 (PDT)
Date: Tue, 10 Apr 2018 10:50:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a constructor
Message-ID: <20180410175011.GE3614@bombadil.infradead.org>
References: <20180410125351.15837-1-willy@infradead.org>
 <fee8a8bc-3db5-a66a-33cb-0729143ba615@gmail.com>
 <20180410165054.GC3614@bombadil.infradead.org>
 <alpine.DEB.2.20.1804101228170.29384@nuc-kabylake>
 <20180410173841.GD3614@bombadil.infradead.org>
 <alpine.DEB.2.20.1804101244290.29559@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804101244290.29559@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On Tue, Apr 10, 2018 at 12:45:56PM -0500, Christopher Lameter wrote:
> On Tue, 10 Apr 2018, Matthew Wilcox wrote:
> 
> > > How do you envision dealing with the SLAB_TYPESAFE_BY_RCU slab caches?
> > > Those must have a defined state of the objects at all times and a constructor is
> > > required for that. And their use of RCU is required for numerous lockless
> > > lookup algorithms in the kernhel.
> >
> > Not at all times.  Only once they've been used.  Re-constructing them
> > once they've been used might break the rcu typesafety, I suppose ...
> > would need to examine the callers.
> 
> Objects can be freed and reused and still be accessed from code that
> thinks the object is the old and not the new object....

Yes, I know, that's the point of RCU typesafety.  My point is that an
object *which has never been used* can't be accessed.  So you don't *need*
a constructor.
