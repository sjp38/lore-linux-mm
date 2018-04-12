Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6EFB86B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 10:10:26 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id k23so3804460qtj.16
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 07:10:26 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id n8si4822495qtc.341.2018.04.12.07.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 07:10:25 -0700 (PDT)
Date: Thu, 12 Apr 2018 09:10:23 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/2] slab: __GFP_ZERO is incompatible with a
 constructor
In-Reply-To: <20180411235652.GA28279@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804120907100.11220@nuc-kabylake>
References: <20180411060320.14458-1-willy@infradead.org> <20180411060320.14458-3-willy@infradead.org> <alpine.DEB.2.20.1804110842560.3788@nuc-kabylake> <20180411192448.GD22494@bombadil.infradead.org> <alpine.DEB.2.20.1804111601090.7458@nuc-kabylake>
 <20180411235652.GA28279@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On Wed, 11 Apr 2018, Matthew Wilcox wrote:

>
> I don't see how that works ... can you explain a little more?
>
> I see ___slab_alloc() is called from __slab_alloc().  And I see
> slab_alloc_node does this:
>
>         object = c->freelist;
>         page = c->page;
>         if (unlikely(!object || !node_match(page, node))) {
>                 object = __slab_alloc(s, gfpflags, node, addr, c);
>                 stat(s, ALLOC_SLOWPATH);
>
> But I don't see how slub_debug leads to c->freelist always being NULL.
> It looks like it gets repopulated from page->freelist in ___slab_alloc()
> at the load_freelist label.

c->freelist is NULL and thus ___slab_alloc (slowpath) is called.
___slab_alloc populates c->freelist and gets the new object pointer.

if debugging is on then c->freelist is set to NULL at the end of
___slab_alloc because deactivate_slab() is called.

Thus the next invocation of the fastpath will find that c->freelist is
NULL and go to the slowpath. ...
