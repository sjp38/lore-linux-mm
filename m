Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 712156B0026
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:21:48 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s11so1835428ioa.8
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:21:48 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id k21-v6si1918889iti.146.2018.04.10.13.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 13:21:47 -0700 (PDT)
Date: Tue, 10 Apr 2018 15:21:45 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a
 constructor
In-Reply-To: <20180410175011.GE3614@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804101512350.30225@nuc-kabylake>
References: <20180410125351.15837-1-willy@infradead.org> <fee8a8bc-3db5-a66a-33cb-0729143ba615@gmail.com> <20180410165054.GC3614@bombadil.infradead.org> <alpine.DEB.2.20.1804101228170.29384@nuc-kabylake> <20180410173841.GD3614@bombadil.infradead.org>
 <alpine.DEB.2.20.1804101244290.29559@nuc-kabylake> <20180410175011.GE3614@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On Tue, 10 Apr 2018, Matthew Wilcox wrote:

> > Objects can be freed and reused and still be accessed from code that
> > thinks the object is the old and not the new object....
>
> Yes, I know, that's the point of RCU typesafety.  My point is that an
> object *which has never been used* can't be accessed.  So you don't *need*
> a constructor.

But the object needs to have the proper contents after it was released and
re-allocated. Some objects may rely on contents (like list heads)
surviving the realloc process because access must always be possible.

validate_slab() checks on proper metadata content in a slab
although it does not access the payload. So that may work you separate
the payload init from the metadata init.
