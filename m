Date: Wed, 7 Feb 2007 09:25:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Drop PageReclaim()
Message-Id: <20070207092517.15071f04.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Feb 2007 06:13:48 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:

> Am I missing something here? I cannot see PageReclaim have any effect?
> 
> 
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
> 
> The if statement is therefore always true and the rotating code
> is never executed.

end_page_writeback() is amazingly obscure for such a short function.  For
which I apologise, but on revisit, it's still not obvious how to clean it
up.

It does:

	if (!PageReclaim(page)) {
		clear_page_writeback();
	}
	if (PageRecaim(page)) {
		ClearPageReclaim(page);
		foo = rotate_reclaimable_page(page);
		if (foo == 0) {
			/*
			 * rotate_reclaimable_page has already done
			 * clear_page_writeback()
			 */
		} else {
			clear_page_writeback(page);
		}
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
