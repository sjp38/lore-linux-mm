From: Zach Brown <zab@zabbo.net>
Subject: Re: [RFC][PATCH] Interface to invalidate regions of mmaps
Date: Tue, 13 May 2003 16:11:31 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3EC17BA3.7060403@zabbo.net>
References: <20030513133636.C2929@us.ibm.com> <20030513152141.5ab69f07.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
In-Reply-To: <20030513152141.5ab69f07.akpm@digeo.com>
To: Andrew Morton <akpm@digeo.com>
Cc: paulmck@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mjbligh@us.ibm.com
List-Id: linux-mm.kvack.org

Andrew Morton wrote:

> What filesystems would be needing this, and when could we see live code
> which actually uses it?

on the one hand, lustre would very much like something like this.  our
posix IO guarantees are centered around a DLM that knows about file
extents and the presence of pages in the page cache is tied to holding
these locks.  its very common for us to get a lock cancelation which
invalidates a region of a file that falls in the middle of what is cached.

worse still, our (possibly gi-normous) files are backed by striping the
file across multiple storage targets and the locks live on these
targets.  if you imagine a file that is built by alternating 64k-wide
stripes across 4 targets, we can get a lock cancelation that invalidates
pages at offset 0->15, 64->79,128->143, and so on.

so what we'd like most is the ability to invalidate a region of the file
in an efficient go.

void truncate_inode_pages(struct address_space * mapping, loff_t lstart,
loff_t end)

that sort of thing.  this might not suck so bad if the page cache was an
rbtree :)   in any case, what we've been doing so far is tracking dirty
page offsets in our own rbtree thing in lustre and calling
truncate_complete_page for these offsets as locks are canceled.  (our
locks are page-aligned, so we don't worry so much about partial page
pain in these particular paths).

but on the other hand, this doesn't solve another problem we have with
opportunistic lock extents and sparse page cache populations.  Ideally
we'd like a FS specific pointer in struct page so we can associate pages
in the cache with a lock, but I can't imagine suggesting such a thing
within earshot of wli.  so we'd still have to track the dirty offsets to
avoid having to pass through offsets 0 ... i_size only to find that one
page in the 8T file that was cached.

	https://lxr.lustre.org/source/llite/file.c?v=b_devel#602

is the most relevant part of the story.

- z
