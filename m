Date: Thu, 20 Mar 2003 22:48:32 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] anobjrmap 2/6 mapping
Message-Id: <20030320224832.0334712d.akpm@digeo.com>
In-Reply-To: <Pine.LNX.4.44.0303202312560.2743-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0303202310440.2743-100000@localhost.localdomain>
	<Pine.LNX.4.44.0303202312560.2743-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> It is likely that I've screwed up on the "Morton pages", those
> ext3 journal pages locked at truncate time which then turn into
> fish with wings: please check them out, I never manage to wrap
> my head around them.  Certainly don't want a page using private
> for both bufferheads and swp_entry_t.

It goes BUG in try_to_free_buffers().

We really should fix this up for other reasons, probably by making ext3's
per-page truncate operations wait on commit, and be more aggressive about
pulling the page's buffers off the transaction at truncate time.

The same thing _could_ happen with other filesystems; not too sure about
that.

Still.  I suggest you look at freeing up page->list from anon/swapcache
pages.  It really doesn't do much.

Meanwhile, I backed out that bit - I don't actually see where the failure is
anyway.  The page is page_mapped(), !PageAnon and ->mapping == NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
