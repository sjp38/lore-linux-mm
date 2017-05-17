Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CCF226B02F3
	for <linux-mm@kvack.org>; Wed, 17 May 2017 17:52:23 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z142so9320313qkz.8
        for <linux-mm@kvack.org>; Wed, 17 May 2017 14:52:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y4si3336936qky.120.2017.05.17.14.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 14:52:23 -0700 (PDT)
Date: Wed, 17 May 2017 23:52:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [bug report] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20170517215219.GA27094@redhat.com>
References: <20170517200255.67kvej2onwv54psi@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170517200255.67kvej2onwv54psi@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

Hello Dan,

On Wed, May 17, 2017 at 11:02:55PM +0300, Dan Carpenter wrote:
> Hello Andrea Arcangeli,
> 
> The patch 1073fbb7013b: "ksm: introduce ksm_max_page_sharing per page
> deduplication limit" from May 13, 2017, leads to the following static
> checker warning:
> 
> 	mm/ksm.c:1442 __stable_node_chain()
> 	warn: 'stable_node' was already freed.
> 
> mm/ksm.c
>   1433  static struct stable_node *__stable_node_chain(struct stable_node **_stable_node,
>   1434                                                 struct page **tree_page,
>   1435                                                 struct rb_root *root,
>   1436                                                 bool prune_stale_stable_nodes)
>   1437  {
>   1438          struct stable_node *stable_node = *_stable_node;
>   1439          if (!is_stable_node_chain(stable_node)) {
>   1440                  if (is_page_sharing_candidate(stable_node)) {
>   1441                          *tree_page = get_ksm_page(stable_node, false);
>   1442                          return stable_node;
> 
> There is a comment about this somewhere down the call tree but if
> get_ksm_page() fails then we're returning a freed pointer here which is
> gnarly.
> 
>   1443                  }
>   1444                  return NULL;
>   1445          }
>   1446          return stable_node_dup(_stable_node, tree_page, root,
>   1447                                 prune_stale_stable_nodes);
>   1448  }

__stable_node_chain is invoked by chain and chain_prune.

		stable_node_dup = chain(stable_node, &tree_page, root);
		if (!stable_node_dup) {
[..]
		}
		VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
		if (!tree_page) {
			goto again;

		stable_node_dup = chain_prune(&stable_node, &tree_page, root);
		if (!stable_node_dup) {
[..]
		}
		VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
		if (!tree_page) {
			goto again;

If the stable_node was freed tree_page is NULL. So it's a false
positive.

I agree it's not great to return a stale pointer but if we return
NULL, stable_node_dup_any would then run on the stale stable_node
which would then be a kernel crashing bug. There's a reason why this
isn't returned as NULL and we depend on the following tree_page check
to bail out.

I noticed in the fix for the real stale stable_node corruption with
merge_across_node = 0, it may be enough to set *_stable_node to
"found" (instead of NULL as I implemented in the fix). This way when
the chain is collapsed to the caller it will look like the chain never
existed and there's no special !stable_node check to care about later
(the check can return "stable_node == stable_node_dup"). Considering
such bug was real I wanted to set it to NULL to be sure the stale
stable_node was never accessed by mistake following such collapse
(NULL provided extra safety). However now that such bug seems fixed,
it may be enough to hide the collapse and it'll remove one branch in
the code as there will be no need to check !stable_node to detect the
collapse. It's a bit more risky than my initial fix but it could be
also considered a cleanup.

I thought above the above in the context of you report, because then
we could proceed to set *_stable_node = NULL in the case you worried
about, which would get its own new meaning. In the current code
setting *_stable_node to NULL under the chain*() calls means the
collapse happened (which doesn't rebalance the tree and doesn't
require to restart the look), while it could then mean the regular
stable_node was freed (which rebalances the tree and the lookup must
restart). Then we could return NULL in chain*() if the KSM page was
freed and then bail out immediately if stable_node also become NULL.

Ideally we could go further, and change get_ksm_page to get
&stable_node a parameter and set it to NULL in the caller if it's
freed by the callee to wipe out all stale pointers from all callees.

Considering these are purely cleanups, comments are welcome, as I've
no strong particular preference about this but I can implement if
agreed.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
