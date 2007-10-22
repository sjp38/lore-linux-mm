Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1193073477.27435.186.camel@twins>
References: <1193064305.16541.3.camel@matrix>
	 <1193073477.27435.186.camel@twins>
Content-Type: text/plain
Date: Mon, 22 Oct 2007 19:20:56 +0200
Message-Id: <1193073656.27435.188.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: stefani@seibold.net
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Jaya Kumar <jayakumar.lkml@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-10-22 at 19:17 +0200, Peter Zijlstra wrote:
> On Mon, 2007-10-22 at 16:45 +0200, Stefani Seibold wrote:
> > Hi,
> > 
> > i have a problem with vmalloc() and vm_ops.page_mkwrite().
> > 
> > ReadOnly access works, but on a write access the VM will
> > endless invoke the vm_ops.page_mkwrite() handler.
> > 
> > I tracked down the problem to the
> > 	struct page.mapping pointer,
> > which is NULL.
> 
> Where?
> 
> would this happen to be in set_page_dirty_balance(, .page_mkwrite=1) ?
> 
> I indeed over-looked the fb_defio driver when I grepped the tree for
> ->page_mkwrite() usage :-/
> 
> The proper fix is to revert this set_page_dirty_balance() hack and make
> the filesystem ->page_mkwrite() implementations call
> balance_dirty_pages_ratelimited()

Hmm, that should all work out when page->mapping is NULL.

/me goes look again..

Aaah, the truncate fixlet, yes that will mess one up..
/me goes ponder what to do about that..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
