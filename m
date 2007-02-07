Date: Wed, 7 Feb 2007 14:32:33 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Drop PageReclaim()
In-Reply-To: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Feb 2007, Christoph Lameter wrote:

> Am I missing something here? I cannot see PageReclaim have any effect?

I think you are missing something.

> 
> PageReclaim is only used for dead code. The only current user is
> end_page_writeback() which has the following lines:
> 
>  if (!TestClearPageReclaim(page) || rotate_reclaimable_page(page)) {
>          if (!test_clear_page_writeback(page))
>                   BUG();
>  }
> 
> So the if statement is performed if !PageReclaim(page).
> If PageReclaim is set then we call rorate_reclaimable(page) which
> does:
> 
>  if (!PageLRU(page))
>        return 1;
> 
> The only user of PageReclaim is shrink_list(). The pages processed
> by shrink_list have earlier been taken off the LRU. So !PageLRU is always 
> true.

On return from shrink_page_list(),
doesn't shrink_inactive_list() put those pages back on the LRU?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
