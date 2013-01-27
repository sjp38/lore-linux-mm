Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id B32576B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 17:07:59 -0500 (EST)
Received: by mail-da0-f46.google.com with SMTP id p5so939652dak.5
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 14:07:58 -0800 (PST)
Date: Sun, 27 Jan 2013 14:08:00 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 5/11] ksm: get_ksm_page locked
In-Reply-To: <1359254187.4159.10.camel@kernel>
Message-ID: <alpine.LNX.2.00.1301271355430.17144@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251759470.29196@eggly.anvils> <1359254187.4159.10.camel@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 26 Jan 2013, Simon Jeons wrote:
> On Fri, 2013-01-25 at 18:00 -0800, Hugh Dickins wrote:
> > In some places where get_ksm_page() is used, we need the page to be locked.
> > 
> 
> In function get_ksm_page, why check page->mapping =>
> get_page_unless_zero => check page->mapping instead of
> get_page_unless_zero => check page->mapping, because
> get_page_unless_zero is expensive?

Yes, it's more expensive.

> 
> > When KSM migration is fully enabled, we shall want that to make sure that
> > the page just acquired cannot be migrated beneath us (raised page count is
> > only effective when there is serialization to make sure migration notices).
> > Whereas when navigating through the stable tree, we certainly do not want
> 
> What's the meaning of "navigating through the stable tree"?

Finding the right place in the stable tree,
as stable_tree_search() and stable_tree_insert() do.

> 
> > to lock each node (raised page count is enough to guarantee the memcmps,
> > even if page is migrated to another node).
> > 
> > Since we're about to add another use case, add the locked argument to
> > get_ksm_page() now.
> 
> Why the parameter lock passed from stable_tree_search/insert is true,
> but remove_rmap_item_from_tree is false?

The other way round?  remove_rmap_item_from_tree needs the page locked,
because it's about to modify the list: that's secured (e.g. against
concurrent KSM page reclaim) by the page lock.

stable_tree_search and stable_tree_insert do not need intermediate nodes
to be locked: get_page is enough to secure the page contents for memcmp,
and we don't want a pointless wait for exclusive page lock on every
intermediate node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
