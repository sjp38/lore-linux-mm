Subject: Re: [PATCH] anobjrmap 2/6 mapping
From: "Stephen C. Tweedie" <sct@redhat.com>
In-Reply-To: <20030320224832.0334712d.akpm@digeo.com>
References: <Pine.LNX.4.44.0303202310440.2743-100000@localhost.localdomain>
	 <Pine.LNX.4.44.0303202312560.2743-100000@localhost.localdomain>
	 <20030320224832.0334712d.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1048534712.1907.398.camel@sisko.scot.redhat.com>
Mime-Version: 1.0
Date: 24 Mar 2003 19:38:32 +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 2003-03-21 at 06:48, Andrew Morton wrote:

> It goes BUG in try_to_free_buffers().
> 
> We really should fix this up for other reasons, probably by making ext3's
> per-page truncate operations wait on commit, and be more aggressive about
> pulling the page's buffers off the transaction at truncate time.

Ouch.

> The same thing _could_ happen with other filesystems; not too sure about
> that.

XFS used to have synchronous truncates, for similar sorts of reasons. 
It was dog slow for unlinks.  They worked pretty hard to fix that; I'd
really like to avoid adding extra synchronicity to ext3 in this case.

Pulling buffers off the transaction more aggressively would certainly be
worth looking at.  Trouble is, if a truncate transaction on disk gets
interrupted by a crash, you really do have to be able to undo it, so you
simply don't have the luxury of throwing the buffers away until a commit
has occurred (unless you're in writeback mode.)

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
