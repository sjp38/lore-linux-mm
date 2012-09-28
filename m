Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id DC1196B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 07:26:52 -0400 (EDT)
Date: Fri, 28 Sep 2012 13:26:45 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v4] KSM: numa awareness sysfs knob
Message-ID: <20120928112645.GX19474@redhat.com>
References: <1348448166-1995-1-git-send-email-pholasek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348448166-1995-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

Hi everyone,

On Mon, Sep 24, 2012 at 02:56:06AM +0200, Petr Holasek wrote:
> +static struct rb_root root_unstable_tree[MAX_NUMNODES] = { RB_ROOT, };

not initializing is better so we don't waste .data and it goes in the
.bss, initializing only the first entry is useless anyway, that's
getting initialized later (maybe safer to initialize it once more in
some init routine too along with the below one for a peace of mind,
not at the first scan instance).

> +static struct rb_root root_stable_tree[MAX_NUMNODES] = { RB_ROOT, };

uninitialized root_stable_tree [1..]

> @@ -1300,7 +1341,8 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>  		 */
>  		lru_add_drain_all();
>  
> -		root_unstable_tree = RB_ROOT;
> +		for (i = 0; i < MAX_NUMNODES; i++)
> +			root_unstable_tree[i] = RB_ROOT;

s/MAX_NUMNODES/nr_node_ids/

> @@ -1758,7 +1800,12 @@ void ksm_migrate_page(struct page *newpage, struct page *oldpage)
>  	stable_node = page_stable_node(newpage);
>  	if (stable_node) {
>  		VM_BUG_ON(stable_node->kpfn != page_to_pfn(oldpage));
> -		stable_node->kpfn = page_to_pfn(newpage);
> +
> +		if (ksm_merge_across_nodes ||
> +				page_to_nid(oldpage) == page_to_nid(newpage))
> +			stable_node->kpfn = page_to_pfn(newpage);
> +		else
> +			remove_node_from_stable_tree(stable_node);
>  	}
>  }

This will result in memory corruption because the ksm page still
points to the stable_node that has been freed (that is copied by the
migrate code when the newpage->mapping = oldpage->mapping).

What should happen is that the ksm page of src_node is merged with
the pre-existing ksm page in the dst_node of the migration. That's the
complex case, the easy case is if there's no pre-existing page and
that just requires an insert of the stable node in a different rbtree
I think (without actual pagetable mangling).

It may be simpler to break cow across migrate and require the ksm
scanner to re-merge it however.

Basically the above would remove the ability to rmap the ksm page
(i.e. rmap crashes on a dangling pointer), but we need rmap to be
functional at all times on all ksm pages.

Hugh what's your views on this ksm_migrate_page NUMA aware that is
giving trouble? What would you prefer? Merge two ksm pages together
(something that has never happened before), break_cow (so we don't
have to merge two ksm pages together in the first place and we
fallback in the regular paths) etc...

All the rest looks very good, great work Petr!

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
