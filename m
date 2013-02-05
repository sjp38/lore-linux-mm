Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 5908D6B0008
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 12:18:10 -0500 (EST)
Date: Tue, 5 Feb 2013 17:18:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/11] ksm: get_ksm_page locked
Message-ID: <20130205171805.GK21389@suse.de>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
 <alpine.LNX.2.00.1301251759470.29196@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1301251759470.29196@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 25, 2013 at 06:00:50PM -0800, Hugh Dickins wrote:
> In some places where get_ksm_page() is used, we need the page to be locked.
> 
> When KSM migration is fully enabled, we shall want that to make sure that
> the page just acquired cannot be migrated beneath us (raised page count is
> only effective when there is serialization to make sure migration notices).
> Whereas when navigating through the stable tree, we certainly do not want
> to lock each node (raised page count is enough to guarantee the memcmps,
> even if page is migrated to another node).
> 
> Since we're about to add another use case, add the locked argument to
> get_ksm_page() now.
> 
> Hmm, what's that rcu_read_lock() about?  Complete misunderstanding, I
> really got the wrong end of the stick on that!  There's a configuration
> in which page_cache_get_speculative() can do something cheaper than
> get_page_unless_zero(), relying on its caller's rcu_read_lock() to have
> disabled preemption for it.  There's no need for rcu_read_lock() around
> get_page_unless_zero() (and mapping checks) here.  Cut out that
> silliness before making this any harder to understand.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  mm/ksm.c |   23 +++++++++++++----------
>  1 file changed, 13 insertions(+), 10 deletions(-)
> 
> --- mmotm.orig/mm/ksm.c	2013-01-25 14:36:53.244205966 -0800
> +++ mmotm/mm/ksm.c	2013-01-25 14:36:58.856206099 -0800
> @@ -514,15 +514,14 @@ static void remove_node_from_stable_tree
>   * but this is different - made simpler by ksm_thread_mutex being held, but
>   * interesting for assuming that no other use of the struct page could ever
>   * put our expected_mapping into page->mapping (or a field of the union which
> - * coincides with page->mapping).  The RCU calls are not for KSM at all, but
> - * to keep the page_count protocol described with page_cache_get_speculative.
> + * coincides with page->mapping).
>   *
>   * Note: it is possible that get_ksm_page() will return NULL one moment,
>   * then page the next, if the page is in between page_freeze_refs() and
>   * page_unfreeze_refs(): this shouldn't be a problem anywhere, the page
>   * is on its way to being freed; but it is an anomaly to bear in mind.
>   */
> -static struct page *get_ksm_page(struct stable_node *stable_node)
> +static struct page *get_ksm_page(struct stable_node *stable_node, bool locked)
>  {

The naming is unhelpful :(

Because the second parameter is called "locked", it implies that the
caller of this function holds the page lock (which is obviously very
silly). ret_locked maybe?

As the function is akin to find_lock_page I would  prefer if there was
a new get_lock_ksm_page() instead of locking depending on the value of a
parameter. We can do this because expected_mapping is recorded by the
stable_node and we only need to recalculate it if the page has been
successfully pinned. We calculate the expected value twice but that's
not earth shattering. It'd look something like;

/*
 * get_lock_ksm_page: Similar to get_ksm_page except returns with page
 * locked and pinned
 */
static struct page *get_lock_ksm_page(struct stable_node *stable_node)
{
	struct page *page = get_ksm_page(stable_node);

	if (page) {
  		expected_mapping = (void *)stable_node +
  				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
		lock_page(page);
		if (page->mapping != expected_mapping) {
			unlock_page(page);

			/* release pin taken by get_ksm_page() */
			put_page(page);
			page = NULL;
		}
	}

	return page;
}

Up to you, I'm not going to make a big deal of it.

FWIW, I agree that removing rcu_read_lock() is fine.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
