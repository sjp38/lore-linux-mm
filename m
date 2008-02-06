Date: Tue, 5 Feb 2008 19:22:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Pull request: DMA pool updates
Message-Id: <20080205192226.79ba9982.akpm@linux-foundation.org>
In-Reply-To: <20080206025247.GA7705@parisc-linux.org>
References: <20080206025247.GA7705@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008 19:52:47 -0700 Matthew Wilcox <matthew@wil.cx> wrote:

> Could I ask you to pull the DMA Pool changes detailed below?
> 
> All the patches have been posted to linux-kernel before, and various
> comments (and acks) have been taken into account.  (see
> http://thread.gmane.org/gmane.linux.kernel/609943)
> 
> It's a fairly nice performance improvement, so would be good to get in.
> It's survived a few hours of *mumble* high-stress database benchmark,
> so I have high confidence in its stability.
> 
> The following changes since commit 21511abd0a248a3f225d3b611cfabb93124605a7:
>   Linus Torvalds (1):
>         Merge branch 'release' of git://git.kernel.org/.../aegl/linux-2.6
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/willy/misc.git dmapool

Looks OK to me - I think I reviewed these a while back?  We really should
have had this tree in -mm for general tyre-kicking.


What's with the #ifdef CONFIG_SLAB stuff in the dmapool code?  Are we just
overloading a convenient Kconfig label here, or is it required for some
reason?  Why not CONFIG_SLUB_DEBUG too?


For the future:

This code:

+struct dma_pool *dma_pool_create(const char *name, struct device *dev,
+				 size_t size, size_t align, size_t boundary)
+{
+	struct dma_pool *retval;
+	size_t allocation;
+
+	if (align == 0) {
+		align = 1;
+	} else if (align & (align - 1)) {
+		return NULL;
+	}
+
+	if (size == 0) {
+		return NULL;
+	} else if (size < 4) {
+		size = 4;
+	}
+
+	if ((size % align) != 0)
+		size = ALIGN(size, align);
+
+	allocation = max_t(size_t, size, PAGE_SIZE);
+
+	if (!boundary) {
+		boundary = allocation;
+	} else if ((boundary < size) || (boundary & (boundary - 1))) {
+		return NULL;
+	}

could do with some relief from its brace fetish and some education about
is_power_of_2().  And the `if ((size % align) != 0)' can just go away,
which will save code and is likely faster.

It's a separate thing I guess, but I don't see any reason why
dma_pool_alloc() _has_ to use GFP_ATOMIC.  Looks like it can do the
allocation outside spin_lock_irqsave() and use mem_flags instead.  If that
has __GFP_WAIT then we're in much better shape.

I wish all this code wouldn't do

	struct dma_page *page;

because one very much expects a local variable called "page" to be of type
`struct page *'.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
