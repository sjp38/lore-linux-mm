Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 6E7EB6B00A9
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 21:04:15 -0400 (EDT)
Date: Wed, 11 Sep 2013 10:04:34 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [REPOST PATCH 3/4] slab: introduce byte sized index for the
 freelist of a slab
Message-ID: <20130911010434.GB24671@lge.com>
References: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1378447067-19832-4-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140f3fed229-f49b95d4-7087-476f-b2c9-37846749aad6-000000@email.amazonses.com>
 <20130909043217.GB22390@lge.com>
 <00000141032dea11-c5aa9c77-b2f2-4cab-b7a0-d37665a6cec8-000000@email.amazonses.com>
 <20130910054342.GB24602@lge.com>
 <0000014109c372c6-5f3c49d4-ce8b-4760-b80d-a32e042ec09b-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000014109c372c6-5f3c49d4-ce8b-4760-b80d-a32e042ec09b-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 10, 2013 at 09:25:05PM +0000, Christoph Lameter wrote:
> On Tue, 10 Sep 2013, Joonsoo Kim wrote:
> 
> > On Mon, Sep 09, 2013 at 02:44:03PM +0000, Christoph Lameter wrote:
> > > On Mon, 9 Sep 2013, Joonsoo Kim wrote:
> > >
> > > > 32 byte is not minimum object size, minimum *kmalloc* object size
> > > > in default configuration. There are some slabs that their object size is
> > > > less than 32 byte. If we have a 8 byte sized kmem_cache, it has 512 objects
> > > > in 4K page.
> > >
> > > As far as I can recall only SLUB supports 8 byte objects. SLABs mininum
> > > has always been 32 bytes.
> >
> > No.
> > There are many slabs that their object size are less than 32 byte.
> > And I can also create a 8 byte sized slab in my kernel with SLAB.
> 
> Well the minimum size for the kmalloc array is 32 bytes. These are custom
> slabs. KMALLOC_SHIFT_LOW is set to 5 in include/linux/slab.h.
> 
> Ok so there are some slabs like that. Hmmm.. We have sizes 16 and 24 in
> your list. 16*256 is still 4096. So this would still work fine if we would
> forbid a size of 8 or increase that by default to 16.
> 
> > > On x86 f.e. it would add useless branching. The branches are never taken.
> > > You only need these if you do bad things to the system like requiring
> > > large contiguous allocs.
> >
> > As I said before, since there is a possibility that some runtime loaded modules
> > use a 8 byte sized slab, we can't determine index size in compile time. Otherwise
> > we should always use short int sized index and I think that it is worse than
> > adding a branch.
> 
> We can enforce a mininum slab size and an order limit so that it fits. And
> then there would be no additional branching.
> 

Okay. I will respin this patchset with your suggestion.

Anyway, could you review my previous patchset, that is, 'overload struct slab
over struct page to reduce memory usage'? I'm not sure whether your answer is
ack or not.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
