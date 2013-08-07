Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 949166B003B
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 19:51:27 -0400 (EDT)
Date: Wed, 7 Aug 2013 16:51:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] aoe: adjust ref of head for compound page tails
Message-Id: <20130807165125.38a4acd2a8bc533e52d07d06@linux-foundation.org>
In-Reply-To: <3F0FBDD9-129C-45F4-A20C-3EB2E8EFC9C8@coraid.com>
References: <cover.1375320764.git.ecashin@coraid.com>
	<0c8aff39249c1da6b9cc3356650149d065c3ebd2.1375320764.git.ecashin@coraid.com>
	<20130807135804.e62b75f6986e9568ab787562@linux-foundation.org>
	<8DFEA276-4EE1-44B4-9669-5634631D7BBC@coraid.com>
	<20130807141835.533816143f8b37175c50d58d@linux-foundation.org>
	<20130807142755.5cd89e02e4286f7dca88b80d@linux-foundation.org>
	<3F0FBDD9-129C-45F4-A20C-3EB2E8EFC9C8@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ed Cashin <ecashin@coraid.com>
Cc: linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org

On Wed, 7 Aug 2013 19:41:48 -0400 Ed Cashin <ecashin@coraid.com> wrote:

> On Aug 7, 2013, at 5:27 PM, Andrew Morton wrote:
> 
> >> elevated refcount, full stop.
> >> 
> > 
> > err, no.  slab.c uses alloc_pages(), so the underlying page indeed has
> > a proper refcount.  I'm still not understanding how this situation comes
> > about.
> 
> It sounds like it's wrong to give block pages with a zero count,

Depends on your definition of "page".  It should be OK to put a
_count==0 tail page into a BIO, because the MM knows that it's a tail
page and that its refcount actually lives in the head page.

> so why not just have aoe BUG_ON(compound_trans_head(bv->page->_count) == 0) until we're sure nobody does that anymore?

AOE shouldn't be touching ->_count at all.  That's why it has the
leading underscore.  If AOE can stick with the usual interfaces such as
page_count(), everything should work?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
