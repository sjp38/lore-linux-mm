Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCFB86B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:07:37 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v184so7389684wmf.1
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:07:37 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z12sor1109176edm.42.2017.12.13.04.07.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 04:07:36 -0800 (PST)
Date: Wed, 13 Dec 2017 15:07:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20171213120733.umeb7rylswl7chi5@node.shutemov.name>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208161559.27313-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, Dec 08, 2017 at 05:15:57PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> do_pages_move is supposed to move user defined memory (an array of
> addresses) to the user defined numa nodes (an array of nodes one for
> each address). The user provided status array then contains resulting
> numa node for each address or an error. The semantic of this function is
> little bit confusing because only some errors are reported back. Notably
> migrate_pages error is only reported via the return value. This patch
> doesn't try to address these semantic nuances but rather change the
> underlying implementation.
> 
> Currently we are processing user input (which can be really large)
> in batches which are stored to a temporarily allocated page. Each
> address is resolved to its struct page and stored to page_to_node
> structure along with the requested target numa node. The array of these
> structures is then conveyed down the page migration path via private
> argument. new_page_node then finds the corresponding structure and
> allocates the proper target page.
> 
> What is the problem with the current implementation and why to change
> it? Apart from being quite ugly it also doesn't cope with unexpected
> pages showing up on the migration list inside migrate_pages path.
> That doesn't happen currently but the follow up patch would like to
> make the thp migration code more clear and that would need to split a
> THP into the list for some cases.
> 
> How does the new implementation work? Well, instead of batching into a
> fixed size array we simply batch all pages that should be migrated to
> the same node and isolate all of them into a linked list which doesn't
> require any additional storage. This should work reasonably well because
> page migration usually migrates larger ranges of memory to a specific
> node. So the common case should work equally well as the current
> implementation. Even if somebody constructs an input where the target
> numa nodes would be interleaved we shouldn't see a large performance
> impact because page migration alone doesn't really benefit from
> batching. mmap_sem batching for the lookup is quite questionable and
> isolate_lru_page which would benefit from batching is not using it even
> in the current implementation.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/internal.h  |   1 +
>  mm/mempolicy.c |   5 +-
>  mm/migrate.c   | 306 +++++++++++++++++++++++++--------------------------------
>  3 files changed, 139 insertions(+), 173 deletions(-)

The approach looks fine to me.

But patch is rather large and hard to review. And how git mixed add/remove
lines doesn't help too. Any chance to split it up further?

One nitpick: I don't think 'chunk' terminology should go away with the
patch.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
