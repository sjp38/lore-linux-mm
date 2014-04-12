Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9DAA96B009B
	for <linux-mm@kvack.org>; Sat, 12 Apr 2014 17:03:28 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id f51so6119504qge.12
        for <linux-mm@kvack.org>; Sat, 12 Apr 2014 14:03:28 -0700 (PDT)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id d5si1312991qad.109.2014.04.12.14.03.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 12 Apr 2014 14:03:27 -0700 (PDT)
Received: by mail-qc0-f180.google.com with SMTP id w7so7379493qcr.39
        for <linux-mm@kvack.org>; Sat, 12 Apr 2014 14:03:27 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 0/2] swap: simplify/fix swap_list handling and iteration
Date: Sat, 12 Apr 2014 17:00:52 -0400
Message-Id: <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <alpine.LSU.2.11.1402232344280.1890@eggly.anvils>
References: <alpine.LSU.2.11.1402232344280.1890@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Dan Streetman <ddstreet@ieee.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Weijie Yang <weijieut@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The logic controlling the singly-linked list of swap_info_struct entries
for all active, i.e. swapon'ed, swap targets is rather complex, because:
-it stores the entries in priority order
-there is a pointer to the highest priority entry
-there is a pointer to the highest priority not-full entry
-there is a highest_priority_index variable set outside the swap_lock
-swap entries of equal priority should be used equally

this complexity leads to bugs such as:
https://lkml.org/lkml/2014/2/13/181
where different priority swap targets are incorrectly used equally.

That bug probably could be solved with the existing singly-linked lists,
but I think it would only add more complexity to the already difficult
to understand get_swap_page() swap_list iteration logic.

The first patch changes from a singly-linked list to a doubly-linked
list using list_heads; the highest_priority_index and related code are
removed and get_swap_page() starts each iteration at the highest priority
swap_info entry, even if it's full.  While this does introduce
unnecessary list iteration (i.e. Schlemiel the painter's algorithm)
in the case where one or more of the highest priority entries are full,
the iteration and manipulation code is much simpler and behaves
correctly re: the above bug; and the second patch removes the unnecessary
iteration.

The second patch adds a new list that contains only swap_info entries
that are both active and not full, and a new spinlock to protect it.
This allows swap_info entries to be added or removed from the new list
immediately as they become full or not full.


Dan Streetman (2):
  swap: change swap_info singly-linked list to list_head
  swap: use separate priority list for available swap_infos

 include/linux/swap.h     |   8 +--
 include/linux/swapfile.h |   2 +-
 mm/frontswap.c           |  13 ++---
 mm/swapfile.c            | 212 ++++++++++++++++++++++++++++++++++---------------------------------
 4 files changed, 114 insertions(+), 121 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
