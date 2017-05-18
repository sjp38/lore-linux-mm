Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id F029E831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 13:37:26 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id a46so16905013qte.3
        for <linux-mm@kvack.org>; Thu, 18 May 2017 10:37:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l38si6019600qtb.255.2017.05.18.10.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 10:37:26 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/3] KSMscale cleanup/optimizations
Date: Thu, 18 May 2017 19:37:18 +0200
Message-Id: <20170518173721.22316-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Evgheni Dereveanchin <ederevea@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Arjan van de Ven <arjan@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Gavin Guo <gavin.guo@canonical.com>, Jay Vosburgh <jay.vosburgh@canonical.com>, Mel Gorman <mgorman@techsingularity.net>, Dan Carpenter <dan.carpenter@oracle.com>

Hello,

This is incremental with the two fixes already in -mm.

There are no fixes here it's just minor cleanups and optimizations.

1/3 removes makes the "fix" for the stale stable_node fall in the
standard case without introducing new cases. Setting stable_node to
NULL was marginally safer, but stale pointer is still wiped from the
caller, this looks cleaner.

2/3 should fix the false positive from Dan's static checker. Dan could
you check if it still complains?

3/3 is a microoptimization to apply the the refile of future merge
candidate dups at the head of the chain in all cases and to skip it in
one case where we did it and but it was a noop (to avoid checking if
it was already at the head but now we've to check it anyway so it got
optimized away).

Andrea Arcangeli (3):
  ksm: cleanup stable_node chain collapse case
  ksm: swap the two output parameters of chain/chain_prune
  ksm: optimize refile of stable_node_dup at the head of the chain

 mm/ksm.c | 163 ++++++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 103 insertions(+), 60 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
