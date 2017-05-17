Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1404B6B02E1
	for <linux-mm@kvack.org>; Wed, 17 May 2017 16:03:05 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e65so15351928ita.1
        for <linux-mm@kvack.org>; Wed, 17 May 2017 13:03:05 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q198si3178474iod.83.2017.05.17.13.03.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 13:03:04 -0700 (PDT)
Date: Wed, 17 May 2017 23:02:55 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20170517200255.67kvej2onwv54psi@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: linux-mm@kvack.org

Hello Andrea Arcangeli,

The patch 1073fbb7013b: "ksm: introduce ksm_max_page_sharing per page
deduplication limit" from May 13, 2017, leads to the following static
checker warning:

	mm/ksm.c:1442 __stable_node_chain()
	warn: 'stable_node' was already freed.

mm/ksm.c
  1433  static struct stable_node *__stable_node_chain(struct stable_node **_stable_node,
  1434                                                 struct page **tree_page,
  1435                                                 struct rb_root *root,
  1436                                                 bool prune_stale_stable_nodes)
  1437  {
  1438          struct stable_node *stable_node = *_stable_node;
  1439          if (!is_stable_node_chain(stable_node)) {
  1440                  if (is_page_sharing_candidate(stable_node)) {
  1441                          *tree_page = get_ksm_page(stable_node, false);
  1442                          return stable_node;

There is a comment about this somewhere down the call tree but if
get_ksm_page() fails then we're returning a freed pointer here which is
gnarly.

  1443                  }
  1444                  return NULL;
  1445          }
  1446          return stable_node_dup(_stable_node, tree_page, root,
  1447                                 prune_stale_stable_nodes);
  1448  }


regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
